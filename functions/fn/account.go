package fn

import (
	"context"
	"fmt"
	"log"
	"time"

	"cloud.google.com/go/firestore"
	cloudevents "github.com/cloudevents/sdk-go/v2"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"google.golang.org/api/iterator"
)

func init() {
	functions.CloudEvent("ProcessAccountDeletion", processAccountDeletion)
	functions.CloudEvent("ProcessDataExport", processDataExport)
}

// processAccountDeletion — Ejecutar diariamente (Cloud Scheduler)
// Busca deletion_requests con status=pending y createdAt > 15 días
// Anonimiza posts, reseñas, pedidos y elimina datos personales
func processAccountDeletion(ctx context.Context, e cloudevents.Event) error {
	fs, _, err := initFirebase(ctx)
	if err != nil {
		return err
	}
	defer fs.Close()

	cutoff := time.Now().Add(-15 * 24 * time.Hour)

	iter := fs.Collection("deletion_requests").
		Where("status", "==", "pending").
		Where("requestedAt", "<", cutoff).
		Documents(ctx)
	defer iter.Stop()

	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return fmt.Errorf("iterating deletion requests: %v", err)
		}

		uid, _ := doc.Data()["uid"].(string)
		if uid == "" {
			continue
		}

		log.Printf("Procesando eliminación de cuenta: %s", uid)

		// 1. Anonimizar posts
		if err := anonymizeCollection(ctx, fs, "posts", "authorUid", uid); err != nil {
			log.Printf("Error anonimizando posts: %v", err)
		}

		// 2. Anonimizar reseñas
		if err := anonymizeCollection(ctx, fs, "reviews", "authorUid", uid); err != nil {
			log.Printf("Error anonimizando reviews: %v", err)
		}

		// 3. Nullificar pedidos
		if err := nullifyOrders(ctx, fs, uid); err != nil {
			log.Printf("Error nullificando orders: %v", err)
		}

		// 4. Eliminar datos personales del usuario
		if err := deleteUserData(ctx, fs, uid); err != nil {
			log.Printf("Error eliminando datos: %v", err)
		}

		// 5. Marcar solicitud como completada
		_, err = doc.Ref.Update(ctx, []firestore.Update{
			{Path: "status", Value: "completed"},
			{Path: "completedAt", Value: time.Now()},
		})
		if err != nil {
			log.Printf("Error actualizando deletion request: %v", err)
		}

		log.Printf("Cuenta %s eliminada exitosamente", uid)
	}
	return nil
}

func anonymizeCollection(ctx context.Context, fs *firestore.Client, collection, field, uid string) error {
	iter := fs.CollectionGroup(collection).Where(field, "==", uid).Documents(ctx)
	defer iter.Stop()

	batch := fs.Batch()
	count := 0
	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return err
		}
		batch.Update(doc.Ref, []firestore.Update{
			{Path: field, Value: "deleted"},
			{Path: "authorName", Value: "Usuario eliminado"},
			{Path: "authorPhotoURL", Value: ""},
		})
		count++
		if count%400 == 0 {
			if _, err := batch.Commit(ctx); err != nil {
				return err
			}
			batch = fs.Batch()
		}
	}
	if count%400 != 0 {
		if _, err := batch.Commit(ctx); err != nil {
			return err
		}
	}
	return nil
}

func nullifyOrders(ctx context.Context, fs *firestore.Client, uid string) error {
	iter := fs.Collection("orders").Where("buyerUid", "==", uid).Documents(ctx)
	defer iter.Stop()

	batch := fs.Batch()
	count := 0
	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return err
		}
		batch.Update(doc.Ref, []firestore.Update{
			{Path: "buyerUid", Value: nil},
			{Path: "buyerName", Value: "Usuario eliminado"},
		})
		count++
		if count%400 == 0 {
			if _, err := batch.Commit(ctx); err != nil {
				return err
			}
			batch = fs.Batch()
		}
	}
	if count%400 != 0 {
		if _, err := batch.Commit(ctx); err != nil {
			return err
		}
	}
	return nil
}

func deleteUserData(ctx context.Context, fs *firestore.Client, uid string) error {
	// Eliminar subcolecciones del usuario
	subCollections := []string{"notifications", "consents"}
	for _, sub := range subCollections {
		iter := fs.Collection("users").Doc(uid).Collection(sub).Documents(ctx)
		batch := fs.Batch()
		count := 0
		for {
			doc, err := iter.Next()
			if err == iterator.Done {
				break
			}
			if err != nil {
				return err
			}
			batch.Delete(doc.Ref)
			count++
			if count%400 == 0 {
				if _, err := batch.Commit(ctx); err != nil {
					return err
				}
				batch = fs.Batch()
			}
		}
		if count > 0 && count%400 != 0 {
			if _, err := batch.Commit(ctx); err != nil {
				return err
			}
		}
		iter.Stop()
	}

	// Eliminar el documento del usuario
	_, err := fs.Collection("users").Doc(uid).Delete(ctx)
	return err
}

// processDataExport — Genera un JSON con todos los datos del usuario
// Trigger: Firestore onCreate en data_export_requests
func processDataExport(ctx context.Context, e cloudevents.Event) error {
	fs, _, err := initFirebase(ctx)
	if err != nil {
		return err
	}
	defer fs.Close()

	// Buscar solicitudes pendientes
	iter := fs.Collection("data_export_requests").
		Where("status", "==", "pending").
		Documents(ctx)
	defer iter.Stop()

	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return err
		}

		uid, _ := doc.Data()["uid"].(string)
		if uid == "" {
			continue
		}

		log.Printf("Processing data export for user: %s", uid)

		// Recopilar todos los datos del usuario
		exportData := map[string]interface{}{
			"exportDate": time.Now().Format(time.RFC3339),
			"userId":     uid,
		}

		// 1. Datos del perfil
		userDoc, err := fs.Collection("users").Doc(uid).Get(ctx)
		if err == nil {
			exportData["profile"] = userDoc.Data()
		}

		// 2. Posts del usuario
		postsIter := fs.CollectionGroup("posts").Where("authorUid", "==", uid).Documents(ctx)
		var posts []map[string]interface{}
		for {
			postDoc, err := postsIter.Next()
			if err == iterator.Done {
				break
			}
			if err != nil {
				break
			}
			posts = append(posts, postDoc.Data())
		}
		postsIter.Stop()
		exportData["posts"] = posts

		// 3. Pedidos del usuario
		ordersIter := fs.Collection("orders").Where("buyerUid", "==", uid).Documents(ctx)
		var orders []map[string]interface{}
		for {
			orderDoc, err := ordersIter.Next()
			if err == iterator.Done {
				break
			}
			if err != nil {
				break
			}
			orders = append(orders, orderDoc.Data())
		}
		ordersIter.Stop()
		exportData["orders"] = orders

		// 4. Reseñas del usuario
		reviewsIter := fs.Collection("reviews").Where("authorUid", "==", uid).Documents(ctx)
		var reviews []map[string]interface{}
		for {
			reviewDoc, err := reviewsIter.Next()
			if err == iterator.Done {
				break
			}
			if err != nil {
				break
			}
			reviews = append(reviews, reviewDoc.Data())
		}
		reviewsIter.Stop()
		exportData["reviews"] = reviews

		// 5. Servicios del usuario
		servicesIter := fs.Collection("services").Where("ownerUid", "==", uid).Documents(ctx)
		var services []map[string]interface{}
		for {
			serviceDoc, err := servicesIter.Next()
			if err == iterator.Done {
				break
			}
			if err != nil {
				break
			}
			services = append(services, serviceDoc.Data())
		}
		servicesIter.Stop()
		exportData["services"] = services

		// 6. Notificaciones
		notifsIter := fs.Collection("users").Doc(uid).Collection("notifications").Documents(ctx)
		var notifs []map[string]interface{}
		for {
			notifDoc, err := notifsIter.Next()
			if err == iterator.Done {
				break
			}
			if err != nil {
				break
			}
			notifs = append(notifs, notifDoc.Data())
		}
		notifsIter.Stop()
		exportData["notifications"] = notifs

		// Guardar el JSON exportado en Firestore (colección temporal)
		_, _, err = fs.Collection("data_exports").Add(ctx, map[string]interface{}{
			"uid":      uid,
			"data":     exportData,
			"status":   "ready",
			"readyAt":  time.Now(),
		})
		if err != nil {
			log.Printf("Error saving export for %s: %v", uid, err)
			continue
		}

		// Marcar la solicitud como completada
		_, err = doc.Ref.Update(ctx, []firestore.Update{
			{Path: "status", Value: "completed"},
			{Path: "completedAt", Value: time.Now()},
		})
		if err != nil {
			log.Printf("Error updating export request: %v", err)
		}

		log.Printf("Data export completed for user: %s", uid)
	}
	return nil
}
