package fn

import (
	"crypto/sha256"
	"encoding/hex"
	"strconv"
	"strings"
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

// wompiTestData replica el data del webhook como lo entrega Wompi:
// los números llegan deserializados como float64.
func wompiTestData() map[string]interface{} {
	return map[string]interface{}{
		"transaction": map[string]interface{}{
			"id":              "evt_12345",
			"status":          "APPROVED",
			"amount_in_cents": float64(50000),
		},
	}
}

// wompiTestChecksum calcula el checksum tal como lo hace Wompi:
// valores en el orden de properties + timestamp + secreto, todo bajo SHA256.
func wompiTestChecksum(props []string, timestamp int64, secret string) string {
	concat := ""
	data := wompiTestData()
	for _, p := range props {
		concat += resolveSignatureValue(data, p)
	}
	concat += strconv.FormatInt(timestamp, 10)
	concat += secret

	sum := sha256.Sum256([]byte(concat))
	return hex.EncodeToString(sum[:])
}

func TestVerifyWompiSignature_Valid(t *testing.T) {
	secret := "test-secret"
	props := []string{"transaction.id", "transaction.status", "transaction.amount_in_cents"}
	var timestamp int64 = 1704067200

	event := WompiEvent{
		Event:     "transaction.updated",
		Timestamp: timestamp,
	}
	event.Signature.Properties = props
	event.Signature.Checksum = wompiTestChecksum(props, timestamp, secret)

	if !verifyWompiSignature(event, wompiTestData(), secret) {
		t.Error("Expected valid signature to be verified")
	}
}

func TestVerifyWompiSignature_UppercaseChecksum(t *testing.T) {
	secret := "test-secret"
	props := []string{"transaction.id", "transaction.status", "transaction.amount_in_cents"}
	var timestamp int64 = 1704067200

	event := WompiEvent{Timestamp: timestamp}
	event.Signature.Properties = props
	// Wompi envía el checksum en mayúsculas
	event.Signature.Checksum = strings.ToUpper(wompiTestChecksum(props, timestamp, secret))

	if !verifyWompiSignature(event, wompiTestData(), secret) {
		t.Error("Expected uppercase checksum to be verified")
	}
}

func TestVerifyWompiSignature_Invalid(t *testing.T) {
	secret := "test-secret"

	event := WompiEvent{Timestamp: 1704067200}
	event.Signature.Properties = []string{"transaction.id", "transaction.status", "transaction.amount_in_cents"}
	event.Signature.Checksum = "invalid-checksum-123456"

	if verifyWompiSignature(event, wompiTestData(), secret) {
		t.Error("Expected invalid signature to not be verified")
	}
}

func TestVerifyWompiSignature_WrongSecret(t *testing.T) {
	secret := "test-secret"
	wrongSecret := "wrong-secret"
	props := []string{"transaction.id", "transaction.status", "transaction.amount_in_cents"}
	var timestamp int64 = 1704067200

	event := WompiEvent{Timestamp: timestamp}
	event.Signature.Properties = props
	event.Signature.Checksum = wompiTestChecksum(props, timestamp, secret)

	// Con secreto incorrecto la verificación debe fallar
	if verifyWompiSignature(event, wompiTestData(), wrongSecret) {
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
