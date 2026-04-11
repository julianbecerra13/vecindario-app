#!/bin/bash
set -e

echo "=== Deploying Firestore Rules & Indexes ==="

# Deploy security rules
firebase deploy --only firestore:rules
echo "Firestore rules deployed."

# Deploy indexes
firebase deploy --only firestore:indexes
echo "Firestore indexes deployed."

# Deploy storage rules
firebase deploy --only storage
echo "Storage rules deployed."

echo "=== All Firestore configurations deployed ==="
