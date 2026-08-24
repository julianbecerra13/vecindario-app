// Comando de un solo uso: migra el campo legado `role` de cada documento en
// la colección `users` al nuevo esquema communityRole/platformRole.
//
// Mapeo:
//   role == "super_admin"           -> platformRole = "super_admin", communityRole = "resident"
//   role == "admin"                 -> communityRole = "admin"
//   role in ("store_owner", "external", "resident", "") o ausente -> communityRole = "resident"
//
// El campo `role` se elimina del documento al terminar.
//
// Uso:
//   cd functions
//   go run ./cmd/migrate_roles -project=<FIREBASE_PROJECT_ID> [-dry-run]
package main

import (
	"context"
	"flag"
	"fmt"
	"log"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go/v4"
	"google.golang.org/api/iterator"
)

func main() {
	projectID := flag.String("project", "", "ID del proyecto Firebase (requerido)")
	dryRun := flag.Bool("dry-run", false, "Si es true, solo imprime los cambios sin escribirlos")
	flag.Parse()

	if *projectID == "" {
		log.Fatal("uso: go run ./cmd/migrate_roles -project=<FIREBASE_PROJECT_ID> [-dry-run]")
	}

	ctx := context.Background()
	app, err := firebase.NewApp(ctx, &firebase.Config{ProjectID: *projectID})
	if err != nil {
		log.Fatalf("firebase.NewApp: %v", err)
	}

	client, err := app.Firestore(ctx)
	if err != nil {
		log.Fatalf("app.Firestore: %v", err)
	}
	defer client.Close()

	iter := client.Collection("users").Documents(ctx)
	defer iter.Stop()

	migrated := 0
	skipped := 0

	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			log.Fatalf("iter.Next: %v", err)
		}

		legacyRole, hasLegacy := doc.Data()["role"].(string)
		if !hasLegacy {
			skipped++
			continue
		}

		update := map[string]interface{}{}
		switch legacyRole {
		case "super_admin":
			update["platformRole"] = "super_admin"
			update["communityRole"] = "resident"
		case "admin":
			update["communityRole"] = "admin"
		default: // "store_owner", "external", "resident", "" u otro valor
			update["communityRole"] = "resident"
		}

		fmt.Printf("uid=%s role=%q -> %+v (elimina 'role')\n", doc.Ref.ID, legacyRole, update)

		if *dryRun {
			migrated++
			continue
		}

		_, err = doc.Ref.Update(ctx, []firestore.Update{
			{Path: "communityRole", Value: update["communityRole"]},
			{Path: "role", Value: firestore.Delete},
		})
		if err != nil {
			log.Fatalf("update uid=%s: %v", doc.Ref.ID, err)
		}
		if platformRole, ok := update["platformRole"]; ok {
			_, err = doc.Ref.Update(ctx, []firestore.Update{
				{Path: "platformRole", Value: platformRole},
			})
			if err != nil {
				log.Fatalf("update platformRole uid=%s: %v", doc.Ref.ID, err)
			}
		}
		migrated++
	}

	fmt.Printf("\nListo. %d documentos migrados, %d sin campo 'role' legado (ya migrados u omitidos).\n", migrated, skipped)
	if *dryRun {
		fmt.Println("(dry-run: no se escribió nada)")
	}
}
