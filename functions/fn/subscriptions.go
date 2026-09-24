package fn

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"time"

	"cloud.google.com/go/firestore"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	cloudevents "github.com/cloudevents/sdk-go/v2"
	"google.golang.org/api/iterator"
)

func init() {
	functions.CloudEvent("BillSubscription", BillSubscription)
	functions.HTTP("StartSubscriptionTrial", StartSubscriptionTrial)
}

type startTrialRequest struct {
	CommunityID string `json:"communityId"`
	Plan        string `json:"plan"`
}

func StartSubscriptionTrial(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	ctx := r.Context()
	uid, err := verifyAuthToken(ctx, r)
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}
	var req startTrialRequest
	if json.NewDecoder(r.Body).Decode(&req) != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}
	if req.Plan != "starter" && req.Plan != "professional" && req.Plan != "enterprise" {
		http.Error(w, "Invalid plan", http.StatusBadRequest)
		return
	}
	fs, _, err := initFirebase(ctx)
	if err != nil {
		http.Error(w, "Service unavailable", http.StatusServiceUnavailable)
		return
	}
	defer fs.Close()
	user, err := fs.Collection("users").Doc(uid).Get(ctx)
	if err != nil || user.Data()["communityRole"] != "admin" || user.Data()["communityId"] != req.CommunityID {
		http.Error(w, "Forbidden", http.StatusForbidden)
		return
	}
	now := time.Now()
	_, err = fs.Collection("subscriptions").Doc(req.CommunityID).Create(ctx, map[string]interface{}{
		"plan": req.Plan, "status": "trial", "trialStartedAt": now, "trialEndsAt": now.AddDate(0, 0, 30), "createdAt": now, "createdBy": uid,
	})
	if err != nil {
		http.Error(w, "Trial already used", http.StatusConflict)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}

// BillSubscription — Scheduled mensual (Cloud Scheduler)
// Expira pruebas vencidas. La activación pagada solo puede ocurrir después de
// verificar una compra con Google Play en el backend.
func BillSubscription(ctx context.Context, e cloudevents.Event) error {
	fs, _, err := initFirebase(ctx)
	if err != nil {
		return err
	}
	defer fs.Close()

	now := time.Now()

	// Buscar únicamente pruebas; jamás convertirlas automáticamente en activas.
	iter := fs.Collection("subscriptions").
		Where("status", "==", "trial").
		Documents(ctx)
	defer iter.Stop()

	expired := 0
	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return err
		}

		data := doc.Data()
		trialEnds, ok := data["trialEndsAt"].(time.Time)
		if !ok || now.Before(trialEnds) {
			continue
		}
		if _, err = doc.Ref.Update(ctx, []firestore.Update{{Path: "status", Value: "expired"}, {Path: "expiredAt", Value: now}}); err != nil {
			log.Printf("Error expiring subscription %s: %v", doc.Ref.ID, err)
			continue
		}
		expired++
	}

	if expired > 0 {
		log.Printf("BillSubscription: %d trials expired", expired)
	}
	return nil
}
