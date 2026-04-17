package fn

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"testing"
)

func TestSplitReference_Order(t *testing.T) {
	ref := "order_abc123"
	parts := splitReference(ref)

	if len(parts) != 2 {
		t.Errorf("Expected 2 parts, got %d", len(parts))
	}
	if parts[0] != "order" {
		t.Errorf("Expected 'order', got '%s'", parts[0])
	}
	if parts[1] != "abc123" {
		t.Errorf("Expected 'abc123', got '%s'", parts[1])
	}
}

func TestSplitReference_Booking(t *testing.T) {
	ref := "booking_xyz789"
	parts := splitReference(ref)

	if len(parts) != 2 {
		t.Errorf("Expected 2 parts, got %d", len(parts))
	}
	if parts[0] != "booking" {
		t.Errorf("Expected 'booking', got '%s'", parts[0])
	}
	if parts[1] != "xyz789" {
		t.Errorf("Expected 'xyz789', got '%s'", parts[1])
	}
}

func TestSplitReference_Cuota(t *testing.T) {
	ref := "cuota_user123_202604"
	parts := splitReference(ref)

	if len(parts) != 3 {
		t.Errorf("Expected 3 parts, got %d", len(parts))
	}
	if parts[0] != "cuota" {
		t.Errorf("Expected 'cuota', got '%s'", parts[0])
	}
	if parts[1] != "user123" {
		t.Errorf("Expected 'user123', got '%s'", parts[1])
	}
	if parts[2] != "202604" {
		t.Errorf("Expected '202604', got '%s'", parts[2])
	}
}

func TestSplitReference_Fine(t *testing.T) {
	ref := "fine_fine-id-123"
	parts := splitReference(ref)

	if len(parts) != 2 {
		t.Errorf("Expected 2 parts, got %d", len(parts))
	}
	if parts[0] != "fine" {
		t.Errorf("Expected 'fine', got '%s'", parts[0])
	}
	if parts[1] != "fine-id-123" {
		t.Errorf("Expected 'fine-id-123', got '%s'", parts[1])
	}
}

func TestSplitReference_EmptyParts(t *testing.T) {
	ref := "order__invalid" // Double underscore creates empty part
	parts := splitReference(ref)

	// splitReference skips empty parts
	if len(parts) != 2 {
		t.Errorf("Expected 2 parts (skipping empty), got %d", len(parts))
	}
}

func TestSplitReference_NoUnderscore(t *testing.T) {
	ref := "simple"
	parts := splitReference(ref)

	if len(parts) != 1 {
		t.Errorf("Expected 1 part, got %d", len(parts))
	}
	if parts[0] != "simple" {
		t.Errorf("Expected 'simple', got '%s'", parts[0])
	}
}

func TestSplitReference_MultipleUnderscores(t *testing.T) {
	ref := "a_b_c_d_e"
	parts := splitReference(ref)

	if len(parts) != 5 {
		t.Errorf("Expected 5 parts, got %d", len(parts))
	}
	expected := []string{"a", "b", "c", "d", "e"}
	for i, part := range parts {
		if part != expected[i] {
			t.Errorf("Part %d: expected '%s', got '%s'", i, expected[i], part)
		}
	}
}

func TestVerifyWompiSignature_Valid(t *testing.T) {
	secret := "test-secret"

	// Create a WompiEvent
	event := WompiEvent{
		Event: "transaction.updated",
		Data: WompiData{
			Transaction: WompiTransaction{
				ID:            "evt_12345",
				Status:        "APPROVED",
				AmountInCents: 50000,
			},
		},
	}
	event.Signature.Properties = []string{"evt_12345", "APPROVED", "50000"}

	// Calculate expected signature
	tx := event.Data.Transaction
	data := fmt.Sprintf("%s%s%d%s", tx.ID, tx.Status, tx.AmountInCents, event.Signature.Properties)
	data += secret

	h := hmac.New(sha256.New, []byte(secret))
	h.Write([]byte(data))
	expectedChecksum := hex.EncodeToString(h.Sum(nil))
	event.Signature.Checksum = expectedChecksum

	// Test
	if !verifyWompiSignature(event, secret) {
		t.Error("Expected valid signature to be verified")
	}
}

func TestVerifyWompiSignature_Invalid(t *testing.T) {
	secret := "test-secret"

	event := WompiEvent{
		Event: "transaction.updated",
		Data: WompiData{
			Transaction: WompiTransaction{
				ID:            "evt_12345",
				Status:        "APPROVED",
				AmountInCents: 50000,
			},
		},
	}
	event.Signature.Properties = []string{"evt_12345", "APPROVED", "50000"}
	event.Signature.Checksum = "invalid-checksum-123456"

	// Test
	if verifyWompiSignature(event, secret) {
		t.Error("Expected invalid signature to not be verified")
	}
}

func TestVerifyWompiSignature_WrongSecret(t *testing.T) {
	secret := "test-secret"
	wrongSecret := "wrong-secret"

	event := WompiEvent{
		Event: "transaction.updated",
		Data: WompiData{
			Transaction: WompiTransaction{
				ID:            "evt_12345",
				Status:        "APPROVED",
				AmountInCents: 50000,
			},
		},
	}
	event.Signature.Properties = []string{"evt_12345", "APPROVED", "50000"}

	// Calculate signature with correct secret
	tx := event.Data.Transaction
	data := fmt.Sprintf("%s%s%d%s", tx.ID, tx.Status, tx.AmountInCents, event.Signature.Properties)
	data += secret

	h := hmac.New(sha256.New, []byte(secret))
	h.Write([]byte(data))
	event.Signature.Checksum = hex.EncodeToString(h.Sum(nil))

	// Test with wrong secret - should fail
	if verifyWompiSignature(event, wrongSecret) {
		t.Error("Expected signature verification to fail with wrong secret")
	}
}

func TestCentavosConversion(t *testing.T) {
	// Test: pesos * 100 = centavos
	tests := []struct {
		pesos     int64
		expected  int64
		name      string
	}{
		{50000, 5000000, "50,000 pesos"},
		{100, 10000, "100 pesos"},
		{1, 100, "1 peso"},
		{0, 0, "0 pesos"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			centavos := tt.pesos * 100
			if centavos != tt.expected {
				t.Errorf("Expected %d centavos, got %d", tt.expected, centavos)
			}
		})
	}
}
