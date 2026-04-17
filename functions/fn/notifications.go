package fn

import (
	"context"
	"fmt"
	"log"
	"strings"
	"time"

	"cloud.google.com/go/firestore"
	cloudevents "github.com/cloudevents/sdk-go/v2"
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
func sendNotification(ctx context.Context, e cloudevents.Event) error {
	log.Println("SendNotification triggered")
	return nil
}

// onNewCircular — Trigger cuando se crea una circular nueva
func onNewCircular(ctx context.Context, e cloudevents.Event) error {
	fs, msg, err := initFirebase(ctx)
	if err != nil {
		return fmt.Errorf("initFirebase: %v", err)
	}
	defer fs.Close()

	// Parsear datos del evento
	var data map[string]interface{}
	if err := e.DataAs(&data); err != nil {
		return fmt.Errorf("DataAs: %v", err)
	}

	subject := e.Subject()
	documentID := subject[strings.LastIndex(subject, "/")+1:]
	pathParts := strings.Split(subject, "/")
	if len(pathParts) < 4 {
		return fmt.Errorf("invalid path")
	}
	communityID := pathParts[1]

	// Obtener la circular
	doc, err := fs.Collection("communities").Doc(communityID).Collection("circulars").Doc(documentID).Get(ctx)
	if err != nil {
		return fmt.Errorf("get circular: %v", err)
	}

	title := doc.Data()["title"].(string)
	description := doc.Data()["description"].(string)

	// Notificar a todos los miembros verificados de la comunidad
	iter := fs.Collection("users").Where("communityId", "==", communityID).Where("verified", "==", true).Documents(ctx)
	defer iter.Stop()

	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			log.Printf("Error iterando usuarios: %v", err)
			continue
		}
		uid := doc.Ref.ID
		sendPushToUser(ctx, fs, msg, uid, "Nueva Circular: "+title, description, "/premium/circulars")
	}

	return nil
}

// onNewPost — Trigger cuando se crea un post fijado
func onNewPost(ctx context.Context, e cloudevents.Event) error {
	fs, msg, err := initFirebase(ctx)
	if err != nil {
		return fmt.Errorf("initFirebase: %v", err)
	}
	defer fs.Close()

	pathParts := strings.Split(e.Subject(), "/")
	if len(pathParts) < 4 {
		return fmt.Errorf("invalid path")
	}
	communityID := pathParts[1]
	postID := pathParts[3]

	// Obtener el post
	doc, err := fs.Collection("communities").Doc(communityID).Collection("posts").Doc(postID).Get(ctx)
	if err != nil {
		return fmt.Errorf("get post: %v", err)
	}

	isPinned := doc.Data()["isPinned"].(bool)
	if !isPinned {
		return nil // Solo notificar si está fijado
	}

	title := doc.Data()["title"].(string)
	authorUID := doc.Data()["authorUid"].(string)

	// Obtener autor para nombre
	authorDoc, err := fs.Collection("users").Doc(authorUID).Get(ctx)
	if err != nil {
		authorUID = "Vecino"
	} else {
		authorUID = authorDoc.Data()["displayName"].(string)
	}

	// Notificar a todos los miembros verificados
	iter := fs.Collection("users").Where("communityId", "==", communityID).Where("verified", "==", true).Documents(ctx)
	defer iter.Stop()

	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			log.Printf("Error iterando usuarios: %v", err)
			continue
		}
		uid := doc.Ref.ID
		sendPushToUser(ctx, fs, msg, uid, "Post fijado de "+authorUID, title, "/feed/"+postID)
	}

	return nil
}

// onOrderStatusChange — Trigger cuando cambia el estado de un pedido
func onOrderStatusChange(ctx context.Context, e cloudevents.Event) error {
	fs, msg, err := initFirebase(ctx)
	if err != nil {
		return fmt.Errorf("initFirebase: %v", err)
	}
	defer fs.Close()

	pathParts := strings.Split(e.Subject(), "/")
	if len(pathParts) < 2 {
		return fmt.Errorf("invalid path")
	}
	orderID := pathParts[len(pathParts)-1]

	// Obtener la orden
	doc, err := fs.Collection("orders").Doc(orderID).Get(ctx)
	if err != nil {
		return fmt.Errorf("get order: %v", err)
	}

	buyerUID := doc.Data()["buyerUid"].(string)
	status := doc.Data()["status"].(string)

	var title, body string
	switch status {
	case "confirmed":
		title = "Pedido Confirmado"
		body = "Tu pedido ha sido confirmado"
	case "preparing":
		title = "Preparando tu Pedido"
		body = "Tu pedido está siendo preparado"
	case "ready":
		title = "Pedido Listo"
		body = "Tu pedido está listo para retirar"
	case "completed":
		title = "Pedido Completado"
		body = "Tu pedido ha sido entregado"
	case "cancelled":
		title = "Pedido Cancelado"
		body = "Tu pedido ha sido cancelado"
	default:
		return nil
	}

	return sendPushToUser(ctx, fs, msg, buyerUID, title, body, "/stores/orders")
}

// onNewPQRS — Trigger cuando se crea un PQRS (notificar admin)
func onNewPQRS(ctx context.Context, e cloudevents.Event) error {
	fs, msg, err := initFirebase(ctx)
	if err != nil {
		return fmt.Errorf("initFirebase: %v", err)
	}
	defer fs.Close()

	pathParts := strings.Split(e.Subject(), "/")
	if len(pathParts) < 4 {
		return fmt.Errorf("invalid path")
	}
	communityID := pathParts[1]
	pqrsID := pathParts[3]

	// Obtener el PQRS
	doc, err := fs.Collection("communities").Doc(communityID).Collection("pqrs").Doc(pqrsID).Get(ctx)
	if err != nil {
		return fmt.Errorf("get pqrs: %v", err)
	}

	title := doc.Data()["title"].(string)
	pqrsType := doc.Data()["type"].(string)

	// Notificar a todos los admins de la comunidad
	iter := fs.Collection("users").Where("communityId", "==", communityID).Where("role", "==", "admin").Documents(ctx)
	defer iter.Stop()

	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			log.Printf("Error iterando admins: %v", err)
			continue
		}
		uid := doc.Ref.ID
		sendPushToUser(ctx, fs, msg, uid, "Nuevo PQRS: "+pqrsType, title, "/premium/pqrs")
	}

	return nil
}
