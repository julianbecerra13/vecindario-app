package fn

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"time"

	"cloud.google.com/go/firestore"
	cloudstorage "cloud.google.com/go/storage"
	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	cloudevents "github.com/cloudevents/sdk-go/v2"
	"google.golang.org/api/iterator"
)

func init() {
	functions.CloudEvent("ProcessAccountDeletion", ProcessAccountDeletion)
	functions.CloudEvent("ProcessDataExport", ProcessDataExport)
}

// ProcessAccountDeletion — Ejecutar diariamente (Cloud Scheduler)
// Busca deletion_requests con status=pending y createdAt > 15 días
// Anonimiza posts, reseñas, pedidos y elimina datos personales
func ProcessAccountDeletion(ctx context.Context, e cloudevents.Event) error {
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
		if err := anonymizeOwnedResources(ctx, fs, uid); err != nil {
			log.Printf("Error anonimizando recursos propios: %v", err)
		}

		// 4. Eliminar datos personales del usuario
		if err := deleteUserData(ctx, fs, uid); err != nil {
			return fmt.Errorf("eliminando datos Firestore de %s: %w", uid, err)
		}
		if err := deleteUserStorage(ctx, uid); err != nil {
			return fmt.Errorf("eliminando Storage de %s: %w", uid, err)
		}
		if err := deleteAuthUser(ctx, uid); err != nil {
			return fmt.Errorf("eliminando Auth de %s: %w", uid, err)
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

func anonymizeOwnedResources(ctx context.Context, fs *firestore.Client, uid string) error {
	for _, collection := range []string{"services", "stores"} {
		iter := fs.Collection(collection).Where("ownerUid", "==", uid).Documents(ctx)
		batch := fs.Batch()
		count := 0
		for {
			doc, err := iter.Next()
			if err == iterator.Done {
				break
			}
			if err != nil {
				iter.Stop()
				return err
			}
			updates := []firestore.Update{{Path: "ownerUid", Value: "deleted"}, {Path: "active", Value: false}}
			if collection == "services" {
				updates = append(updates,
					firestore.Update{Path: "ownerName", Value: "Usuario eliminado"},
					firestore.Update{Path: "ownerPhotoURL", Value: nil},
				)
			}
			batch.Update(doc.Ref, updates)
			count++
			if count%400 == 0 {
				if _, err := batch.Commit(ctx); err != nil {
					iter.Stop()
					return err
				}
				batch = fs.Batch()
			}
		}
		iter.Stop()
		if count%400 != 0 {
			if _, err := batch.Commit(ctx); err != nil {
				return err
			}
		}
	}
	return nil
}

func storageBucketName() (string, error) {
	name := os.Getenv("FIREBASE_STORAGE_BUCKET")
	if name == "" {
		return "", fmt.Errorf("FIREBASE_STORAGE_BUCKET no configurado")
	}
	return name, nil
}

func deleteUserStorage(ctx context.Context, uid string) error {
	bucketName, err := storageBucketName()
	if err != nil {
		return err
	}
	client, err := cloudstorage.NewClient(ctx)
	if err != nil {
		return err
	}
	defer client.Close()

	bucket := client.Bucket(bucketName)
	for _, prefix := range []string{"users/" + uid + "/", "data-exports/" + uid + "/"} {
		iter := bucket.Objects(ctx, &cloudstorage.Query{Prefix: prefix})
		for {
			attrs, err := iter.Next()
			if err == iterator.Done {
				break
			}
			if err != nil {
				return err
			}
			if err := bucket.Object(attrs.Name).Delete(ctx); err != nil {
				return err
			}
		}
	}
	return nil
}

func deleteAuthUser(ctx context.Context, uid string) error {
	app, err := firebase.NewApp(ctx, nil)
	if err != nil {
		return err
	}
	client, err := app.Auth(ctx)
	if err != nil {
		return err
	}
	if err := client.DeleteUser(ctx, uid); err != nil && !auth.IsUserNotFound(err) {
		return err
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

// ProcessDataExport — Genera un JSON con todos los datos del usuario
// Trigger: Firestore onCreate en data_export_requests
func ProcessDataExport(ctx context.Context, e cloudevents.Event) error {
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

		storagePath, expiresAt, err := writeDataExport(ctx, uid, doc.Ref.ID, exportData)
		if err != nil {
			_, _ = doc.Ref.Update(ctx, []firestore.Update{
				{Path: "status", Value: "failed"},
				{Path: "error", Value: "No fue posible generar la exportación"},
				{Path: "failedAt", Value: time.Now()},
			})
			log.Printf("Error guardando exportación de %s: %v", uid, err)
			continue
		}

		// Marcar la solicitud como completada
		_, err = doc.Ref.Update(ctx, []firestore.Update{
			{Path: "status", Value: "completed"},
			{Path: "completedAt", Value: time.Now()},
			{Path: "storagePath", Value: storagePath},
			{Path: "expiresAt", Value: expiresAt},
		})
		if err != nil {
			log.Printf("Error updating export request: %v", err)
		}

		log.Printf("Data export completed for user: %s", uid)
	}
	return nil
}

func writeDataExport(ctx context.Context, uid, requestID string, data map[string]interface{}) (string, time.Time, error) {
	payload, err := json.MarshalIndent(data, "", "  ")
	if err != nil {
		return "", time.Time{}, err
	}
	bucketName, err := storageBucketName()
	if err != nil {
		return "", time.Time{}, err
	}
	client, err := cloudstorage.NewClient(ctx)
	if err != nil {
		return "", time.Time{}, err
	}
	defer client.Close()

	expiresAt := time.Now().Add(7 * 24 * time.Hour)
	path := fmt.Sprintf("data-exports/%s/%s.json", uid, requestID)
	writer := client.Bucket(bucketName).Object(path).NewWriter(ctx)
	writer.ContentType = "application/json"
	writer.CacheControl = "private, max-age=0, no-store"
	writer.Metadata = map[string]string{"expiresAt": expiresAt.Format(time.RFC3339)}
	if _, err := writer.Write(payload); err != nil {
		_ = writer.Close()
		return "", time.Time{}, err
	}
	if err := writer.Close(); err != nil {
		return "", time.Time{}, err
	}
	return path, expiresAt, nil
}
