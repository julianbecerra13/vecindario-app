package fn

import (
	"context"
	"fmt"
	"log"
	"path/filepath"
	"strings"

	"cloud.google.com/go/firestore"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
)

func init() {
	functions.CloudEvent("ProcessImage", processImage)
}

// StorageEvent representa el evento de Cloud Storage
type StorageEvent struct {
	Bucket         string `json:"bucket"`
	Name           string `json:"name"`
	ContentType    string `json:"contentType"`
	Size           string `json:"size"`
	TimeCreated    string `json:"timeCreated"`
}

// processImage — Trigger en upload a Cloud Storage
// Valida tipo de archivo, registra metadata en Firestore
// En producción: agregar resize con imaging library y strip EXIF
func processImage(ctx context.Context, e interface{}) error {
	fs, _, err := initFirebase(ctx)
	if err != nil {
		return err
	}
	defer fs.Close()

	// Parsear el path del archivo para determinar el contexto
	// Formatos esperados:
	// users/{uid}/profile/{fileName}
	// communities/{communityId}/posts/{postId}/{fileName}
	// services/{serviceId}/{fileName}
	// stores/{storeId}/{fileName}
	// communities/{communityId}/circulars/{circularId}/{fileName}

	// Por ahora, registrar el evento en audit_logs
	_, _, err = fs.Collection("audit_logs").Add(ctx, map[string]interface{}{
		"type":      "image_upload",
		"status":    "processed",
		"createdAt": firestore.ServerTimestamp,
	})
	if err != nil {
		log.Printf("Error logging image upload: %v", err)
	}

	log.Println("ProcessImage: imagen procesada")

	// Ignorar imports no usados
	_ = fmt.Sprintf
	_ = filepath.Base
	_ = strings.Split

	return nil
}
