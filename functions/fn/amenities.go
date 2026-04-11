package fn

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"cloud.google.com/go/firestore"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"google.golang.org/api/iterator"
)

func init() {
	functions.HTTP("BookAmenity", bookAmenity)
	functions.HTTP("RefundDeposit", refundDeposit)
}

type BookAmenityRequest struct {
	CommunityID string `json:"communityId"`
	AmenityID   string `json:"amenityId"`
	Date        string `json:"date"` // YYYY-MM-DD
	StartTime   string `json:"startTime"`
	EndTime     string `json:"endTime"`
}

// bookAmenity — Valida disponibilidad, crea reserva
func bookAmenity(w http.ResponseWriter, r *http.Request) {
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

	var req BookAmenityRequest
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

	// Verificar que el usuario esté verificado
	userDoc, err := fs.Collection("users").Doc(callerUID).Get(ctx)
	if err != nil {
		http.Error(w, "User not found", http.StatusBadRequest)
		return
	}
	verified, _ := userDoc.Data()["verified"].(bool)
	if !verified {
		http.Error(w, "User not verified", http.StatusForbidden)
		return
	}

	// Verificar disponibilidad (no hay otra reserva para esa fecha)
	bookingsRef := fs.Collection("communities").Doc(req.CommunityID).Collection("bookings")
	existing := bookingsRef.
		Where("amenityId", "==", req.AmenityID).
		Where("date", "==", req.Date).
		Where("status", "in", []interface{}{"confirmed", "pending"}).
		Documents(ctx)

	hasConflict := false
	for {
		_, err := existing.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			break
		}
		hasConflict = true
		break
	}
	existing.Stop()

	if hasConflict {
		http.Error(w, "Date already booked", http.StatusConflict)
		return
	}

	// Obtener tarifa de la amenidad
	amenityDoc, err := fs.Collection("communities").Doc(req.CommunityID).
		Collection("amenities").Doc(req.AmenityID).Get(ctx)
	if err != nil {
		http.Error(w, "Amenity not found", http.StatusBadRequest)
		return
	}
	hourlyRate := getInt64(amenityDoc.Data(), "hourlyRate")
	deposit := getInt64(amenityDoc.Data(), "deposit")

	totalPaid := hourlyRate + deposit

	// Crear reserva
	bookingData := map[string]interface{}{
		"amenityId":        req.AmenityID,
		"residentUid":      callerUID,
		"date":             req.Date,
		"startTime":        req.StartTime,
		"endTime":          req.EndTime,
		"totalPaid":        totalPaid,
		"depositPaid":      deposit,
		"depositRefunded":  false,
		"status":           "pending", // Cambia a confirmed tras pago
		"createdAt":        time.Now(),
	}

	docRef, _, err := bookingsRef.Add(ctx, bookingData)
	if err != nil {
		http.Error(w, "Error creating booking", http.StatusInternalServerError)
		return
	}

	// Generar referencia para Wompi
	reference := fmt.Sprintf("booking_%s", docRef.ID)

	log.Printf("Booking %s created: amenity=%s date=%s total=%d", docRef.ID, req.AmenityID, req.Date, totalPaid)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"bookingId":  docRef.ID,
		"reference":  reference,
		"totalPaid":  totalPaid,
		"deposit":    deposit,
		"hourlyRate": hourlyRate,
		"status":     "pending",
	})
}

type RefundDepositRequest struct {
	CommunityID string `json:"communityId"`
	BookingID   string `json:"bookingId"`
}

// refundDeposit — Admin aprueba devolución de depósito post-uso
func refundDeposit(w http.ResponseWriter, r *http.Request) {
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

	var req RefundDepositRequest
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
	if err != nil || callerDoc.Data()["role"] != "admin" {
		http.Error(w, "Forbidden", http.StatusForbidden)
		return
	}

	bookingRef := fs.Collection("communities").Doc(req.CommunityID).
		Collection("bookings").Doc(req.BookingID)

	_, err = bookingRef.Update(ctx, []firestore.Update{
		{Path: "depositRefunded", Value: true},
		{Path: "depositRefundedAt", Value: time.Now()},
		{Path: "depositRefundedBy", Value: callerUID},
		{Path: "status", Value: "completed"},
	})
	if err != nil {
		http.Error(w, "Error refunding deposit", http.StatusInternalServerError)
		return
	}

	log.Printf("Deposit refunded: booking=%s by=%s", req.BookingID, callerUID)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "refunded"})
}
