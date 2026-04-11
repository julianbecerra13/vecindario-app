package fn

import (
	"context"
	"log"
	"time"

	"cloud.google.com/go/firestore"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"google.golang.org/api/iterator"
)

func init() {
	functions.CloudEvent("AssignPQRS", assignPQRS)
}

// SLA por tipo de PQRS (en horas)
var slaByCategoryHours = map[string]int{
	"mantenimiento": 72,
	"seguridad":     24,
	"convivencia":   48,
	"administracion": 48,
}

// assignPQRS — Auto-asigna al área responsable según categoría y calcula deadline SLA
func assignPQRS(ctx context.Context, e interface{}) error {
	fs, msg, err := initFirebase(ctx)
	if err != nil {
		return err
	}
	defer fs.Close()

	// Buscar PQRS recién creados sin asignar
	iter := fs.CollectionGroup("pqrs").
		Where("status", "==", "received").
		Where("assignedTo", "==", "").
		Documents(ctx)
	defer iter.Stop()

	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return err
		}

		data := doc.Data()
		category, _ := data["category"].(string)
		pqrsType, _ := data["type"].(string)

		// Calcular SLA deadline
		slaHours := slaByCategoryHours[category]
		if slaHours == 0 {
			slaHours = 72 // Default 3 días
		}
		slaDeadline := time.Now().Add(time.Duration(slaHours) * time.Hour)

		// Asignar al admin de la comunidad
		communityRef := doc.Ref.Parent.Parent
		if communityRef == nil {
			continue
		}
		communityDoc, err := communityRef.Get(ctx)
		if err != nil {
			continue
		}
		adminUID, _ := communityDoc.Data()["adminUid"].(string)

		_, err = doc.Ref.Update(ctx, []firestore.Update{
			{Path: "assignedTo", Value: adminUID},
			{Path: "slaDeadline", Value: slaDeadline},
			{Path: "status", Value: "inProgress"},
			{Path: "assignedAt", Value: time.Now()},
		})
		if err != nil {
			log.Printf("Error assigning PQRS %s: %v", doc.Ref.ID, err)
			continue
		}

		// Notificar al admin
		if msg != nil && adminUID != "" {
			residentUid, _ := data["residentUid"].(string)
			_ = sendPushToUser(ctx, fs, msg, adminUID,
				"Nuevo PQRS: "+pqrsType,
				"Se ha recibido un nuevo "+pqrsType+" en la categoría "+category,
				"/premium/pqrs",
			)
			_ = residentUid // Se puede usar para notificar de vuelta
		}

		log.Printf("PQRS %s assigned to %s with SLA %dh", doc.Ref.ID, adminUID, slaHours)
	}
	return nil
}
