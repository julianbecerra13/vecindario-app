package fn

import (
	"context"
	"crypto/rand"
	"encoding/json"
	"fmt"
	"log"
	"math/big"
	"net/http"
	"time"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
)

func init() {
	functions.HTTP("ApproveResident", ApproveResident)
	functions.HTTP("RejectResident", RejectResident)
	functions.HTTP("RotateInviteCode", RotateInviteCode)
}

// ApproveResidentRequest — Payload para aprobar un residente
type ApproveResidentRequest struct {
	UID         string `json:"uid"`
	CommunityID string `json:"communityId"`
}

// ApproveResident — Cambia verified=true server-side, valida que quien llama sea admin
func ApproveResident(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	ctx := r.Context()

	// Verificar token JWT del admin que hace la solicitud
	callerUID, err := verifyAuthToken(ctx, r)
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	var req ApproveResidentRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	if req.UID == "" || req.CommunityID == "" {
		http.Error(w, "uid and communityId required", http.StatusBadRequest)
		return
	}

	fs, msg, err := initFirebase(ctx)
	if err != nil {
		log.Printf("Error init firebase: %v", err)
		http.Error(w, "Internal error", http.StatusInternalServerError)
		return
	}
	defer fs.Close()

	// Verificar que el caller sea admin de la comunidad
	callerDoc, err := fs.Collection("users").Doc(callerUID).Get(ctx)
	if err != nil {
		http.Error(w, "Caller not found", http.StatusForbidden)
		return
	}
	callerRole, _ := callerDoc.Data()["role"].(string)
	callerCommunity, _ := callerDoc.Data()["communityId"].(string)
	if callerRole != "admin" || callerCommunity != req.CommunityID {
		http.Error(w, "Only community admin can approve residents", http.StatusForbidden)
		return
	}

	// Aprobar al residente
	_, err = fs.Collection("users").Doc(req.UID).Update(ctx, []firestore.Update{
		{Path: "verified", Value: true},
		{Path: "verifiedAt", Value: time.Now()},
		{Path: "verifiedBy", Value: callerUID},
	})
	if err != nil {
		log.Printf("Error approving resident %s: %v", req.UID, err)
		http.Error(w, "Error approving resident", http.StatusInternalServerError)
		return
	}

	// Incrementar memberCount de la comunidad
	_, err = fs.Collection("communities").Doc(req.CommunityID).Update(ctx, []firestore.Update{
		{Path: "memberCount", Value: firestore.Increment(1)},
	})
	if err != nil {
		log.Printf("Error incrementing memberCount: %v", err)
	}

	// Notificar al residente aprobado
	if msg != nil {
		_ = sendPushToUser(ctx, fs, msg, req.UID,
			"Bienvenido a tu comunidad",
			"Tu solicitud de ingreso ha sido aprobada. Ya puedes acceder a todo el contenido.",
			"/feed",
		)
	}

	log.Printf("Resident %s approved by admin %s in community %s", req.UID, callerUID, req.CommunityID)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "approved"})
}

// RejectResident — Rechaza un residente pendiente
func RejectResident(w http.ResponseWriter, r *http.Request) {
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

	var req ApproveResidentRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	fs, _, err := initFirebase(ctx)
	if err != nil {
		http.Error(w, "Internal error", http.StatusInternalServerError)
		return
	}
	defer fs.Close()

	// Verificar admin
	callerDoc, err := fs.Collection("users").Doc(callerUID).Get(ctx)
	if err != nil {
		http.Error(w, "Caller not found", http.StatusForbidden)
		return
	}
	callerRole, _ := callerDoc.Data()["role"].(string)
	callerCommunity, _ := callerDoc.Data()["communityId"].(string)
	if callerRole != "admin" || callerCommunity != req.CommunityID {
		http.Error(w, "Forbidden", http.StatusForbidden)
		return
	}

	// Quitar communityId del usuario rechazado
	_, err = fs.Collection("users").Doc(req.UID).Update(ctx, []firestore.Update{
		{Path: "communityId", Value: nil},
		{Path: "tower", Value: nil},
		{Path: "apartment", Value: nil},
		{Path: "verified", Value: false},
	})
	if err != nil {
		http.Error(w, "Error rejecting resident", http.StatusInternalServerError)
		return
	}

	log.Printf("Resident %s rejected by admin %s", req.UID, callerUID)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "rejected"})
}

// RotateInviteCodeRequest — Payload para rotar código
type RotateInviteCodeRequest struct {
	CommunityID string `json:"communityId"`
}

// RotateInviteCode — Genera un nuevo código de invitación de 6 caracteres
func RotateInviteCode(w http.ResponseWriter, r *http.Request) {
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

	var req RotateInviteCodeRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	fs, _, err := initFirebase(ctx)
	if err != nil {
		http.Error(w, "Internal error", http.StatusInternalServerError)
		return
	}
	defer fs.Close()

	// Verificar admin
	callerDoc, err := fs.Collection("users").Doc(callerUID).Get(ctx)
	if err != nil {
		http.Error(w, "Forbidden", http.StatusForbidden)
		return
	}
	callerRole, _ := callerDoc.Data()["role"].(string)
	callerCommunity, _ := callerDoc.Data()["communityId"].(string)
	if callerRole != "admin" || callerCommunity != req.CommunityID {
		http.Error(w, "Forbidden", http.StatusForbidden)
		return
	}

	newCode := generateInviteCode(6)

	_, err = fs.Collection("communities").Doc(req.CommunityID).Update(ctx, []firestore.Update{
		{Path: "inviteCode", Value: newCode},
	})
	if err != nil {
		http.Error(w, "Error rotating code", http.StatusInternalServerError)
		return
	}

	log.Printf("Invite code rotated for community %s by admin %s", req.CommunityID, callerUID)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"status":  "ok",
		"newCode": newCode,
	})
}

// verifyAuthToken — Extrae y verifica el token JWT de Firebase del header Authorization
func verifyAuthToken(ctx context.Context, r *http.Request) (string, error) {
	authHeader := r.Header.Get("Authorization")
	if len(authHeader) < 8 || authHeader[:7] != "Bearer " {
		return "", fmt.Errorf("missing or invalid Authorization header")
	}
	idToken := authHeader[7:]

	app, err := firebase.NewApp(ctx, nil)
	if err != nil {
		return "", fmt.Errorf("firebase.NewApp: %v", err)
	}
	authClient, err := app.Auth(ctx)
	if err != nil {
		return "", fmt.Errorf("app.Auth: %v", err)
	}

	token, err := authClient.VerifyIDToken(ctx, idToken)
	if err != nil {
		return "", fmt.Errorf("verifyIDToken: %v", err)
	}
	return token.UID, nil
}

// Alias para que compile si auth se necesita en otro archivo
var _ = (*auth.Client)(nil)

// generateInviteCode — Genera código alfanumérico de N caracteres
func generateInviteCode(length int) string {
	const charset = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789" // Sin I,O,0,1 para evitar confusión
	code := make([]byte, length)
	for i := range code {
		n, _ := rand.Int(rand.Reader, big.NewInt(int64(len(charset))))
		code[i] = charset[n.Int64()]
	}
	return string(code)
}
