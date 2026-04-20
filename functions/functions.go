package functions

import (
	"context"
	"net/http"

	cloudevents "github.com/cloudevents/sdk-go/v2"
	"github.com/vecindario/functions/fn"
)

// Handlers HTTP exportados para Cloud Functions Gen2 (modo declarativo).
// Cada símbolo corresponde a un entry-point deployable con:
//   gcloud functions deploy <name> --entry-point=<name> --source=./functions

// --- Residentes ---
func ApproveResident(w http.ResponseWriter, r *http.Request)   { fn.ApproveResident(w, r) }
func RejectResident(w http.ResponseWriter, r *http.Request)    { fn.RejectResident(w, r) }
func RotateInviteCode(w http.ResponseWriter, r *http.Request)  { fn.RotateInviteCode(w, r) }

// --- Pedidos / Tiendas ---
func CreateOrder(w http.ResponseWriter, r *http.Request) { fn.CreateOrder(w, r) }

// --- Multas ---
func CreateFine(w http.ResponseWriter, r *http.Request) { fn.CreateFine(w, r) }

// --- Amenidades ---
func BookAmenity(w http.ResponseWriter, r *http.Request)    { fn.BookAmenity(w, r) }
func RefundDeposit(w http.ResponseWriter, r *http.Request)  { fn.RefundDeposit(w, r) }

// --- Asambleas ---
func CreateAssemblyVote(w http.ResponseWriter, r *http.Request) { fn.CreateAssemblyVote(w, r) }

// --- Finanzas ---
func ProcessAdminFee(w http.ResponseWriter, r *http.Request)         { fn.ProcessAdminFee(w, r) }
func GenerateFinancialReport(w http.ResponseWriter, r *http.Request) { fn.GenerateFinancialReport(w, r) }

// --- Circulares ---
func SendCircular(w http.ResponseWriter, r *http.Request) { fn.SendCircular(w, r) }

// --- Pagos Wompi ---
func WompiWebhook(w http.ResponseWriter, r *http.Request)            { fn.WompiWebhook(w, r) }
func CreateWompiTransaction(w http.ResponseWriter, r *http.Request)  { fn.CreateWompiTransaction(w, r) }

// --- CloudEvent handlers (triggers Firestore/Storage/Pub-Sub) ---
func SendNotification(ctx context.Context, e cloudevents.Event) error    { return fn.SendNotification(ctx, e) }
func OnNewCircular(ctx context.Context, e cloudevents.Event) error       { return fn.OnNewCircular(ctx, e) }
func OnNewPost(ctx context.Context, e cloudevents.Event) error           { return fn.OnNewPost(ctx, e) }
func OnOrderStatusChange(ctx context.Context, e cloudevents.Event) error { return fn.OnOrderStatusChange(ctx, e) }
func OnNewPQRS(ctx context.Context, e cloudevents.Event) error           { return fn.OnNewPQRS(ctx, e) }
func BillSubscription(ctx context.Context, e cloudevents.Event) error    { return fn.BillSubscription(ctx, e) }
func AssignPQRS(ctx context.Context, e cloudevents.Event) error          { return fn.AssignPQRS(ctx, e) }
func ProcessAccountDeletion(ctx context.Context, e cloudevents.Event) error { return fn.ProcessAccountDeletion(ctx, e) }
func ProcessDataExport(ctx context.Context, e cloudevents.Event) error      { return fn.ProcessDataExport(ctx, e) }
func CalculateRatings(ctx context.Context, e cloudevents.Event) error       { return fn.CalculateRatings(ctx, e) }
func CleanupVerificationDocs(ctx context.Context, e cloudevents.Event) error { return fn.CleanupVerificationDocs(ctx, e) }
func ProcessImage(ctx context.Context, e cloudevents.Event) error            { return fn.ProcessImage(ctx, e) }
