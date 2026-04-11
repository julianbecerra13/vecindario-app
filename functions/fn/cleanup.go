package fn

import (
	"context"
	"log"
	"time"

	"cloud.google.com/go/firestore"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"google.golang.org/api/iterator"
)

func init() {
	functions.CloudEvent("CleanupVerificationDocs", cleanupVerificationDocs)
}

// cleanupVerificationDocs — Scheduled diario (Cloud Scheduler)
// Elimina documentos de verificación de Storage con más de 30 días tras aprobación
func cleanupVerificationDocs(ctx context.Context, e interface{}) error {
	fs, _, err := initFirebase(ctx)
	if err != nil {
		return err
	}
	defer fs.Close()

	cutoff := time.Now().Add(-30 * 24 * time.Hour)

	// Buscar usuarios aprobados hace más de 30 días que tengan verificationDocURL
	iter := fs.Collection("users").
		Where("verified", "==", true).
		Where("verifiedAt", "<", cutoff).
		Documents(ctx)
	defer iter.Stop()

	cleaned := 0
	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return err
		}

		docURL, _ := doc.Data()["verificationDocURL"].(string)
		if docURL == "" {
			continue
		}

		// Marcar como limpiado en Firestore (el archivo en Storage se elimina aparte)
		_, err = doc.Ref.Update(ctx, []firestore.Update{
			{Path: "verificationDocURL", Value: nil},
			{Path: "verificationDocCleanedAt", Value: time.Now()},
		})
		if err != nil {
			log.Printf("Error limpiando doc de verificación para %s: %v", doc.Ref.ID, err)
			continue
		}

		cleaned++
	}

	if cleaned > 0 {
		log.Printf("CleanupVerificationDocs: limpiados %d documentos", cleaned)
	}
	return nil
}
