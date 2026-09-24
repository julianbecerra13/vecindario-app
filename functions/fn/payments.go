package fn

import (
	"context"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"strconv"
	"strings"
	"time"

	"cloud.google.com/go/firestore"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"google.golang.org/api/iterator"
)

func init() {
	functions.HTTP("WompiWebhook", WompiWebhook)
	functions.HTTP("CreateWompiTransaction", CreateWompiTransaction)
}

// ==================== WOMPI PAYMENT GATEWAY ====================

// WompiEvent estructura del webhook de Wompi
type WompiEvent struct {
	Event     string    `json:"event"`
	Data      WompiData `json:"data"`
	Timestamp int64     `json:"timestamp"`
	Signature struct {
		Checksum   string   `json:"checksum"`
		Properties []string `json:"properties"`
	} `json:"signature"`
}

type WompiData struct {
	Transaction WompiTransaction `json:"transaction"`
}

type WompiTransaction struct {
	ID                string `json:"id"`
	Status            string `json:"status"`
	Reference         string `json:"reference"`
	AmountInCents     int64  `json:"amount_in_cents"`
	Currency          string `json:"currency"`
	PaymentMethodType string `json:"payment_method_type"`
	FinalizedAt       string `json:"finalized_at"`
}

// WompiWebhook — Recibe webhooks de Wompi cuando una transacción cambia de estado
func WompiWebhook(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	body, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Invalid body", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	var event WompiEvent
	if err := json.Unmarshal(body, &event); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	// Verificar firma del webhook. Wompi arma el checksum navegando data por las
	// rutas de signature.properties, así que necesitamos data como mapa dinámico.
	secret := os.Getenv("WOMPI_EVENTS_SECRET")
	if secret == "" {
		log.Print("WOMPI_EVENTS_SECRET no está configurado")
		http.Error(w, "Payment not configured", http.StatusServiceUnavailable)
		return
	}
	var payload struct {
		Data map[string]interface{} `json:"data"`
	}
	_ = json.Unmarshal(body, &payload)
	if !verifyWompiSignature(event, payload.Data, secret) {
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

func verifyWompiSignature(event WompiEvent, data map[string]interface{}, secret string) bool {
	// Wompi concatena, en el orden de properties, cada valor apuntado por su ruta,
	// luego el timestamp y por último el secreto de eventos; sobre eso aplica SHA256.
	var sb strings.Builder
	for _, prop := range event.Signature.Properties {
		sb.WriteString(resolveSignatureValue(data, prop))
	}
	sb.WriteString(strconv.FormatInt(event.Timestamp, 10))
	sb.WriteString(secret)

	sum := sha256.Sum256([]byte(sb.String()))
	expected := hex.EncodeToString(sum[:])

	// Wompi manda el checksum en mayúsculas; comparamos sin distinguir caso.
	return subtle.ConstantTimeCompare(
		[]byte(strings.ToLower(expected)),
		[]byte(strings.ToLower(event.Signature.Checksum)),
	) == 1
}

// resolveSignatureValue navega data siguiendo una ruta con puntos
// (ej. "transaction.amount_in_cents") y devuelve el valor como string.
func resolveSignatureValue(data map[string]interface{}, path string) string {
	var current interface{} = data
	for _, key := range strings.Split(path, ".") {
		m, ok := current.(map[string]interface{})
		if !ok {
			return ""
		}
		current = m[key]
	}

	switch v := current.(type) {
	case string:
		return v
	case float64:
		// JSON decodifica los números como float64; los enteros (montos, etc.)
		// se serializan sin decimales.
		if v == float64(int64(v)) {
			return strconv.FormatInt(int64(v), 10)
		}
		return strconv.FormatFloat(v, 'f', -1, 64)
	case nil:
		return ""
	default:
		return fmt.Sprintf("%v", v)
	}
}

func handleApprovedPayment(ctx context.Context, fs *firestore.Client, ref string, tx WompiTransaction) error {
	// Guardar registro del pago
	_, _, err := fs.Collection("payments").Add(ctx, map[string]interface{}{
		"transactionId": tx.ID,
		"reference":     ref,
		"amountInCents": tx.AmountInCents,
		"currency":      tx.Currency,
		"status":        "approved",
		"paymentMethod": tx.PaymentMethodType,
		"wompiStatus":   tx.Status,
		"processedAt":   time.Now(),
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
	Reference     string `json:"reference"`
	Amount        int64  `json:"amount"`   // En pesos (no centavos)
	Currency      string `json:"currency"` // COP
	Description   string `json:"description"`
	RedirectURL   string `json:"redirect_url"`
	CustomerEmail string `json:"customer_email"`
}

// CreateWompiTransaction — Endpoint HTTP para crear una transacción de Wompi
func CreateWompiTransaction(w http.ResponseWriter, r *http.Request) {
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

	var clientReq CreatePaymentRequest
	if err := json.NewDecoder(r.Body).Decode(&clientReq); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	fs, _, err := initFirebase(ctx)
	if err != nil {
		http.Error(w, "Service unavailable", http.StatusServiceUnavailable)
		return
	}
	defer fs.Close()

	req, paymentType, err := authoritativePaymentRequest(ctx, fs, callerUID, clientReq.Reference)
	if err != nil {
		log.Printf("Pago rechazado para %s: %v", callerUID, err)
		http.Error(w, "Invalid payment reference", http.StatusBadRequest)
		return
	}

	existing, err := fs.Collection("payment_intents").Where("reference", "==", req.Reference).Limit(1).Documents(ctx).GetAll()
	if err != nil {
		http.Error(w, "Service unavailable", http.StatusServiceUnavailable)
		return
	}
	if len(existing) > 0 {
		http.Error(w, "Payment reference already used", http.StatusConflict)
		return
	}

	pubKey := os.Getenv("WOMPI_PUBLIC_KEY")
	integritySecret := os.Getenv("WOMPI_INTEGRITY_SECRET")
	if pubKey == "" || integritySecret == "" {
		http.Error(w, "Payment not configured", http.StatusServiceUnavailable)
		return
	}

	checkoutURL := buildWompiCheckoutURL(pubKey, req, integritySecret)
	if _, _, err := fs.Collection("payment_intents").Add(ctx, map[string]interface{}{
		"uid": callerUID, "reference": req.Reference, "amount": req.Amount,
		"amountInCents": req.Amount * 100, "currency": req.Currency,
		"type": paymentType, "status": "pending", "customerEmail": req.CustomerEmail,
		"checkoutURL": checkoutURL, "createdAt": time.Now(),
	}); err != nil {
		http.Error(w, "Service unavailable", http.StatusServiceUnavailable)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"checkout_url": checkoutURL,
	})
}

func authoritativePaymentRequest(ctx context.Context, fs *firestore.Client, uid, reference string) (CreatePaymentRequest, string, error) {
	parts := splitReference(reference)
	if len(parts) != 3 || parts[1] == "" {
		return CreatePaymentRequest{}, "", fmt.Errorf("invalid reference")
	}
	paymentType, resourceID := parts[0], parts[1]
	amount := int64(0)

	switch paymentType {
	case "order":
		doc, err := fs.Collection("orders").Doc(resourceID).Get(ctx)
		if err != nil || doc.Data()["buyerUid"] != uid {
			return CreatePaymentRequest{}, "", fmt.Errorf("order not owned")
		}
		amount = getInt64(doc.Data(), "total")
	case "fine":
		data, err := findOwnedCollectionGroupDocument(ctx, fs, "fines", resourceID, uid)
		if err != nil || data["status"] != "confirmed" {
			return CreatePaymentRequest{}, "", fmt.Errorf("fine not payable")
		}
		amount = getInt64(data, "amount")
	case "booking":
		data, err := findOwnedCollectionGroupDocument(ctx, fs, "bookings", resourceID, uid)
		if err != nil {
			return CreatePaymentRequest{}, "", fmt.Errorf("booking not owned")
		}
		amount = getInt64(data, "totalPaid")
	case "cuota":
		if resourceID != uid {
			return CreatePaymentRequest{}, "", fmt.Errorf("account statement not owned")
		}
		iter := fs.CollectionGroup("account_statements").Where("residentUid", "==", uid).Limit(1).Documents(ctx)
		doc, err := iter.Next()
		iter.Stop()
		if err != nil {
			return CreatePaymentRequest{}, "", fmt.Errorf("account statement unavailable")
		}
		amount = getInt64(doc.Data(), "balance")
	default:
		return CreatePaymentRequest{}, "", fmt.Errorf("unsupported payment type")
	}

	if amount <= 0 || amount > 100000000 {
		return CreatePaymentRequest{}, "", fmt.Errorf("invalid amount")
	}
	userDoc, err := fs.Collection("users").Doc(uid).Get(ctx)
	if err != nil {
		return CreatePaymentRequest{}, "", fmt.Errorf("user unavailable")
	}
	email, _ := userDoc.Data()["email"].(string)
	return CreatePaymentRequest{
		Reference: reference, Amount: amount, Currency: "COP", CustomerEmail: email,
	}, paymentType, nil
}

func findOwnedCollectionGroupDocument(ctx context.Context, fs *firestore.Client, collection, id, uid string) (map[string]interface{}, error) {
	iter := fs.CollectionGroup(collection).Where("residentUid", "==", uid).Documents(ctx)
	defer iter.Stop()
	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			return nil, fmt.Errorf("document not found")
		}
		if err != nil {
			return nil, err
		}
		if doc.Ref.ID == id {
			return doc.Data(), nil
		}
	}
}

// buildWompiCheckoutURL arma la URL del Web Checkout de Wompi. Cuando hay secreto
// de integridad, agrega signature:integrity = SHA256(reference + amount_in_cents +
// currency + secreto), que Wompi exige para checkouts con monto fijo.
func buildWompiCheckoutURL(pubKey string, req CreatePaymentRequest, integritySecret string) string {
	amountInCents := req.Amount * 100 // el request llega en pesos

	params := url.Values{}
	params.Set("public-key", pubKey)
	params.Set("currency", req.Currency)
	params.Set("amount-in-cents", strconv.FormatInt(amountInCents, 10))
	params.Set("reference", req.Reference)
	if req.RedirectURL != "" {
		params.Set("redirect-url", req.RedirectURL)
	}

	checkoutURL := "https://checkout.wompi.co/p/?" + params.Encode()

	// La firma va con dos puntos literales en la clave, así que se anexa a mano
	// para que url.Values no los codifique.
	if integritySecret != "" {
		raw := fmt.Sprintf("%s%d%s%s", req.Reference, amountInCents, req.Currency, integritySecret)
		sum := sha256.Sum256([]byte(raw))
		checkoutURL += "&signature:integrity=" + hex.EncodeToString(sum[:])
	}

	return checkoutURL
}
