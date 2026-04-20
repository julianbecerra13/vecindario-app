package fn

import (
	"testing"
)

func TestGetInt64_FromInt64(t *testing.T) {
	data := map[string]interface{}{
		"estrato": int64(4),
	}
	result := getInt64(data, "estrato")
	if result != 4 {
		t.Errorf("Expected 4, got %d", result)
	}
}

func TestGetInt64_FromFloat64(t *testing.T) {
	// Firestore sometimes returns numbers as float64
	data := map[string]interface{}{
		"estrato": float64(3),
	}
	result := getInt64(data, "estrato")
	if result != 3 {
		t.Errorf("Expected 3, got %d", result)
	}
}

func TestGetInt64_MissingKey(t *testing.T) {
	data := map[string]interface{}{
		"name": "Test",
	}
	result := getInt64(data, "estrato")
	if result != 0 {
		t.Errorf("Expected 0 for missing key, got %d", result)
	}
}

func TestGetInt64_WrongType(t *testing.T) {
	data := map[string]interface{}{
		"estrato": "4", // String instead of number
	}
	result := getInt64(data, "estrato")
	if result != 0 {
		t.Errorf("Expected 0 for wrong type, got %d", result)
	}
}

func TestServiceFeeByEstrato(t *testing.T) {
	tests := []struct {
		estrato   int
		expected  int64
		name      string
	}{
		{1, 200, "Estrato 1"},
		{2, 200, "Estrato 2"},
		{3, 300, "Estrato 3"},
		{4, 350, "Estrato 4"},
		{5, 450, "Estrato 5"},
		{6, 500, "Estrato 6"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			fee, exists := serviceFeeByCOP[tt.estrato]
			if !exists {
				t.Errorf("Estrato %d not found in serviceFeeByCOP", tt.estrato)
			}
			if fee != tt.expected {
				t.Errorf("Estrato %d: expected %d, got %d", tt.estrato, tt.expected, fee)
			}
		})
	}
}

func TestServiceFeeByEstrato_InvalidEstrato(t *testing.T) {
	_, exists := serviceFeeByCOP[7]
	if exists {
		t.Error("Estrato 7 should not exist in serviceFeeByCOP")
	}
	_, exists = serviceFeeByCOP[0]
	if exists {
		t.Error("Estrato 0 should not exist in serviceFeeByCOP")
	}
}

func TestServiceFeeCalculation(t *testing.T) {
	// Test: subtotal + serviceFee = total
	subtotal := int64(50000)
	estrato := 4
	fee := serviceFeeByCOP[estrato]
	total := subtotal + fee

	expectedTotal := int64(50350)
	if total != expectedTotal {
		t.Errorf("Expected total %d, got %d", expectedTotal, total)
	}
}
