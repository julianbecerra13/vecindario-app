package fn

import (
	"context"
	"fmt"
	"log"
	"time"

	"cloud.google.com/go/firestore"
	cloudevents "github.com/cloudevents/sdk-go/v2"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"google.golang.org/api/iterator"
)

func init() {
	functions.CloudEvent("BillSubscription", BillSubscription)
}

// Precios por plan en COP
var planPrices = map[string]int64{
	"starter":      150000,
	"professional": 350000,
	"enterprise":   600000,
}

// BillSubscription — Scheduled mensual (Cloud Scheduler)
// Cobra suscripción B2B a cada comunidad con plan activo
func BillSubscription(ctx context.Context, e cloudevents.Event) error {
	fs, _, err := initFirebase(ctx)
	if err != nil {
		return err
	}
	defer fs.Close()

	now := time.Now()

	// Buscar suscripciones activas cuyo nextBillingDate ya pasó
	iter := fs.Collection("subscriptions").
		Where("status", "in", []interface{}{"active", "trial"}).
		Documents(ctx)
	defer iter.Stop()

	billed := 0
	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return err
		}

		data := doc.Data()
		status, _ := data["status"].(string)
		plan, _ := data["plan"].(string)

		// Si es trial, verificar si ya terminó
		if status == "trial" {
			trialEnds, ok := data["trialEndsAt"].(time.Time)
			if ok && now.Before(trialEnds) {
				continue // Trial aún vigente, no cobrar
			}
			// Trial terminado, activar cobro
			_, err = doc.Ref.Update(ctx, []firestore.Update{
				{Path: "status", Value: "active"},
			})
			if err != nil {
				log.Printf("Error activating subscription %s: %v", doc.Ref.ID, err)
			}
		}

		// Verificar fecha de siguiente cobro
		nextBilling, ok := data["nextBillingDate"].(time.Time)
		if ok && now.Before(nextBilling) {
			continue // No es hora de cobrar
		}

		price := planPrices[plan]
		if price == 0 {
			continue
		}

		// Registrar cobro
		communityID := doc.Ref.ID
		_, _, err = fs.Collection("billing_records").Add(ctx, map[string]interface{}{
			"communityId": communityID,
			"plan":        plan,
			"amount":      price,
			"period":      now.Format("2006-01"),
			"status":      "pending",
			"createdAt":   now,
		})
		if err != nil {
			log.Printf("Error creating billing record for %s: %v", communityID, err)
			continue
		}

		// Actualizar siguiente fecha de cobro (+1 mes)
		nextMonth := now.AddDate(0, 1, 0)
		_, err = doc.Ref.Update(ctx, []firestore.Update{
			{Path: "nextBillingDate", Value: nextMonth},
			{Path: "lastBilledAt", Value: now},
		})
		if err != nil {
			log.Printf("Error updating billing date for %s: %v", communityID, err)
		}

		billed++
		log.Printf("Billed subscription: community=%s plan=%s amount=%d", communityID, plan, price)
	}

	if billed > 0 {
		log.Printf("BillSubscription: %d subscriptions billed", billed)
	}

	_ = fmt.Sprintf // Avoid unused import
	return nil
}
