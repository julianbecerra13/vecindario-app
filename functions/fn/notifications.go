package fn

import (
	"context"
	"fmt"
	"log"
	"time"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"google.golang.org/api/iterator"
)

func init() {
	functions.CloudEvent("SendNotification", sendNotification)
	functions.CloudEvent("OnNewCircular", onNewCircular)
	functions.CloudEvent("OnNewPost", onNewPost)
	functions.CloudEvent("OnOrderStatusChange", onOrderStatusChange)
	functions.CloudEvent("OnNewPQRS", onNewPQRS)
}

// Estructura para notificaciones Firestore
type notification struct {
	UID       string            `firestore:"uid"`
	Type      string            `firestore:"type"`
	Title     string            `firestore:"title"`
	Body      string            `firestore:"body"`
	Route     string            `firestore:"route,omitempty"`
	Read      bool              `firestore:"read"`
	CreatedAt time.Time         `firestore:"createdAt"`
}

// initFirebase inicializa Firebase Admin SDK
func initFirebase(ctx context.Context) (*firestore.Client, *messaging.Client, error) {
	app, err := firebase.NewApp(ctx, nil)
	if err != nil {
		return nil, nil, fmt.Errorf("firebase.NewApp: %v", err)
	}
	fs, err := app.Firestore(ctx)
	if err != nil {
		return nil, nil, fmt.Errorf("app.Firestore: %v", err)
	}
	msg, err := app.Messaging(ctx)
	if err != nil {
		return nil, nil, fmt.Errorf("app.Messaging: %v", err)
	}
	return fs, msg, nil
}

// sendPushToUser envía push notification a un usuario por sus tokens FCM
func sendPushToUser(ctx context.Context, fs *firestore.Client, msg *messaging.Client, uid, title, body, route string) error {
	// Obtener tokens del usuario
	doc, err := fs.Collection("users").Doc(uid).Get(ctx)
	if err != nil {
		return fmt.Errorf("get user %s: %v", uid, err)
	}
	tokens, _ := doc.Data()["fcmTokens"].([]interface{})
	if len(tokens) == 0 {
		return nil
	}

	// Crear notificación en Firestore
	_, _, err = fs.Collection("users").Doc(uid).Collection("notifications").Add(ctx, notification{
		UID:       uid,
		Type:      "system",
		Title:     title,
		Body:      body,
		Route:     route,
		Read:      false,
		CreatedAt: time.Now(),
	})
	if err != nil {
		log.Printf("Error creando notificación en Firestore: %v", err)
	}

	// Enviar push a cada token
	for _, t := range tokens {
		token, ok := t.(string)
		if !ok || token == "" {
			continue
		}
		_, err := msg.Send(ctx, &messaging.Message{
			Token: token,
			Notification: &messaging.Notification{
				Title: title,
				Body:  body,
			},
			Data: map[string]string{
				"route": route,
				"type":  "notification",
			},
		})
		if err != nil {
			log.Printf("Error enviando push a token %s: %v", token[:20], err)
		}
	}
	return nil
}

// sendPushToCommunity envía notificación a todos los miembros de una comunidad
func sendPushToCommunity(ctx context.Context, fs *firestore.Client, msg *messaging.Client, communityID, title, body, route, notifType string) error {
	// Obtener todos los usuarios de la comunidad
	iter := fs.Collection("users").Where("communityId", "==", communityID).Where("verified", "==", true).Documents(ctx)
	defer iter.Stop()

	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return fmt.Errorf("iterating users: %v", err)
		}
		uid := doc.Ref.ID

		// Crear notificación en Firestore
		_, _, _ = fs.Collection("users").Doc(uid).Collection("notifications").Add(ctx, notification{
			UID:       uid,
			Type:      notifType,
			Title:     title,
			Body:      body,
			Route:     route,
			Read:      false,
			CreatedAt: time.Now(),
		})

		// Enviar push
		tokens, _ := doc.Data()["fcmTokens"].([]interface{})
		for _, t := range tokens {
			token, ok := t.(string)
			if !ok || token == "" {
				continue
			}
			_, _ = msg.Send(ctx, &messaging.Message{
				Token: token,
				Notification: &messaging.Notification{
					Title: title,
					Body:  body,
				},
				Data: map[string]string{
					"route": route,
					"type":  notifType,
				},
			})
		}
	}
	return nil
}

// sendNotification — Trigger genérico cuando se crea un doc en users/{uid}/notifications
func sendNotification(ctx context.Context, e interface{}) error {
	log.Println("SendNotification triggered")
	return nil
}

// onNewCircular — Trigger cuando se crea una circular nueva
func onNewCircular(ctx context.Context, e interface{}) error {
	log.Println("OnNewCircular triggered — notificar a toda la comunidad")
	return nil
}

// onNewPost — Trigger cuando se crea un post fijado
func onNewPost(ctx context.Context, e interface{}) error {
	log.Println("OnNewPost triggered")
	return nil
}

// onOrderStatusChange — Trigger cuando cambia el estado de un pedido
func onOrderStatusChange(ctx context.Context, e interface{}) error {
	log.Println("OnOrderStatusChange triggered")
	return nil
}

// onNewPQRS — Trigger cuando se crea un PQRS (notificar admin)
func onNewPQRS(ctx context.Context, e interface{}) error {
	log.Println("OnNewPQRS triggered — notificar admin")
	return nil
}
