package middleware

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"time"

	"cloud.google.com/go/firestore"
)

const (
	maxRequestsPerMinute = 10
	rateLimitCollection  = "rate_limits"
)

// RateLimiter verifica que un usuario no exceda el límite de peticiones
type RateLimiter struct {
	fs *firestore.Client
}

// NewRateLimiter crea un nuevo rate limiter
func NewRateLimiter(fs *firestore.Client) *RateLimiter {
	return &RateLimiter{fs: fs}
}

// Check verifica si el usuario puede hacer la petición
// Retorna true si está permitido, false si excedió el límite
func (rl *RateLimiter) Check(ctx context.Context, uid string) (bool, error) {
	if uid == "" {
		return false, fmt.Errorf("uid vacío")
	}

	now := time.Now()
	windowKey := fmt.Sprintf("%s_%d", uid, now.Unix()/60) // Ventana de 1 minuto

	ref := rl.fs.Collection(rateLimitCollection).Doc(windowKey)

	// Usar transacción para atomicidad
	var allowed bool
	err := rl.fs.RunTransaction(ctx, func(ctx context.Context, tx *firestore.Transaction) error {
		doc, err := tx.Get(ref)

		if err != nil {
			// Documento no existe, crear con count=1
			tx.Set(ref, map[string]interface{}{
				"uid":       uid,
				"count":     1,
				"window":    windowKey,
				"createdAt": now,
				"expiresAt": now.Add(2 * time.Minute), // TTL para cleanup
			})
			allowed = true
			return nil
		}

		count, _ := doc.Data()["count"].(int64)
		if count >= maxRequestsPerMinute {
			allowed = false
			return nil
		}

		tx.Update(ref, []firestore.Update{
			{Path: "count", Value: firestore.Increment(1)},
		})
		allowed = true
		return nil
	})

	if err != nil {
		log.Printf("Rate limit check error for %s: %v", uid, err)
		return true, err // En caso de error, permitir (fail-open)
	}

	return allowed, nil
}

// Middleware wraps un handler HTTP con rate limiting
func (rl *RateLimiter) Middleware(uid string, w http.ResponseWriter, r *http.Request) bool {
	allowed, err := rl.Check(r.Context(), uid)
	if err != nil {
		// Fail-open: si hay error en rate limit, dejar pasar
		return true
	}
	if !allowed {
		http.Error(w, "Rate limit exceeded. Max 10 requests per minute.", http.StatusTooManyRequests)
		return false
	}
	return true
}
