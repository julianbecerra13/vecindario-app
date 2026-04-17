package fn

import (
	"regexp"
	"testing"
)

func TestGenerateInviteCode_Length(t *testing.T) {
	code := generateInviteCode(6)
	if len(code) != 6 {
		t.Errorf("Expected length 6, got %d", len(code))
	}
}

func TestGenerateInviteCode_ValidCharset(t *testing.T) {
	// Charset usado: "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
	validPattern := regexp.MustCompile(`^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{6}$`)

	code := generateInviteCode(6)
	if !validPattern.MatchString(code) {
		t.Errorf("Code contains invalid characters: %s", code)
	}
}

func TestGenerateInviteCode_NoDuplicates(t *testing.T) {
	codes := make(map[string]bool)

	// Generar 100 códigos y verificar que no hay duplicados
	for i := 0; i < 100; i++ {
		code := generateInviteCode(6)
		if codes[code] {
			t.Errorf("Duplicate code generated: %s", code)
		}
		codes[code] = true
	}

	if len(codes) != 100 {
		t.Errorf("Expected 100 unique codes, got %d", len(codes))
	}
}

func TestGenerateInviteCode_DifferentLengths(t *testing.T) {
	for length := 1; length <= 10; length++ {
		code := generateInviteCode(length)
		if len(code) != length {
			t.Errorf("Expected length %d, got %d", length, len(code))
		}
	}
}
