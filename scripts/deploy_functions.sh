#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="vecindario-app-a746b"
REGION="us-central1"
FIRESTORE_LOCATION="${FIRESTORE_LOCATION:-nam5}"
STORAGE_LOCATION="${STORAGE_LOCATION:-us-central1}"
RUNTIME="go125"
SOURCE="./functions"
DATABASE="(default)"
STORAGE_BUCKET="vecindario-app-a746b.firebasestorage.app"

deploy_http() {
  local name="$1"
  gcloud functions deploy "$name" \
    --gen2 \
    --quiet \
    --project="$PROJECT_ID" \
    --region="$REGION" \
    --runtime="$RUNTIME" \
    --trigger-http \
    --allow-unauthenticated \
    --source="$SOURCE" \
    --entry-point="$name" \
    --update-env-vars="FIREBASE_STORAGE_BUCKET=$STORAGE_BUCKET" \
    --memory=256Mi \
    --timeout=60s
}

deploy_firestore() {
  local name="$1"
  local event_type="$2"
  local document_pattern="$3"
  gcloud functions deploy "$name" \
    --gen2 \
    --quiet \
    --project="$PROJECT_ID" \
    --region="$REGION" \
    --runtime="$RUNTIME" \
    --source="$SOURCE" \
    --entry-point="$name" \
    --update-env-vars="FIREBASE_STORAGE_BUCKET=$STORAGE_BUCKET" \
    --memory=256Mi \
    --timeout=120s \
    --trigger-location="$FIRESTORE_LOCATION" \
    --trigger-event-filters="type=$event_type" \
    --trigger-event-filters="database=$DATABASE" \
    --trigger-event-filters-path-pattern="document=$document_pattern" \
    --retry
}

deploy_scheduled() {
  local name="$1"
  local topic="$2"
  gcloud pubsub topics describe "$topic" --project="$PROJECT_ID" >/dev/null 2>&1 \
    || gcloud pubsub topics create "$topic" --project="$PROJECT_ID"
  gcloud functions deploy "$name" \
    --gen2 \
    --quiet \
    --project="$PROJECT_ID" \
    --region="$REGION" \
    --runtime="$RUNTIME" \
    --trigger-topic="$topic" \
    --source="$SOURCE" \
    --entry-point="$name" \
    --update-env-vars="FIREBASE_STORAGE_BUCKET=$STORAGE_BUCKET" \
    --memory=256Mi \
    --timeout=540s \
    --retry
}

for name in \
  ApproveResident RejectResident RotateInviteCode JoinCommunity CreateOrder StartSubscriptionTrial \
  WompiWebhook CreateWompiTransaction SendCircular CreateFine \
  BookAmenity RefundDeposit ProcessAdminFee GenerateFinancialReport \
  CreateAssemblyVote; do
  deploy_http "$name"
done

deploy_firestore OnNewCircular \
  google.cloud.firestore.document.v1.created \
  'communities/{communityId}/circulars/{circularId}'
deploy_firestore OnNewPost \
  google.cloud.firestore.document.v1.created \
  'communities/{communityId}/posts/{postId}'
deploy_firestore OnOrderStatusChange \
  google.cloud.firestore.document.v1.updated \
  'orders/{orderId}'
deploy_firestore OnNewPQRS \
  google.cloud.firestore.document.v1.created \
  'communities/{communityId}/pqrs/{pqrsId}'
deploy_firestore AssignPQRS \
  google.cloud.firestore.document.v1.created \
  'communities/{communityId}/pqrs/{pqrsId}'
deploy_firestore ProcessDataExport \
  google.cloud.firestore.document.v1.created \
  'data_export_requests/{requestId}'
deploy_firestore CalculateRatings \
  google.cloud.firestore.document.v1.written \
  'reviews/{reviewId}'

gcloud functions deploy ProcessImage \
  --gen2 \
  --quiet \
  --project="$PROJECT_ID" \
  --region="$REGION" \
  --runtime="$RUNTIME" \
  --source="$SOURCE" \
  --entry-point=ProcessImage \
  --update-env-vars="FIREBASE_STORAGE_BUCKET=$STORAGE_BUCKET" \
  --memory=512Mi \
  --timeout=120s \
  --trigger-location="$STORAGE_LOCATION" \
  --trigger-event-filters=type=google.cloud.storage.object.v1.finalized \
  --trigger-event-filters="bucket=$STORAGE_BUCKET" \
  --retry

deploy_scheduled ProcessAccountDeletion vecindario-account-deletion
deploy_scheduled CleanupVerificationDocs vecindario-verification-cleanup
deploy_scheduled BillSubscription vecindario-subscription-maintenance

upsert_scheduler() {
  local job="$1"
  local schedule="$2"
  local topic="$3"
  if gcloud scheduler jobs describe "$job" \
    --project="$PROJECT_ID" --location="$REGION" >/dev/null 2>&1; then
    gcloud scheduler jobs update pubsub "$job" \
      --project="$PROJECT_ID" \
      --location="$REGION" \
      --schedule="$schedule" \
      --time-zone="America/Bogota" \
      --topic="$topic" \
      --message-body='{}'
  else
    gcloud scheduler jobs create pubsub "$job" \
      --project="$PROJECT_ID" \
      --location="$REGION" \
      --schedule="$schedule" \
      --time-zone="America/Bogota" \
      --topic="$topic" \
      --message-body='{}'
  fi
}

upsert_scheduler vecindario-account-deletion '0 2 * * *' vecindario-account-deletion
upsert_scheduler vecindario-verification-cleanup '0 3 * * *' vecindario-verification-cleanup
upsert_scheduler vecindario-subscription-maintenance '0 4 * * *' vecindario-subscription-maintenance

echo "Cloud Functions y tareas programadas configuradas."
