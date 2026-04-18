package fn

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"github.com/vecindario/functions/internal/middleware"
)

func init() {
	functions.HTTP("CreateOrder", CreateOrder)
}

// Tarifas de comisión por estrato
var serviceFeeByCOP = map[int]int64{
	1: 200,
	2: 200,
	3: 300,
	4: 350,
	5: 450,
	6: 500,
}

type OrderItem struct {
	ItemID   string `json:"itemId"`
	Name     string `json:"name"`
	Price    int64  `json:"price"`
	Quantity int    `json:"quantity"`
}

type CreateOrderRequest struct {
	StoreID string      `json:"storeId"`
	Items   []OrderItem `json:"items"`
}

// CreateOrder — Valida stock, calcula comisión según estrato, crea orden
func CreateOrder(w http.ResponseWriter, r *http.Request) {
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

	var req CreateOrderRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	if req.StoreID == "" || len(req.Items) == 0 {
		http.Error(w, "storeId and items required", http.StatusBadRequest)
		return
	}

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

	// Obtener datos del comprador
	buyerDoc, err := fs.Collection("users").Doc(callerUID).Get(ctx)
	if err != nil {
		http.Error(w, "User not found", http.StatusBadRequest)
		return
	}
	buyerData := buyerDoc.Data()
	communityID, _ := buyerData["communityId"].(string)
	verified, _ := buyerData["verified"].(bool)
	if !verified || communityID == "" {
		http.Error(w, "User not verified", http.StatusForbidden)
		return
	}

	// Obtener estrato de la comunidad para calcular comisión
	communityDoc, err := fs.Collection("communities").Doc(communityID).Get(ctx)
	if err != nil {
		http.Error(w, "Community not found", http.StatusBadRequest)
		return
	}
	estrato := int(getInt64(communityDoc.Data(), "estrato"))
	if estrato < 1 || estrato > 6 {
		estrato = 3 // Default
	}

	// Obtener datos de la tienda
	storeDoc, err := fs.Collection("stores").Doc(req.StoreID).Get(ctx)
	if err != nil {
		http.Error(w, "Store not found", http.StatusBadRequest)
		return
	}
	storeOwnerUID, _ := storeDoc.Data()["ownerUid"].(string)

	// Calcular subtotal
	var subtotal int64
	orderItems := make([]map[string]interface{}, len(req.Items))
	for i, item := range req.Items {
		itemTotal := item.Price * int64(item.Quantity)
		subtotal += itemTotal
		orderItems[i] = map[string]interface{}{
			"itemId":   item.ItemID,
			"name":     item.Name,
			"price":    item.Price,
			"quantity": item.Quantity,
			"total":    itemTotal,
		}
	}

	// Calcular comisión de servicio
	serviceFee := serviceFeeByCOP[estrato]
	total := subtotal + serviceFee

	// Crear orden
	orderData := map[string]interface{}{
		"storeId":       req.StoreID,
		"storeOwnerUid": storeOwnerUID,
		"buyerUid":      callerUID,
		"buyerName":     buyerData["displayName"],
		"items":         orderItems,
		"subtotal":      subtotal,
		"serviceFee":    serviceFee,
		"estrato":       estrato,
		"total":         total,
		"status":        "pending",
		"paymentMethod": "pending",
		"createdAt":     time.Now(),
		"updatedAt":     time.Now(),
	}

	docRef, _, err := fs.Collection("orders").Add(ctx, orderData)
	if err != nil {
		http.Error(w, "Error creating order", http.StatusInternalServerError)
		return
	}

	// Notificar a la tienda
	if msg != nil {
		_ = sendPushToUser(ctx, fs, msg, storeOwnerUID,
			"Nuevo pedido",
			fmt.Sprintf("Pedido de %s por $%d", buyerData["displayName"], total),
			fmt.Sprintf("/stores/order/%s", docRef.ID),
		)
	}

	log.Printf("Order %s created: buyer=%s store=%s total=%d fee=%d estrato=%d",
		docRef.ID, callerUID, req.StoreID, total, serviceFee, estrato)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"orderId":    docRef.ID,
		"subtotal":   subtotal,
		"serviceFee": serviceFee,
		"total":      total,
		"status":     "pending",
	})
}

// getInt64 helper para leer int de Firestore data
func getInt64(data map[string]interface{}, key string) int64 {
	if v, ok := data[key].(int64); ok {
		return v
	}
	if v, ok := data[key].(float64); ok {
		return int64(v)
	}
	return 0
}

// Ignorar import no usado
var _ = strings.Contains
