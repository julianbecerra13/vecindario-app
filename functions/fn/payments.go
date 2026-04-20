package fn

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"cloud.google.com/go/firestore"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
)

func init() {
	functions.HTTP("WompiWebhook", WompiWebhook)
	functions.HTTP("CreateWompiTransaction", CreateWompiTransaction)
}

// ==================== WOMPI PAYMENT GATEWAY ====================

// WompiEvent estructura del webhook de Wompi
type WompiEvent struct {
	Event     string `json:"event"`
	Data      WompiData `json:"data"`
	Timestamp int64  `json:"timestamp"`
	Signature struct {
		Checksum   string   `json:"checksum"`
		Properties []string `json:"properties"`
	} `json:"signature"`
}

type WompiData struct {
	Transaction WompiTransaction `json:"transaction"`
}

type WompiTransaction struct {
	ID              string `json:"id"`
	Status          string `json:"status"`
	Reference       string `json:"reference"`
	AmountInCents   int64  `json:"amount_in_cents"`
	Currency        string `json:"currency"`
	PaymentMethodType string `json:"payment_method_type"`
	FinalizedAt     string `json:"finalized_at"`
}

// WompiWebhook — Recibe webhooks de Wompi cuando una transacción cambia de estado
func WompiWebhook(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var event WompiEvent
	if err := json.NewDecoder(r.Body).Decode(&event); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	// Verificar firma del webhook
	secret := os.Getenv("WOMPI_EVENTS_SECRET")
	if secret != "" && !verifyWompiSignature(event, secret) {
		http.Error(w, "Invalid signature", http.StatusUnauthorized)
		return
	}

	ctx := r.Context()
	fs, _, err := initFirebase(ctx)
	if err != nil {
		log.Printf("Error init firebase: %v", err)
		http.Error(w, "Internal error", http.StatusInternalServerError)
		return
	}
	defer fs.Close()

	tx := event.Data.Transaction
	ref := tx.Reference // Formato: "type_id" (ej: "order_abc123", "booking_xyz789", "cuota_uid_202604")

	log.Printf("Wompi webhook: %s status=%s ref=%s amount=%d", event.Event, tx.Status, ref, tx.AmountInCents)

	switch tx.Status {
	case "APPROVED":
		if err := handleApprovedPayment(ctx, fs, ref, tx); err != nil {
			log.Printf("Error handling approved payment: %v", err)
		}
	case "DECLINED", "ERROR", "VOIDED":
		if err := handleFailedPayment(ctx, fs, ref, tx); err != nil {
			log.Printf("Error handling failed payment: %v", err)
		}
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}

func verifyWompiSignature(event WompiEvent, secret string) bool {
	// Construir string de verificación según docs de Wompi
	tx := event.Data.Transaction
	data := fmt.Sprintf("%s%s%d%s", tx.ID, tx.Status, tx.AmountInCents, event.Signature.Properties)
	data += secret

	h := hmac.New(sha256.New, []byte(secret))
	h.Write([]byte(data))
	expected := hex.EncodeToString(h.Sum(nil))
	return hmac.Equal([]byte(expected), []byte(event.Signature.Checksum))
}

func handleApprovedPayment(ctx context.Context, fs *firestore.Client, ref string, tx WompiTransaction) error {
	// Guardar registro del pago
	_, _, err := fs.Collection("payments").Add(ctx, map[string]interface{}{
		"transactionId":   tx.ID,
		"reference":       ref,
		"amountInCents":   tx.AmountInCents,
		"currency":        tx.Currency,
		"status":          "approved",
		"paymentMethod":   tx.PaymentMethodType,
		"wompiStatus":     tx.Status,
		"processedAt":     time.Now(),
	})
	if err != nil {
		return fmt.Errorf("saving payment: %v", err)
	}

	// Según el tipo de referencia, actualizar el estado del recurso
	parts := splitReference(ref)
	switch parts[0] {
	case "order":
		if len(parts) > 1 {
			_, err := fs.Collection("orders").Doc(parts[1]).Update(ctx, []firestore.Update{
				{Path: "status", Value: "paid"},
				{Path: "paymentMethod", Value: tx.PaymentMethodType},
				{Path: "paymentTransactionId", Value: tx.ID},
				{Path: "updatedAt", Value: time.Now()},
			})
			if err != nil {
				log.Printf("Error updating order %s: %v", parts[1], err)
			}
		}
	case "booking":
		if len(parts) > 1 {
			_, err := fs.Collection("bookings").Doc(parts[1]).Update(ctx, []firestore.Update{
				{Path: "status", Value: "confirmed"},
				{Path: "paymentTransactionId", Value: tx.ID},
			})
			if err != nil {
				log.Printf("Error updating booking %s: %v", parts[1], err)
			}
		}
	case "cuota":
		// Formato: cuota_uid_YYYYMM
		if len(parts) >= 3 {
			uid := parts[1]
			period := parts[2]
			_, _, err := fs.Collection("payment_records").Add(ctx, map[string]interface{}{
				"uid":           uid,
				"type":          "cuota",
				"period":        period,
				"amountInCents": tx.AmountInCents,
				"transactionId": tx.ID,
				"paidAt":        time.Now(),
			})
			if err != nil {
				log.Printf("Error recording cuota payment: %v", err)
			}
		}
	case "fine":
		if len(parts) > 1 {
			// Las multas están en subcolecciones, buscar por ID
			fineID := parts[1]
			// Actualizar en todas las comunidades que tengan esta multa
			iter := fs.CollectionGroup("fines").Where("__name__", "==", fineID).Documents(ctx)
			for {
				doc, err := iter.Next()
				if err != nil {
					break
				}
				_, _ = doc.Ref.Update(ctx, []firestore.Update{
					{Path: "status", Value: "paid"},
					{Path: "paidAt", Value: time.Now()},
					{Path: "paymentTransactionId", Value: tx.ID},
				})
			}
			iter.Stop()
		}
	}

	return nil
}

func handleFailedPayment(ctx context.Context, fs *firestore.Client, ref string, tx WompiTransaction) error {
	_, _, err := fs.Collection("payments").Add(ctx, map[string]interface{}{
		"transactionId": tx.ID,
		"reference":     ref,
		"amountInCents": tx.AmountInCents,
		"status":        "failed",
		"wompiStatus":   tx.Status,
		"processedAt":   time.Now(),
	})
	return err
}

func splitReference(ref string) []string {
	parts := []string{}
	current := ""
	for _, c := range ref {
		if c == '_' {
			if current != "" {
				parts = append(parts, current)
				current = ""
			}
		} else {
			current += string(c)
		}
	}
	if current != "" {
		parts = append(parts, current)
	}
	return parts
}

// CreatePaymentRequest estructura para crear un pago
type CreatePaymentRequest struct {
	Reference   string `json:"reference"`
	Amount      int64  `json:"amount"`       // En pesos (no centavos)
	Currency    string `json:"currency"`      // COP
	Description string `json:"description"`
	RedirectURL string `json:"redirect_url"`
	CustomerEmail string `json:"customer_email"`
}

// CreateWompiTransaction — Endpoint HTTP para crear una transacción de Wompi
func CreateWompiTransaction(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req CreatePaymentRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	pubKey := os.Getenv("WOMPI_PUBLIC_KEY")
	if pubKey == "" {
		http.Error(w, "Payment not configured", http.StatusServiceUnavailable)
		return
	}

	// Construir URL de checkout de Wompi
	checkoutURL := fmt.Sprintf(
		"https://checkout.wompi.co/p/?public-key=%s&currency=%s&amount-in-cents=%d&reference=%s&redirect-url=%s",
		pubKey,
		req.Currency,
		req.Amount*100, // Convertir a centavos
		req.Reference,
		req.RedirectURL,
	)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"checkout_url": checkoutURL,
	})
}
