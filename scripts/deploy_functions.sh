#!/bin/bash
set -e

PROJECT_ID="vecindario-app-a746b"
REGION="us-central1"
RUNTIME="go121"
SOURCE="./functions"

echo "=== Deploying Cloud Functions ==="

# HTTP Functions
HTTP_FUNCTIONS=(
  "ApproveResident"
  "RejectResident"
  "RotateInviteCode"
  "CreateOrder"
  "WompiWebhook"
  "CreateWompiTransaction"
  "SendCircular"
  "CreateFine"
  "BookAmenity"
  "RefundDeposit"
  "ProcessAdminFee"
  "GenerateFinancialReport"
  "CreateAssemblyVote"
)

for fn in "${HTTP_FUNCTIONS[@]}"; do
  echo "Deploying HTTP function: $fn"
  gcloud functions deploy "$fn" \
    --project="$PROJECT_ID" \
    --region="$REGION" \
    --runtime="$RUNTIME" \
    --trigger-http \
    --allow-unauthenticated \
    --source="$SOURCE" \
    --entry-point="$fn" \
    --memory=256MB \
    --timeout=60s
done

# Event-driven Functions (Cloud Events / Firestore triggers)
EVENT_FUNCTIONS=(
  "SendNotification"
  "OnNewCircular"
  "OnNewPost"
  "OnOrderStatusChange"
  "OnNewPQRS"
  "ProcessAccountDeletion"
  "ProcessDataExport"
  "CalculateRatings"
  "CleanupVerificationDocs"
  "AssignPQRS"
  "BillSubscription"
  "ProcessImage"
)

for fn in "${EVENT_FUNCTIONS[@]}"; do
  echo "Deploying Event function: $fn"
  gcloud functions deploy "$fn" \
    --project="$PROJECT_ID" \
    --region="$REGION" \
    --runtime="$RUNTIME" \
    --trigger-event-filters="type=google.cloud.firestore.document.v1.created" \
    --source="$SOURCE" \
    --entry-point="$fn" \
    --memory=256MB \
    --timeout=120s
done

echo "=== All Cloud Functions deployed ==="
