package fn

import (
	"encoding/json"
	"log"
	"net/http"
	"time"

	"cloud.google.com/go/firestore"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
)

func init() {
	functions.HTTP("CreateAssemblyVote", CreateAssemblyVote)
}

type CreateAssemblyVoteRequest struct {
	CommunityID string `json:"communityId"`
	AssemblyID  string `json:"assemblyId"`
	VoteIndex   int    `json:"voteIndex"`
}

// CreateAssemblyVote — Abre votación en tiempo real
func CreateAssemblyVote(w http.ResponseWriter, r *http.Request) {
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

	var req CreateAssemblyVoteRequest
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

	// Activar la votación en la asamblea
	assemblyRef := fs.Collection("communities").Doc(req.CommunityID).
		Collection("assemblies").Doc(req.AssemblyID)

	_, err = assemblyRef.Update(ctx, []firestore.Update{
		{Path: "status", Value: "active"},
		{Path: "activeVoteIndex", Value: req.VoteIndex},
		{Path: "voteOpenedAt", Value: time.Now()},
	})
	if err != nil {
		http.Error(w, "Error opening vote", http.StatusInternalServerError)
		return
	}

	// Notificar a todos los asistentes
	if msg != nil {
		_ = sendPushToCommunity(ctx, fs, msg, req.CommunityID,
			"Votación abierta",
			"Se ha abierto una nueva votación en la asamblea. Emite tu voto ahora.",
			"/premium/assemblies",
			"assembly_vote",
		)
	}

	log.Printf("Vote opened: assembly=%s voteIndex=%d by=%s", req.AssemblyID, req.VoteIndex, callerUID)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "vote_opened"})
}
