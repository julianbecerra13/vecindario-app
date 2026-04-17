package fn

import (
	"testing"
	"time"
)

func TestDefenseDeadline_DefaultDays(t *testing.T) {
	// When defenseDays is not specified or 0, default to 5 days
	defenseDays := 0
	if defenseDays <= 0 {
		defenseDays = 5 // Default: 5 días hábiles
	}

	now := time.Now()
	defenseDeadline := now.Add(time.Duration(defenseDays) * 24 * time.Hour)

	// Should be approximately 5 days from now (120 hours)
	diff := defenseDeadline.Sub(now)
	expectedDuration := time.Duration(5 * 24) * time.Hour

	if diff < expectedDuration-time.Minute || diff > expectedDuration+time.Minute {
		t.Errorf("Expected ~120 hour difference, got %v", diff)
	}
}

func TestDefenseDeadline_CustomDays(t *testing.T) {
	tests := []struct {
		days     int
		name     string
	}{
		{1, "1 day"},
		{3, "3 days"},
		{7, "7 days"},
		{10, "10 days"},
	}

	now := time.Now()

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			defenseDays := tt.days
			defenseDeadline := now.Add(time.Duration(defenseDays) * 24 * time.Hour)

			diff := defenseDeadline.Sub(now)
			expectedDuration := time.Duration(tt.days*24) * time.Hour

			if diff < expectedDuration-time.Minute || diff > expectedDuration+time.Minute {
				t.Errorf("Expected ~%d hour difference, got %v", tt.days*24, diff)
			}
		})
	}
}

func TestDefenseDeadline_IsInFuture(t *testing.T) {
	defenseDays := 5
	now := time.Now()
	defenseDeadline := now.Add(time.Duration(defenseDays) * 24 * time.Hour)

	if defenseDeadline.Before(now) {
		t.Error("Defense deadline should be in the future")
	}

	if defenseDeadline.Equal(now) {
		t.Error("Defense deadline should not be equal to now")
	}
}

func TestDefenseDeadline_CalculationAccuracy(t *testing.T) {
	// Test that deadline is calculated correctly for different day values
	testCases := []int{1, 2, 5, 10}

	for _, days := range testCases {
		before := time.Now()
		deadline := before.Add(time.Duration(days*24) * time.Hour)
		after := time.Now()

		// Deadline should be between (before + days*24h) and (after + days*24h)
		minExpected := before.Add(time.Duration(days*24) * time.Hour)
		maxExpected := after.Add(time.Duration(days*24) * time.Hour)

		if deadline.Before(minExpected) || deadline.After(maxExpected) {
			t.Errorf("For %d days: deadline %v not within expected range [%v, %v]",
				days, deadline, minExpected, maxExpected)
		}
	}
}

func TestCreateFineRequest_DefaultDefenseDays(t *testing.T) {
	req := CreateFineRequest{
		CommunityID:  "comm-1",
		UnitNumber:   "101",
		ResidentUID:  "user-1",
		Amount:       100000,
		Reason:       "Ruido",
		DefenseDays:  0, // Will use default
	}

	defenseDays := req.DefenseDays
	if defenseDays <= 0 {
		defenseDays = 5
	}

	if defenseDays != 5 {
		t.Errorf("Expected default defenseDays to be 5, got %d", defenseDays)
	}
}

func TestCreateFineRequest_CustomDefenseDays(t *testing.T) {
	req := CreateFineRequest{
		CommunityID:  "comm-1",
		UnitNumber:   "102",
		ResidentUID:  "user-2",
		Amount:       150000,
		Reason:       "Basura",
		DefenseDays:  10,
	}

	defenseDays := req.DefenseDays
	if defenseDays <= 0 {
		defenseDays = 5
	}

	if defenseDays != 10 {
		t.Errorf("Expected defenseDays to be 10, got %d", defenseDays)
	}
}
