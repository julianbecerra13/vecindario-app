package fn

import (
	"context"
	"log"

	"cloud.google.com/go/firestore"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"google.golang.org/api/iterator"
)

func init() {
	functions.CloudEvent("CalculateRatings", calculateRatings)
}

// calculateRatings — Trigger cuando se crea/actualiza una reseña
// Recalcula el promedio de rating del target (service, store, external_service)
func calculateRatings(ctx context.Context, e interface{}) error {
	fs, _, err := initFirebase(ctx)
	if err != nil {
		return err
	}
	defer fs.Close()

	// Recalcular ratings para services
	if err := recalcAllRatings(ctx, fs, "services"); err != nil {
		log.Printf("Error recalculando ratings de services: %v", err)
	}

	// Recalcular ratings para stores
	if err := recalcAllRatings(ctx, fs, "stores"); err != nil {
		log.Printf("Error recalculando ratings de stores: %v", err)
	}

	// Recalcular ratings para external_services
	if err := recalcAllRatings(ctx, fs, "external_services"); err != nil {
		log.Printf("Error recalculando ratings de external_services: %v", err)
	}

	return nil
}

func recalcAllRatings(ctx context.Context, fs *firestore.Client, collection string) error {
	// Obtener todos los documentos de la colección
	iter := fs.Collection(collection).Documents(ctx)
	defer iter.Stop()

	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return err
		}

		targetID := doc.Ref.ID

		// Contar y promediar las reseñas para este target
		reviewIter := fs.Collection("reviews").
			Where("targetId", "==", targetID).
			Documents(ctx)

		var totalRating float64
		var count int
		for {
			reviewDoc, err := reviewIter.Next()
			if err == iterator.Done {
				break
			}
			if err != nil {
				reviewIter.Stop()
				break
			}
			rating, ok := reviewDoc.Data()["rating"].(float64)
			if !ok {
				// Intentar con int64
				if r, ok := reviewDoc.Data()["rating"].(int64); ok {
					rating = float64(r)
				}
			}
			totalRating += rating
			count++
		}
		reviewIter.Stop()

		if count > 0 {
			avgRating := totalRating / float64(count)
			_, err := doc.Ref.Update(ctx, []firestore.Update{
				{Path: "rating", Value: avgRating},
				{Path: "reviewCount", Value: count},
			})
			if err != nil {
				log.Printf("Error actualizando rating de %s/%s: %v", collection, targetID, err)
			}
		}
	}
	return nil
}
