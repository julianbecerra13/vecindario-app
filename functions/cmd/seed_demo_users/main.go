// Comando de un solo uso: crea una comunidad demo y 5 usuarios de prueba,
// uno por cada perfil/capacidad de la app, para poder iniciar sesión y
// comparar cómo se ve la app según el rol.
//
// Perfiles creados (todos con contraseña compartida, ver -password):
//
//	resident.demo@vecindario.test    -> communityRole=resident
//	admin.demo@vecindario.test       -> communityRole=admin (admin del conjunto demo)
//	superadmin.demo@vecindario.test  -> platformRole=super_admin (sin comunidad)
//	tienda.demo@vecindario.test      -> resident + dueño de una tienda (capacidad hasStore)
//	servicio.demo@vecindario.test    -> resident + ofrece un servicio (capacidad offersService)
//
// Es idempotente: si corre dos veces, reutiliza los usuarios/comunidad ya
// creados (busca por email / usa un ID de comunidad fijo) en vez de duplicar.
//
// Uso:
//
//	cd functions
//	go run ./cmd/seed_demo_users -project=<FIREBASE_PROJECT_ID>
package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"time"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"google.golang.org/api/iterator"
)

const demoCommunityID = "demo-conjunto-los-nogales"

type demoUser struct {
	email         string
	displayName   string
	phone         string
	communityRole string // "resident" | "admin" | ""
	platformRole  string // "super_admin" | ""
	tower         string
	apartment     string
}

func main() {
	projectID := flag.String("project", "", "ID del proyecto Firebase (requerido)")
	password := flag.String("password", "Demo1234!", "Contraseña compartida para los 5 usuarios demo")
	flag.Parse()

	if *projectID == "" {
		log.Fatal("uso: go run ./cmd/seed_demo_users -project=<FIREBASE_PROJECT_ID>")
	}

	ctx := context.Background()
	app, err := firebase.NewApp(ctx, &firebase.Config{ProjectID: *projectID})
	if err != nil {
		log.Fatalf("firebase.NewApp: %v", err)
	}

	authClient, err := app.Auth(ctx)
	if err != nil {
		log.Fatalf("app.Auth: %v", err)
	}

	fs, err := app.Firestore(ctx)
	if err != nil {
		log.Fatalf("app.Firestore: %v", err)
	}
	defer fs.Close()

	// --- 1. Comunidad demo (idempotente: ID fijo, Set sobreescribe) ---
	communityRef := fs.Collection("communities").Doc(demoCommunityID)
	if _, err := communityRef.Get(ctx); err != nil {
		_, err = communityRef.Set(ctx, map[string]interface{}{
			"name":        "Conjunto Los Nogales (Demo)",
			"address":     "Calle 123 # 45-67",
			"city":        "Bogotá",
			"estrato":     4,
			"adminUid":    "",
			"inviteCode":  "DEMO01",
			"memberCount": 0,
			"unitType":    "apartment",
			"createdAt":   time.Now(),
		})
		if err != nil {
			log.Fatalf("crear comunidad demo: %v", err)
		}
		fmt.Printf("Comunidad demo creada: %s\n", demoCommunityID)
	} else {
		fmt.Printf("Comunidad demo ya existía: %s\n", demoCommunityID)
	}

	users := []demoUser{
		{
			email:         "resident.demo@vecindario.test",
			displayName:   "Residente Demo",
			phone:         "3001112233",
			communityRole: "resident",
			tower:         "1",
			apartment:     "101",
		},
		{
			email:         "admin.demo@vecindario.test",
			displayName:   "Admin Demo",
			phone:         "3001112244",
			communityRole: "admin",
			tower:         "1",
			apartment:     "102",
		},
		{
			email:        "superadmin.demo@vecindario.test",
			displayName:  "Super Admin Demo",
			phone:        "3001112255",
			platformRole: "super_admin",
		},
		{
			email:         "tienda.demo@vecindario.test",
			displayName:   "Dueño de Tienda Demo",
			phone:         "3001112266",
			communityRole: "resident",
			tower:         "2",
			apartment:     "201",
		},
		{
			email:         "servicio.demo@vecindario.test",
			displayName:   "Prestador de Servicio Demo",
			phone:         "3001112277",
			communityRole: "resident",
			tower:         "2",
			apartment:     "202",
		},
	}

	uids := map[string]string{} // email -> uid
	memberCount := 0

	for _, u := range users {
		uid, err := ensureAuthUser(ctx, authClient, u.email, u.displayName, *password)
		if err != nil {
			log.Fatalf("crear usuario auth %s: %v", u.email, err)
		}
		uids[u.email] = uid

		data := map[string]interface{}{
			"displayName": u.displayName,
			"email":       u.email,
			"phone":       u.phone,
			"verified":    true,
			"createdAt":   time.Now(),
		}
		if u.communityRole != "" {
			data["communityId"] = demoCommunityID
			data["communityRole"] = u.communityRole
			data["tower"] = u.tower
			data["apartment"] = u.apartment
			memberCount++
		}
		if u.platformRole != "" {
			data["platformRole"] = u.platformRole
		}

		if _, err := fs.Collection("users").Doc(uid).Set(ctx, data, firestore.MergeAll); err != nil {
			log.Fatalf("escribir doc de usuario %s: %v", u.email, err)
		}
		fmt.Printf("Usuario listo: %-35s uid=%s\n", u.email, uid)
	}

	// --- Admin del conjunto: setear adminUid en la comunidad ---
	adminUID := uids["admin.demo@vecindario.test"]
	if _, err := communityRef.Set(ctx, map[string]interface{}{
		"adminUid":    adminUID,
		"memberCount": memberCount,
	}, firestore.MergeAll); err != nil {
		log.Fatalf("actualizar adminUid de la comunidad: %v", err)
	}

	// --- Capacidad hasStore: crear una tienda si no existe una para ese owner ---
	storeOwnerUID := uids["tienda.demo@vecindario.test"]
	if err := ensureSingleDoc(ctx, fs, "stores", "ownerUid", storeOwnerUID, map[string]interface{}{
		"ownerUid":     storeOwnerUID,
		"communityId":  demoCommunityID,
		"name":         "Panadería Demo",
		"description":  "Panadería de prueba para ver el panel de tienda",
		"deliveryTime": "15-25 min",
		"minOrder":     10000,
		"active":       true,
		"rating":       0,
		"orderCount":   0,
		"createdAt":    time.Now(),
	}); err != nil {
		log.Fatalf("crear tienda demo: %v", err)
	}
	fmt.Println("Tienda demo lista (capacidad hasStore)")

	// --- Capacidad offersService: crear un servicio si no existe uno para ese owner ---
	providerUID := uids["servicio.demo@vecindario.test"]
	if err := ensureSingleDoc(ctx, fs, "services", "ownerUid", providerUID, map[string]interface{}{
		"ownerUid":    providerUID,
		"communityId": demoCommunityID,
		"title":       "Plomería Demo",
		"description": "Servicio de prueba para ver el flujo de servicios ofrecidos",
		"category":    "hogar",
		"active":      true,
		"rating":      0,
		"ratingCount": 0,
		"orderCount":  0,
		"ownerName":   "Prestador de Servicio Demo",
		"createdAt":   time.Now(),
	}); err != nil {
		log.Fatalf("crear servicio demo: %v", err)
	}
	fmt.Println("Servicio demo listo (capacidad offersService)")

	fmt.Println("\n=== Listo ===")
	fmt.Printf("Contraseña compartida: %s\n\n", *password)
	fmt.Println("Perfiles para iniciar sesión:")
	fmt.Println("  Residente:            resident.demo@vecindario.test")
	fmt.Println("  Admin del conjunto:   admin.demo@vecindario.test")
	fmt.Println("  Super admin:          superadmin.demo@vecindario.test")
	fmt.Println("  Residente con tienda: tienda.demo@vecindario.test")
	fmt.Println("  Residente c/servicio: servicio.demo@vecindario.test")
}

// ensureAuthUser busca un usuario de Firebase Auth por email; si no existe,
// lo crea. Devuelve el UID en ambos casos (idempotente).
func ensureAuthUser(ctx context.Context, client *auth.Client, email, displayName, password string) (string, error) {
	existing, err := client.GetUserByEmail(ctx, email)
	if err == nil {
		return existing.UID, nil
	}
	if !auth.IsUserNotFound(err) {
		return "", err
	}
	params := (&auth.UserToCreate{}).
		Email(email).
		Password(password).
		DisplayName(displayName).
		EmailVerified(true)
	created, err := client.CreateUser(ctx, params)
	if err != nil {
		return "", err
	}
	return created.UID, nil
}

// ensureSingleDoc crea un documento en `collection` con `data` solo si no
// existe ya uno con `field` == `value` (evita duplicar tienda/servicio en
// reruns del script).
func ensureSingleDoc(ctx context.Context, fs *firestore.Client, collection, field, value string, data map[string]interface{}) error {
	iter := fs.Collection(collection).Where(field, "==", value).Limit(1).Documents(ctx)
	defer iter.Stop()
	_, err := iter.Next()
	if err == nil {
		return nil // ya existe
	}
	if err != iterator.Done {
		return err
	}
	_, _, err = fs.Collection(collection).Add(ctx, data)
	return err
}
