package fn

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
)

func init() {
	functions.HTTP("CreateFine", CreateFine)
}

type CreateFineRequest struct {
	CommunityID    string   `json:"communityId"`
	UnitNumber     string   `json:"unitNumber"`
	ResidentUID    string   `json:"residentUid"`
	Amount         int64    `json:"amount"`
	Reason         string   `json:"reason"`
	ManualArticle  string   `json:"manualArticle"`
	EvidenceURLs   []string `json:"evidenceUrls"`
	DefenseDays    int      `json:"defenseDays"` // Días para descargo
}

// CreateFine — Registra multa, vincula artículo del manual, notifica al residente
func CreateFine(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	ctx := r.Context()
	callerUID, err := verifyAuthToken(ctx, r)
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	var req CreateFineRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	fs, msg, err := initFirebase(ctx)
	if err != nil {
		http.Error(w, "Internal error", http.StatusInternalServerError)
		return
	}
	defer fs.Close()

	// Verificar admin
	callerDoc, err := fs.Collection("users").Doc(callerUID).Get(ctx)
	if err != nil || callerDoc.Data()["role"] != "admin" {
		http.Error(w, "Forbidden", http.StatusForbidden)
		return
	}

	defenseDays := req.DefenseDays
	if defenseDays <= 0 {
		defenseDays = 5 // Default: 5 días hábiles
	}
	defenseDeadline := time.Now().Add(time.Duration(defenseDays) * 24 * time.Hour)

	fineData := map[string]interface{}{
		"unitNumber":      req.UnitNumber,
		"residentUid":     req.ResidentUID,
		"amount":          req.Amount,
		"reason":          req.Reason,
		"manualArticle":   req.ManualArticle,
		"evidenceURLs":    req.EvidenceURLs,
		"status":          "notified",
		"defenseText":     "",
		"defenseDeadline": defenseDeadline,
		"createdByUid":    callerUID,
		"createdAt":       time.Now(),
	}

	docRef, _, err := fs.Collection("communities").Doc(req.CommunityID).
		Collection("fines").Add(ctx, fineData)
	if err != nil {
		http.Error(w, "Error creating fine", http.StatusInternalServerError)
		return
	}

	// Notificar al residente
	if msg != nil && req.ResidentUID != "" {
		_ = sendPushToUser(ctx, fs, msg, req.ResidentUID,
			"Multa registrada",
			fmt.Sprintf("Se ha registrado una multa de $%d por: %s", req.Amount, req.Reason),
			fmt.Sprintf("/premium/fines/%s", docRef.ID),
		)
	}

	log.Printf("Fine %s created: community=%s unit=%s amount=%d", docRef.ID, req.CommunityID, req.UnitNumber, req.Amount)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"fineId": docRef.ID,
		"status": "notified",
	})
}
