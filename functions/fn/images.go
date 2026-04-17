package fn

import (
	"bytes"
	"context"
	"fmt"
	"image"
	"image/jpeg"
	_ "image/png"
	"log"
	"path/filepath"
	"strings"

	"cloud.google.com/go/firestore"
	gcstorage "cloud.google.com/go/storage"
	cloudevents "github.com/cloudevents/sdk-go/v2"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"golang.org/x/image/draw"
)

const maxImageWidth = 1200

func init() {
	functions.CloudEvent("ProcessImage", processImage)
}

type storageEventData struct {
	Bucket      string `json:"bucket"`
	Name        string `json:"name"`
	ContentType string `json:"contentType"`
}

// processImage resize imágenes a máx 1200px y elimina EXIF re-encodeando como JPEG.
func processImage(ctx context.Context, e cloudevents.Event) error {
	var data storageEventData
	if err := e.DataAs(&data); err != nil {
		return fmt.Errorf("parse event: %v", err)
	}

	if data.Bucket == "" || data.Name == "" {
		return fmt.Errorf("event missing bucket or name")
	}

	if !isImageContentType(data.ContentType) {
		return nil
	}

	fs, _, err := initFirebase(ctx)
	if err != nil {
		return err
	}
	defer fs.Close()

	storageClient, err := gcstorage.NewClient(ctx)
	if err != nil {
		return fmt.Errorf("storage client: %v", err)
	}
	defer storageClient.Close()

	obj := storageClient.Bucket(data.Bucket).Object(data.Name)

	reader, err := obj.NewReader(ctx)
	if err != nil {
		return fmt.Errorf("read %s/%s: %v", data.Bucket, data.Name, err)
	}
	defer reader.Close()

	// Go no lee EXIF al decodificar, así que re-encodear como JPEG lo elimina
	img, _, err := image.Decode(reader)
	if err != nil {
		log.Printf("ProcessImage: decode error for %s: %v (skipping)", data.Name, err)
		return nil
	}

	resized := resizeIfNeeded(img)

	var buf bytes.Buffer
	if err := jpeg.Encode(&buf, resized, &jpeg.Options{Quality: 85}); err != nil {
		return fmt.Errorf("jpeg encode: %v", err)
	}

	writer := obj.NewWriter(ctx)
	writer.ContentType = "image/jpeg"
	if _, err := writer.Write(buf.Bytes()); err != nil {
		writer.Close()
		return fmt.Errorf("write image: %v", err)
	}
	if err := writer.Close(); err != nil {
		return fmt.Errorf("close writer: %v", err)
	}

	_, _, err = fs.Collection("audit_logs").Add(ctx, map[string]interface{}{
		"type":      "image_processed",
		"path":      data.Name,
		"context":   inferImageContext(data.Name),
		"sizeBytes": buf.Len(),
		"status":    "processed",
		"createdAt": firestore.ServerTimestamp,
	})
	if err != nil {
		log.Printf("ProcessImage: audit log error: %v", err)
	}

	log.Printf("ProcessImage: %s procesada (%d bytes)", data.Name, buf.Len())
	return nil
}

func resizeIfNeeded(img image.Image) image.Image {
	w := img.Bounds().Dx()
	if w <= maxImageWidth {
		return img
	}
	h := img.Bounds().Dy()
	newH := h * maxImageWidth / w
	dst := image.NewRGBA(image.Rect(0, 0, maxImageWidth, newH))
	draw.BiLinear.Scale(dst, dst.Bounds(), img, img.Bounds(), draw.Over, nil)
	return dst
}

func isImageContentType(ct string) bool {
	ct = strings.ToLower(ct)
	return strings.HasPrefix(ct, "image/jpeg") ||
		strings.HasPrefix(ct, "image/jpg") ||
		strings.HasPrefix(ct, "image/png") ||
		strings.HasPrefix(ct, "image/webp")
}

func inferImageContext(name string) string {
	parts := strings.Split(name, "/")
	if len(parts) >= 2 {
		return filepath.Join(parts[0], parts[1])
	}
	return "unknown"
}
