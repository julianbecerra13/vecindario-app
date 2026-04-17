package fn

import (
	"encoding/json"
	"log"
	"net/http"
	"time"

	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"google.golang.org/api/iterator"
)

func init() {
	functions.HTTP("ProcessAdminFee", processAdminFee)
	functions.HTTP("GenerateFinancialReport", generateFinancialReport)
}

type ProcessAdminFeeRequest struct {
	CommunityID string `json:"communityId"`
	Period      string `json:"period"` // YYYYMM
	Amount      int64  `json:"amount"`
}

// processAdminFee — Cobrar cuota de administración via Wompi, registrar en account_statements
func processAdminFee(w http.ResponseWriter, r *http.Request) {
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

	var req ProcessAdminFeeRequest
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

	// Generar referencia para Wompi
	reference := "cuota_" + callerUID + "_" + req.Period

	// Registrar intención de pago
	_, _, err = fs.Collection("payment_intents").Add(ctx, map[string]interface{}{
		"uid":         callerUID,
		"communityId": req.CommunityID,
		"type":        "cuota",
		"reference":   reference,
		"amount":      req.Amount,
		"period":      req.Period,
		"status":      "pending",
		"createdAt":   time.Now(),
	})
	if err != nil {
		http.Error(w, "Error creating payment intent", http.StatusInternalServerError)
		return
	}

	log.Printf("Admin fee payment initiated: uid=%s community=%s period=%s amount=%d",
		callerUID, req.CommunityID, req.Period, req.Amount)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"reference": reference,
		"amount":    req.Amount,
		"status":    "pending",
	})
}

// generateFinancialReport — Genera resumen financiero del mes
func generateFinancialReport(w http.ResponseWriter, r *http.Request) {
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

	communityID := r.URL.Query().Get("communityId")
	if communityID == "" {
		http.Error(w, "communityId required", http.StatusBadRequest)
		return
	}

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

	// Obtener movimientos financieros del mes actual
	now := time.Now()
	startOfMonth := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())

	iter := fs.Collection("communities").Doc(communityID).
		Collection("finances").
		Where("date", ">=", startOfMonth).
		Documents(ctx)
	defer iter.Stop()

	var totalIncome, totalExpenses int64
	incomeByCategory := map[string]int64{}
	expenseByCategory := map[string]int64{}

	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			break
		}
		data := doc.Data()
		entryType, _ := data["type"].(string)
		category, _ := data["category"].(string)
		amount := getInt64(data, "amount")

		if entryType == "income" {
			totalIncome += amount
			incomeByCategory[category] += amount
		} else {
			totalExpenses += amount
			expenseByCategory[category] += amount
		}
	}

	report := map[string]interface{}{
		"communityId":       communityID,
		"period":            now.Format("2006-01"),
		"totalIncome":       totalIncome,
		"totalExpenses":     totalExpenses,
		"balance":           totalIncome - totalExpenses,
		"incomeByCategory":  incomeByCategory,
		"expenseByCategory": expenseByCategory,
		"generatedAt":       now.Format(time.RFC3339),
		"generatedBy":       callerUID,
	}

	log.Printf("Financial report generated for community %s: income=%d expenses=%d",
		communityID, totalIncome, totalExpenses)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(report)
}
