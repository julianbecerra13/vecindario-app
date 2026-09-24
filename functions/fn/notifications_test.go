package fn

import (
	"reflect"
	"testing"
)

func TestFirestoreSubjectParts(t *testing.T) {
	tests := []struct {
		name    string
		subject string
		want    []string
	}{
		{
			name:    "Eventarc subject",
			subject: "documents/communities/community-a/posts/post-a",
			want:    []string{"communities", "community-a", "posts", "post-a"},
		},
		{
			name:    "full resource subject",
			subject: "projects/p/databases/(default)/documents/orders/order-a",
			want:    []string{"orders", "order-a"},
		},
		{
			name:    "already relative",
			subject: "communities/community-a/pqrs/pqrs-a",
			want:    []string{"communities", "community-a", "pqrs", "pqrs-a"},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := firestoreSubjectParts(tt.subject); !reflect.DeepEqual(got, tt.want) {
				t.Fatalf("firestoreSubjectParts() = %v, want %v", got, tt.want)
			}
		})
	}
}
