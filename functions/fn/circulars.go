package fn

import (
	"encoding/json"
	"log"
	"net/http"
	"time"

	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"github.com/vecindario/functions/internal/middleware"
)

func init() {
	functions.HTTP("SendCircular", SendCircular)
}

type SendCircularRequest struct {
	CommunityID string   `json:"communityId"`
	Title       string   `json:"title"`
	Body        string   `json:"body"`
	Priority    string   `json:"priority"` // urgent, info, requires_ack, informative
	Attachments []string `json:"attachments"`
	RequiresAck bool     `json:"requiresAck"`
}

// SendCircular — Crea circular, envía push a todos los residentes
func SendCircular(w http.ResponseWriter, r *http.Request) {
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

	var req SendCircularRequest
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

	// Rate limiting
	if !middleware.NewRateLimiter(fs).Middleware(callerUID, w, r) {
		return
	}

	// Verificar que sea admin de la comunidad
	callerDoc, err := fs.Collection("users").Doc(callerUID).Get(ctx)
	if err != nil || callerDoc.Data()["role"] != "admin" {
		http.Error(w, "Forbidden", http.StatusForbidden)
		return
	}

	// Crear circular en Firestore
	circularData := map[string]interface{}{
		"title":          req.Title,
		"body":           req.Body,
		"priority":       req.Priority,
		"attachmentURLs": req.Attachments,
		"authorUid":      callerUID,
		"requiresAck":    req.RequiresAck,
		"readBy":         []interface{}{},
		"ackBy":          []interface{}{},
		"createdAt":      time.Now(),
	}

	docRef, _, err := fs.Collection("communities").Doc(req.CommunityID).
		Collection("circulars").Add(ctx, circularData)
	if err != nil {
		http.Error(w, "Error creating circular", http.StatusInternalServerError)
		return
	}

	// Enviar push a toda la comunidad
	if msg != nil {
		title := "Nueva circular"
		if req.Priority == "urgent" {
			title = "URGENTE: " + req.Title
		} else {
			title = req.Title
		}
		_ = sendPushToCommunity(ctx, fs, msg, req.CommunityID,
			title, req.Body, "/premium/circulars", "circular")
	}

	log.Printf("Circular %s created in community %s by %s", docRef.ID, req.CommunityID, callerUID)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"circularId": docRef.ID,
		"status":     "sent",
	})
}
