# Preparación para Play Store Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Dejar `vecindario_app` en condiciones de subir un release firmado y conforme a políticas a Google Play (Android), cerrando bloqueantes de build, configuración real, permisos, seguridad de datos, observabilidad, el modelo de cobro de la suscripción premium y la migración i18n pendiente.

**Architecture:** Ocho fases independientes que se pueden ejecutar y mergear por separado (cada una deja la app en un estado mejor y compilable). No hay dependencias estrictas entre fases salvo donde se indique explícitamente en "Interfaces".

**Tech Stack:** Flutter 3.32+/Dart 3.8+, Riverpod, GoRouter, Freezed, Firebase (Auth/Firestore/Storage/FCM/RemoteConfig/Crashlytics), Cloud Functions en Go 1.25, Wompi, Google Play Billing (`in_app_purchase`).

## Global Constraints

- Imports absolutos `package:vecindario_app/...`, archivos en snake_case, clases en PascalCase, providers con sufijo `Provider`, repositories con sufijo `Repository`, modelos con sufijo `Model` (CLAUDE.md del repo).
- Sin comentarios largos ni bloques de documentación multilínea; comentarios cortos en español, consistentes con el resto del archivo.
- Sin rastros de herramientas de IA en código, comentarios, commits o docs.
- Wompi se mantiene exclusivamente para cobros de bienes/servicios físicos (cuotas, multas, pedidos de tienda, reservas) — no para desbloquear funciones dentro de la app.
- Cualquier cambio a `firestore.rules`/`storage.rules` debe seguir el patrón deny-by-default ya usado (`isAuthenticated()`, `isCommunityMember()`, etc. en `firestore.rules:6-37`).
- Verificar cada fase con: `flutter analyze`, `flutter test`, y `go test ./...` / `go build ./...` dentro de `functions/` cuando aplique.

---

## Fase 1 — Firma de release y build endurecido (Android)

### Task 1: Generar keystore de producción y cablearlo en Gradle

**Files:**
- Create: `android/key.properties` (NO versionado, agregar a `.gitignore`)
- Create: `android/app/upload-keystore.jks` (NO versionado)
- Modify: `android/app/build.gradle.kts:26-43`
- Modify: `.gitignore`

**Interfaces:**
- Produces: `signingConfigs.release` disponible para la Task 2 (minify) y para cualquier pipeline de CI que firme el AAB.

- [ ] **Step 1: Generar el keystore**

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Guardar el `.jks` generado y las contraseñas usadas en un gestor de contraseñas (1Password/Bitwarden). **Si se pierde este keystore no se podrá volver a publicar actualizaciones de la misma app en Play Store.**

- [ ] **Step 2: Crear `android/key.properties`**

```properties
storePassword=<password del keystore>
keyPassword=<password de la key>
keyAlias=upload
storeFile=upload-keystore.jks
```

- [ ] **Step 3: Agregar al `.gitignore`**

```gitignore
android/key.properties
android/app/upload-keystore.jks
android/app/*.jks
```

- [ ] **Step 4: Cablear el signing real en `android/app/build.gradle.kts`**

Reemplazar líneas 1-9 y 37-43:

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}
```

Y el bloque `android { ... }`:

```kotlin
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
```

- [ ] **Step 5: Verificar que compila y queda firmado**

```bash
flutter build appbundle --release
```

Expected: build exitoso; `unzip -p build/app/outputs/bundle/release/app-release.aab META-INF/*.RSA | keytool -printcert` NO debe mostrar el certificado debug (`CN=Android Debug`).

- [ ] **Step 6: Commit**

```bash
git add android/app/build.gradle.kts .gitignore
git commit -m "build(android): configurar firma de release real"
```

### Task 2: Habilitar minify/shrink + reglas ProGuard

**Files:**
- Create: `android/app/proguard-rules.pro`
- Modify: `android/app/build.gradle.kts` (bloque `buildTypes.release`)

**Interfaces:**
- Consumes: `signingConfigs.release` de la Task 1.

- [ ] **Step 1: Crear `android/app/proguard-rules.pro`**

```proguard
# Firebase / Play Core
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Modelos serializados por json_serializable/Freezed (evitar renombrar campos)
-keep class com.vecindario.vecindario_app.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
```

- [ ] **Step 2: Habilitar minify en `build.gradle.kts`**

```kotlin
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
```

- [ ] **Step 3: Verificar build y humo de la app**

```bash
flutter build appbundle --release
flutter install --release   # o instalar el APK equivalente en un emulador/dispositivo
```

Expected: la app abre, login funciona, no hay crash por clases removidas (`R8`). Si algo falla por ofuscación, añadir la regla `-keep` correspondiente en `proguard-rules.pro`.

- [ ] **Step 4: Commit**

```bash
git add android/app/build.gradle.kts android/app/proguard-rules.pro
git commit -m "build(android): habilitar minify y shrinkResources en release"
```

---

## Fase 2 — Configuración real de backend y pagos

### Task 3: Reemplazar `baseUrl` placeholder por el proyecto real

**Files:**
- Modify: `lib/core/constants/api_constants.dart:5`

**Interfaces:**
- Produces: `ApiConstants.baseUrl` consistente con `CloudFunctionsService._baseUrl` (`lib/shared/services/cloud_functions_service.dart:12-13`), que ya apunta al proyecto real `vecindario-app-a746b`.

- [ ] **Step 1: Editar el placeholder**

```dart
// Antes
static const baseUrl = 'https://us-central1-YOUR_PROJECT.cloudfunctions.net';

// Después
static const baseUrl = 'https://us-central1-vecindario-app-a746b.cloudfunctions.net';
```

- [ ] **Step 2: Verificar que no queden dos fuentes de verdad divergentes**

```bash
grep -rn "cloudfunctions.net" lib/
```

Expected: todas las referencias apuntan a `vecindario-app-a746b`. Si a futuro se quiere unificar `CloudFunctionsService` para leer de `ApiConstants.baseUrl` en vez de tener su propia constante, hacerlo en un commit separado (fuera de este plan, es refactor no bloqueante).

- [ ] **Step 3: `flutter analyze` y commit**

```bash
flutter analyze
git add lib/core/constants/api_constants.dart
git commit -m "fix(config): apuntar baseUrl de Cloud Functions al proyecto real"
```

### Task 4: Configurar Wompi de producción

**Files:**
- Modify: `lib/core/constants/api_constants.dart:15-16`

**Interfaces:**
- Consumes: llave pública real (`pub_prod_...`) que el usuario debe generar en el dashboard de Wompi (comercio productivo, no sandbox).

- [ ] **Step 1: Editar constantes**

```dart
// Wompi (producción)
static const wompiBaseUrl = 'https://production.wompi.co/v1';
static const wompiPublicKey = 'pub_prod_XXXXXXXXXXXXXXXXX'; // reemplazar con la key real del comercio
```

- [ ] **Step 2: Configurar en el backend Go el secreto de integridad de producción**

En la consola de Cloud Functions (o `.env` de despliegue), setear `WOMPI_INTEGRITY_SECRET` y `WOMPI_EVENTS_SECRET` de producción (ya consumidos por `functions/fn/payments.go` vía `os.Getenv`, ver `payments.go:77-126,310-338`).

- [ ] **Step 3: Verificar con una transacción de prueba en el ambiente de producción de Wompi (bajo monto) antes de publicar.**

- [ ] **Step 4: Commit**

```bash
git add lib/core/constants/api_constants.dart
git commit -m "fix(pagos): configurar Wompi de producción"
```

---

## Fase 3 — Permisos runtime declarados

### Task 5: Declarar permisos de cámara/galería en Android e iOS

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `ios/Runner/Info.plist`

**Interfaces:**
- Ninguna (solo manifest/plist, no afecta código Dart).

- [ ] **Step 1: Agregar permisos en `AndroidManifest.xml`** (antes de `<application ...>`, línea 2)

```xml
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    <!-- Compat con Android <= 12 -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
    <uses-feature android:name="android.hardware.camera" android:required="false"/>
```

- [ ] **Step 2: Agregar descripciones de uso en `ios/Runner/Info.plist`** (dentro del `<dict>` principal, antes de la línea 48 `</dict>`)

```xml
	<key>NSCameraUsageDescription</key>
	<string>Vecindario necesita acceso a la cámara para tomar fotos de tu perfil, publicaciones y servicios.</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>Vecindario necesita acceso a tus fotos para adjuntarlas a tu perfil, publicaciones y servicios.</string>
```

- [ ] **Step 3: Verificar en dispositivo/emulador real**

Ejecutar el flujo de "editar foto de perfil" (`lib/features/profile/screens/edit_profile_screen.dart`) en un emulador Android 13+ y en simulador iOS; confirmar que el diálogo de permiso aparece con el texto correcto y no hay crash.

- [ ] **Step 4: Commit**

```bash
git add android/app/src/main/AndroidManifest.xml ios/Runner/Info.plist
git commit -m "fix(permisos): declarar uso de cámara y galería en Android/iOS"
```

### Task 6: Quitar dependencia muerta `permission_handler`

**Files:**
- Modify: `pubspec.yaml:58`

**Interfaces:**
- Ninguna — confirmar primero que no se usa en ningún lado.

- [ ] **Step 1: Confirmar que no se usa**

```bash
grep -rn "permission_handler\|import 'package:permission_handler" lib/
```

Expected: sin resultados (fuera de `pubspec.yaml`).

- [ ] **Step 2: Eliminar la línea `permission_handler: ^11.3.1` de `pubspec.yaml`**

- [ ] **Step 3: Verificar**

```bash
flutter pub get
flutter analyze
```

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore(deps): remover permission_handler sin uso"
```

---

## Fase 4 — Seguridad: acotar `storage.rules` por comunidad

### Task 7: Restringir escritura de posts/servicios/tiendas a miembros de la comunidad dueña del recurso

**Files:**
- Modify: `storage.rules:18-37`

**Interfaces:**
- Consumes: el campo `communityId` que ya existe en los documentos Firestore `services/{serviceId}` y `stores/{storeId}` (confirmado en `lib/features/services/models/service_model.dart`), y la función `isCommunityMember` ya definida en `firestore.rules:18-20` (replicar la misma lógica vía `firestore.get(...)` porque Storage Rules no comparte funciones con Firestore Rules).

- [ ] **Step 1: Reescribir el bloque de posts/services/stores en `storage.rules`**

```javascript
    // Imagenes de posts: solo miembros de esa comunidad
    match /communities/{communityId}/posts/{postId}/{fileName} {
      allow write: if request.auth != null
        && firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.communityId == communityId
        && request.resource.size < 5 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }

    // Imagenes de servicios: solo miembros de la comunidad dueña del servicio
    match /services/{serviceId}/{fileName} {
      allow write: if request.auth != null
        && firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.communityId
           == firestore.get(/databases/(default)/documents/services/$(serviceId)).data.communityId
        && request.resource.size < 5 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }

    // Imagenes de tiendas y productos: solo miembros de la comunidad dueña de la tienda
    match /stores/{storeId}/{fileName} {
      allow write: if request.auth != null
        && firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.communityId
           == firestore.get(/databases/(default)/documents/stores/$(storeId)).data.communityId
        && request.resource.size < 5 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }
```

- [ ] **Step 2: Validar sintaxis y probar con el emulador**

```bash
firebase emulators:start --only firestore,storage
```

Escribir un caso manual (o script) que confirme: (a) un usuario de la comunidad A puede subir imagen a un servicio de la comunidad A, (b) un usuario de la comunidad B recibe `permission-denied` al intentar subir a ese mismo servicio.

- [ ] **Step 3: Desplegar y commit**

```bash
firebase deploy --only storage
git add storage.rules
git commit -m "fix(seguridad): acotar storage.rules por pertenencia a comunidad"
```

---

## Fase 5 — Observabilidad: Crashlytics y captura global de errores

### Task 8: Agregar Firebase Crashlytics

**Files:**
- Modify: `pubspec.yaml` (dependencies)
- Modify: `android/app/build.gradle.kts` (plugin)
- Modify: `android/build.gradle.kts` (classpath, si usa buildscript) — verificar el archivo real de plugins del proyecto (`android/settings.gradle.kts` en proyectos Flutter modernos declara plugins con versión)

**Interfaces:**
- Produces: `FirebaseCrashlytics.instance` disponible para la Task 9.

- [ ] **Step 1: Agregar dependencia**

```yaml
  firebase_crashlytics: ^4.1.0
```

- [ ] **Step 2: Agregar el plugin de Gradle**

En `android/settings.gradle.kts`, dentro del bloque `plugins`:

```kotlin
    id("com.google.firebase.crashlytics") version "3.0.2" apply false
```

En `android/app/build.gradle.kts`, junto a los demás `id(...)` (línea 4):

```kotlin
    id("com.google.firebase.crashlytics")
```

- [ ] **Step 3: `flutter pub get` y verificar build**

```bash
flutter pub get
flutter build apk --debug
```

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock android/settings.gradle.kts android/app/build.gradle.kts
git commit -m "feat(observabilidad): agregar Firebase Crashlytics"
```

### Task 9: Capturar errores no manejados globalmente

**Files:**
- Modify: `lib/main.dart:18-38`

**Interfaces:**
- Consumes: `firebase_crashlytics` de la Task 8.

- [ ] **Step 1: Envolver `main()` en `runZonedGuarded` y cablear Crashlytics**

```dart
import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// ...imports existentes...

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final remoteConfig = RemoteConfigService(FirebaseRemoteConfig.instance);
    await remoteConfig.initialize();

    timeago.setLocaleMessages('es', timeago.EsMessages());
    timeago.setDefaultLocale('es');
    await initializeDateFormatting('es', null);

    runApp(const ProviderScope(child: VecindarioApp()));
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}
```

- [ ] **Step 2: Verificar que reporta**

Forzar un `throw` de prueba en un botón temporal, correr en modo release/profile, confirmar en Firebase Console → Crashlytics que el evento llega (puede tardar unos minutos). Quitar el botón de prueba antes de continuar.

- [ ] **Step 3: `flutter test` (asegurar que los tests existentes no se rompieron por el cambio en `main.dart`) y commit**

```bash
flutter test
git add lib/main.dart
git commit -m "feat(observabilidad): capturar errores no manejados con Crashlytics"
```

---

## Fase 6 — Splash screen personalizado

### Task 10: Configurar `flutter_native_splash`

**Files:**
- Modify: `pubspec.yaml` (dev_dependencies + config)

**Interfaces:**
- Consumes: `assets/icons/app_icon.png` (ya existe, usado por `flutter_launcher_icons`, ver `pubspec.yaml:104`).

- [ ] **Step 1: Agregar dependencia y configuración**

```yaml
dev_dependencies:
  # ...existentes...
  flutter_native_splash: ^2.4.3

flutter_native_splash:
  color: "#3B82F6"
  image: assets/icons/app_icon_foreground.png
  android_12:
    color: "#3B82F6"
    image: assets/icons/app_icon_foreground.png
```

- [ ] **Step 2: Generar**

```bash
flutter pub get
dart run flutter_native_splash:create
```

- [ ] **Step 3: Verificar visualmente**

```bash
flutter run --release
```

Expected: splash con el color/logo de marca en vez del splash blanco default de Flutter, en el arranque frío.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml android/app/src/main/res ios/Runner/Assets.xcassets ios/Runner/Base.lproj
git commit -m "feat(ui): configurar splash screen de marca"
```

---

## Fase 7 — Migrar la suscripción premium a Google Play Billing

**Nota de alcance:** esta fase es un workstream grande por sí solo (nuevo endpoint Go, Play Console, cliente Dart). Se deja aquí como fase separada del plan para poder ejecutarla y revisarla de forma independiente del resto.

**Contexto actual:** `SubscriptionRepository.startTrial` (`lib/features/premium/subscriptions/repositories/subscription_repository.dart:32-57`) solo crea un trial de 30 días en Firestore. La función Go `BillSubscription` (`functions/fn/subscriptions.go`) es un cron mensual que genera `billing_records` con estado `pending` pero **no cobra nada realmente** — no hay pasarela de pago conectada al plan premium hoy. Vamos a reemplazar ese vacío con Google Play Billing en vez de conectarlo a Wompi, por la política de Play sobre features desbloqueadas dentro de la app.

### Task 11: Crear los productos de suscripción en Play Console (manual)

- [ ] **Step 1:** En Play Console → Monetización → Productos → Suscripciones, crear 3 suscripciones con estos IDs exactos (deben coincidir con la Task 13):
  - `vecindario_admin_starter` — $150.000 COP/mes
  - `vecindario_admin_professional` — $350.000 COP/mes
  - `vecindario_admin_enterprise` — $600.000 COP/mes
- [ ] **Step 2:** Habilitar la API de Android Publisher en Google Cloud Console para el proyecto `vecindario-app-a746b` y crear/asignar una cuenta de servicio con rol "Ver informes financieros" + "Gestionar pedidos y suscripciones" en Play Console (Configuración → Acceso a la API).
- [ ] **Step 3:** Descargar el JSON de la cuenta de servicio y configurarlo como credencial de las Cloud Functions (variable de entorno `GOOGLE_APPLICATION_CREDENTIALS` o Secret Manager) — necesario para la Task 12.

### Task 12: Cloud Function Go — verificar compra y activar suscripción

**Files:**
- Create: `functions/fn/subscription_billing.go`
- Create: `functions/fn/subscription_billing_test.go`

**Interfaces:**
- Consumes: `initFirebase` (`functions/fn/notifications.go:38`), `verifyAuthToken` (`functions/fn/residents.go:240-261`), paquete `google.golang.org/api/androidpublisher/v3` (ya disponible vía `google.golang.org/api v0.274.0` en `functions/go.mod`).
- Produces: endpoint HTTP `VerifyPlaySubscription`, consumido por la Task 14 (`BillingRepository` en Dart).

- [ ] **Step 1: Escribir el test de mapeo de producto → plan (unidad pura, sin red)**

```go
package fn

import "testing"

func TestPlanFromProductID(t *testing.T) {
	cases := map[string]string{
		"vecindario_admin_starter":      "starter",
		"vecindario_admin_professional": "professional",
		"vecindario_admin_enterprise":   "enterprise",
		"producto_desconocido":          "starter",
	}
	for productID, want := range cases {
		if got := planFromProductID(productID); got != want {
			t.Errorf("planFromProductID(%q) = %q, want %q", productID, got, want)
		}
	}
}
```

- [ ] **Step 2: Correr el test y confirmar que falla (función no existe aún)**

```bash
cd functions && go test ./fn/... -run TestPlanFromProductID -v
```

Expected: FAIL — `undefined: planFromProductID`.

- [ ] **Step 3: Implementar `functions/fn/subscription_billing.go`**

```go
package fn

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"time"

	"cloud.google.com/go/firestore"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"google.golang.org/api/androidpublisher/v3"
	"google.golang.org/api/option"
)

func init() {
	functions.HTTP("VerifyPlaySubscription", VerifyPlaySubscription)
}

const androidPackageName = "com.vecindario.vecindario_app"

type VerifyPlaySubscriptionRequest struct {
	CommunityID   string `json:"communityId"`
	ProductID     string `json:"productId"`
	PurchaseToken string `json:"purchaseToken"`
}

// planFromProductID mapea el ID de producto de Play Console al enum de plan usado en Firestore.
func planFromProductID(productID string) string {
	switch productID {
	case "vecindario_admin_professional":
		return "professional"
	case "vecindario_admin_enterprise":
		return "enterprise"
	default:
		return "starter"
	}
}

// VerifyPlaySubscription verifica un purchaseToken con la Android Publisher API
// (Subscriptions v2) y activa la suscripción de la comunidad si está vigente.
func VerifyPlaySubscription(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	ctx := r.Context()
	callerUID, err := verifyAuthToken(ctx, r)
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	var req VerifyPlaySubscriptionRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	if req.CommunityID == "" || req.ProductID == "" || req.PurchaseToken == "" {
		http.Error(w, "communityId, productId and purchaseToken required", http.StatusBadRequest)
		return
	}

	fs, _, err := initFirebase(ctx)
	if err != nil {
		log.Printf("Error init firebase: %v", err)
		http.Error(w, "Internal error", http.StatusInternalServerError)
		return
	}
	defer fs.Close()

	callerDoc, err := fs.Collection("users").Doc(callerUID).Get(ctx)
	if err != nil {
		http.Error(w, "Caller not found", http.StatusForbidden)
		return
	}
	callerRole, _ := callerDoc.Data()["role"].(string)
	callerCommunity, _ := callerDoc.Data()["communityId"].(string)
	if callerRole != "admin" || callerCommunity != req.CommunityID {
		http.Error(w, "Only community admin can activate subscription", http.StatusForbidden)
		return
	}

	pubClient, err := androidpublisher.NewService(ctx, option.WithScopes(androidpublisher.AndroidpublisherScope))
	if err != nil {
		log.Printf("Error creando cliente androidpublisher: %v", err)
		http.Error(w, "Internal error", http.StatusInternalServerError)
		return
	}

	// Subscriptions v2 API (recomendada por Google desde 2023).
	// Verificar el nombre exacto del recurso en la versión instalada del SDK
	// (google.golang.org/api/androidpublisher/v3) antes de desplegar.
	sub, err := pubClient.Purchases.Subscriptionsv2.Get(androidPackageName, req.PurchaseToken).Do()
	if err != nil {
		log.Printf("Error verificando compra %s: %v", req.PurchaseToken, err)
		http.Error(w, "Invalid purchase token", http.StatusBadRequest)
		return
	}
	if sub.SubscriptionState != "SUBSCRIPTION_STATE_ACTIVE" {
		http.Error(w, "Subscription not active", http.StatusBadRequest)
		return
	}

	now := time.Now()
	_, err = fs.Collection("subscriptions").Doc(req.CommunityID).Set(ctx, map[string]interface{}{
		"plan":              planFromProductID(req.ProductID),
		"status":            "active",
		"source":            "google_play",
		"playProductId":     req.ProductID,
		"playPurchaseToken": req.PurchaseToken,
		"activatedAt":       now,
		"createdBy":         callerUID,
	}, firestore.MergeAll)
	if err != nil {
		log.Printf("Error activando suscripción %s: %v", req.CommunityID, err)
		http.Error(w, "Error activating subscription", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}
```

- [ ] **Step 4: Correr el test y confirmar que pasa**

```bash
cd functions && go test ./fn/... -run TestPlanFromProductID -v
go build ./...
```

Expected: PASS, build limpio.

- [ ] **Step 5: Commit**

```bash
git add functions/fn/subscription_billing.go functions/fn/subscription_billing_test.go
git commit -m "feat(pagos): verificar suscripciones de Google Play server-side"
```

### Task 13: Actualizar `firestore.rules` para la nueva fuente de datos

**Files:**
- Modify: `firestore.rules:283-294`

**Interfaces:**
- Ninguna acción necesaria en `allow update, delete: if false;` (línea 294) — ya bloquea escritura de cliente en updates, y `VerifyPlaySubscription` escribe con el Admin SDK, que ignora las reglas. Solo se documenta el nuevo campo `source` para quien lea las reglas después.

- [ ] **Step 1: Agregar un comentario corto arriba de la regla existente (línea 283) documentando el nuevo flujo**

```javascript
    // --- Suscripciones ---
    // Admin de la comunidad puede crear el trial inicial (30 días).
    // Activación/renovación real la hace el backend (VerifyPlaySubscription
    // vía Google Play Billing), que usa Admin SDK y no pasa por estas reglas.
```

- [ ] **Step 2: Confirmar con el emulador que un cliente sigue sin poder hacer `update`/`delete` directo**

```bash
firebase emulators:start --only firestore
```

- [ ] **Step 3: Desplegar y commit**

```bash
firebase deploy --only firestore:rules
git add firestore.rules
git commit -m "docs(rules): documentar activación de suscripción vía Google Play Billing"
```

### Task 14: Cliente Dart — `BillingRepository` con `in_app_purchase`

**Files:**
- Create: `lib/features/premium/subscriptions/repositories/billing_repository.dart`
- Create: `test/features/premium/subscriptions/billing_repository_test.dart`
- Modify: `pubspec.yaml` (agregar `in_app_purchase`)
- Modify: `lib/shared/services/cloud_functions_service.dart` (agregar método `verifyPlaySubscription`)

**Interfaces:**
- Consumes: `CloudFunctionsService.callFunction` (`cloud_functions_service.dart:17-49`), endpoint `VerifyPlaySubscription` de la Task 12.
- Produces: `BillingRepository.productIdFor(SubscriptionPlan)`, `BillingRepository.buy(SubscriptionPlan)`, consumidos por la Task 15.

- [ ] **Step 1: Agregar dependencia**

```yaml
  in_app_purchase: ^3.2.3   # verificar última versión estable en pub.dev antes de instalar
```

- [ ] **Step 2: Escribir el test del mapeo plan→productId (unidad pura, sin plugin)**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/features/premium/subscriptions/models/subscription_model.dart';
import 'package:vecindario_app/features/premium/subscriptions/repositories/billing_repository.dart';

void main() {
  test('productIdFor mapea cada plan al ID correcto de Play Console', () {
    expect(BillingRepository.productIdFor(SubscriptionPlan.starter),
        'vecindario_admin_starter');
    expect(BillingRepository.productIdFor(SubscriptionPlan.professional),
        'vecindario_admin_professional');
    expect(BillingRepository.productIdFor(SubscriptionPlan.enterprise),
        'vecindario_admin_enterprise');
  });
}
```

- [ ] **Step 3: Correr el test y confirmar que falla**

```bash
flutter test test/features/premium/subscriptions/billing_repository_test.dart
```

Expected: FAIL — el archivo `billing_repository.dart` no existe.

- [ ] **Step 4: Agregar el método al servicio de Cloud Functions**

En `lib/shared/services/cloud_functions_service.dart`, junto a `createOrder` (línea 71-76):

```dart
  Future<Map<String, dynamic>> verifyPlaySubscription({
    required String communityId,
    required String productId,
    required String purchaseToken,
  }) {
    return callFunction('VerifyPlaySubscription', {
      'communityId': communityId,
      'productId': productId,
      'purchaseToken': purchaseToken,
    });
  }
```

- [ ] **Step 5: Implementar `billing_repository.dart`**

```dart
import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/utils/logger.dart';
import 'package:vecindario_app/features/premium/subscriptions/models/subscription_model.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';
import 'package:vecindario_app/shared/services/cloud_functions_service.dart';

class BillingRepository {
  final InAppPurchase _iap;
  final CloudFunctionsService _functions;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  BillingRepository(this._iap, this._functions);

  static String productIdFor(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.starter:
        return 'vecindario_admin_starter';
      case SubscriptionPlan.professional:
        return 'vecindario_admin_professional';
      case SubscriptionPlan.enterprise:
        return 'vecindario_admin_enterprise';
    }
  }

  void listenToPurchaseUpdates(String communityId) {
    _subscription = _iap.purchaseStream.listen((purchases) async {
      for (final purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          await _verifyAndActivate(communityId, purchase);
        }
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      }
    }, onError: (e) => AppLogger.error('Error en purchaseStream', e));
  }

  Future<void> buy(SubscriptionPlan plan) async {
    final productId = productIdFor(plan);
    final response = await _iap.queryProductDetails({productId});
    if (response.productDetails.isEmpty) {
      throw StateError('Producto no encontrado en Play Console: $productId');
    }
    final purchaseParam =
        PurchaseParam(productDetails: response.productDetails.first);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _verifyAndActivate(
    String communityId,
    PurchaseDetails purchase,
  ) async {
    await _functions.verifyPlaySubscription(
      communityId: communityId,
      productId: purchase.productID,
      purchaseToken: purchase.verificationData.serverVerificationData,
    );
  }

  void dispose() => _subscription?.cancel();
}

final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  return BillingRepository(
    InAppPurchase.instance,
    ref.watch(cloudFunctionsProvider),
  );
});
```

- [ ] **Step 6: Correr el test y confirmar que pasa**

```bash
flutter test test/features/premium/subscriptions/billing_repository_test.dart
flutter analyze
```

Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/shared/services/cloud_functions_service.dart lib/features/premium/subscriptions/repositories/billing_repository.dart test/features/premium/subscriptions/billing_repository_test.dart
git commit -m "feat(pagos): agregar BillingRepository para Google Play Billing"
```

### Task 15: Conectar la pantalla de planes a la compra real

**Files:**
- Modify: `lib/features/premium/subscriptions/screens/subscription_plans_screen.dart`

**Interfaces:**
- Consumes: `billingRepositoryProvider.buy(SubscriptionPlan)` de la Task 14, `subscriptionProvider(communityId)` (`subscription_repository.dart:64-71`).

- [ ] **Step 1: Agregar el método `_subscribeViaPlayBilling` junto a `_startTrial` (después de la línea 145)**

```dart
  Future<void> _subscribeViaPlayBilling(SubscriptionPlan plan) async {
    if (_isLoading) return;

    final communityId = ref.read(currentCommunityIdProvider);
    if (communityId == null) {
      context.showErrorSnackBar('Comunidad no disponible');
      return;
    }

    setState(() => _isLoading = true);
    try {
      ref.read(billingRepositoryProvider).listenToPurchaseUpdates(communityId);
      await ref.read(billingRepositoryProvider).buy(plan);
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Error al iniciar la compra: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
```

- [ ] **Step 2: Decidir qué acción dispara cada botón según el estado de la suscripción**

Reemplazar el `onSubscribe: () => _startTrial(plan)` de cada `_PlanCard` (líneas 63, 78, 91) para que use el trial solo si no existe suscripción previa, y la compra real si el trial ya venció:

```dart
                  onSubscribe: () {
                    final sub = ref.read(subscriptionProvider(
                      ref.read(currentCommunityIdProvider) ?? '',
                    )).value;
                    if (sub == null) {
                      _startTrial(SubscriptionPlan.starter);
                    } else {
                      _subscribeViaPlayBilling(SubscriptionPlan.starter);
                    }
                  },
```

(Repetir el mismo patrón para `professional` y `enterprise`, cambiando el enum.)

- [ ] **Step 3: Verificar manualmente en un dispositivo con una cuenta de prueba de Play Console (licencia de prueba en Play Console → Configuración → Testers de licencia)**

- [ ] **Step 4: `flutter analyze`, `flutter test`, commit**

```bash
flutter analyze
flutter test
git add lib/features/premium/subscriptions/screens/subscription_plans_screen.dart
git commit -m "feat(pagos): conectar planes premium a Google Play Billing"
```

### Task 16: Retirar el cobro B2B no funcional (`BillSubscription`)

**Files:**
- Modify: `functions/fn/subscriptions.go`

**Interfaces:**
- Ninguna — es limpieza de código muerto ahora que la activación real pasa por `VerifyPlaySubscription`.

- [ ] **Step 1: Confirmar que ninguna otra función depende de `billing_records` o de que `BillSubscription` corra**

```bash
grep -rn "billing_records\|BillSubscription" functions/
```

- [ ] **Step 2: Eliminar el Cloud Scheduler job que invoca `BillSubscription` (Google Cloud Console → Cloud Scheduler) y eliminar `functions/fn/subscriptions.go`**, o dejarlo solo para expirar trials vencidos sin cobrar (ajustar el archivo para quitar la sección de `billing_records`/`planPrices` y conservar únicamente el bloque que pasa `status: trial` → `expired` cuando no hubo activación por Play Billing).

- [ ] **Step 3: `go build ./...` y `go test ./...`**

- [ ] **Step 4: Commit**

```bash
git add functions/fn/subscriptions.go
git commit -m "refactor(pagos): retirar cobro B2B no funcional, reemplazado por Play Billing"
```

---

## Fase 8 — i18n masivo (es/en)

**Contexto:** el patrón ya está probado en `login_screen.dart` (usa `context.l10n.<key>`, ver `lib/core/extensions/l10n_extensions.dart` y claves en `lib/l10n/app_es.arb` / `app_en.arb`, generadas por `flutter gen-l10n` gracias a `generate: true` en `pubspec.yaml:112`). Faltan ~200 strings quemados en el resto de módulos.

### Task 17: Migrar `feed` (módulo piloto del resto de la app)

**Files:**
- Modify: `lib/l10n/app_es.arb`
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/features/feed/screens/feed_screen.dart:76,87,155,164,189,190,272`
- Modify: el resto de archivos bajo `lib/features/feed/` con strings quemados (detectar con el comando del Step 1)

**Interfaces:**
- Consumes: `context.l10n` (`l10n_extensions.dart:6`).

- [ ] **Step 1: Listar los strings quemados del módulo**

```bash
grep -rn "'[A-ZÁÉÍÓÚÑ][a-záéíóúñ ]\{3,\}'" lib/features/feed/
```

- [ ] **Step 2: Agregar las claves nuevas a `lib/l10n/app_es.arb` y `app_en.arb`** (mismo estilo que las existentes, ej. `login`/`email`), por ejemplo para lo encontrado en `feed_screen.dart`:

`app_es.arb`:
```json
  "feedDefaultCommunityName": "Vecindario",
  "feedAdminPanelTooltip": "Panel de administración",
  "feedMyStoreTooltip": "Mi tienda",
  "feedEmptyTitle": "Sin noticias aún",
  "feedEmptySubtitle": "Sé el primero en compartir algo con tu comunidad",
  "feedAdSpacePlaceholder": "Espacio publicitario disponible",
```

`app_en.arb`:
```json
  "feedDefaultCommunityName": "Vecindario",
  "feedAdminPanelTooltip": "Admin panel",
  "feedMyStoreTooltip": "My store",
  "feedEmptyTitle": "No news yet",
  "feedEmptySubtitle": "Be the first to share something with your community",
  "feedAdSpacePlaceholder": "Ad space available",
```

- [ ] **Step 3: Regenerar y usar las claves en `feed_screen.dart`**

```bash
flutter gen-l10n
```

Reemplazar, por ejemplo:

```dart
// Antes (línea 76)
community?.name ?? 'Vecindario',
// Después
community?.name ?? context.l10n.feedDefaultCommunityName,

// Antes (línea 155)
tooltip: 'Panel de administración',
// Después
tooltip: context.l10n.feedAdminPanelTooltip,

// Antes (línea 189-190)
title: 'Sin noticias aún',
subtitle: 'Sé el primero en compartir algo con tu comunidad',
// Después
title: context.l10n.feedEmptyTitle,
subtitle: context.l10n.feedEmptySubtitle,
```

Repetir para cada string listado en el Step 1 dentro de `lib/features/feed/` (widgets de creación de post, detalle, carrusel, etc.), siguiendo el mismo patrón.

- [ ] **Step 4: Verificar**

```bash
flutter analyze
flutter test
```

- [ ] **Step 5: Commit**

```bash
git add lib/l10n/app_es.arb lib/l10n/app_en.arb lib/features/feed/
git commit -m "feat(i18n): migrar el modulo feed a claves de traduccion"
```

### Task 18: Repetir el patrón de la Task 17 en el resto de módulos

Ejecutar exactamente los mismos 5 steps de la Task 17 (grep de strings → agregar claves es/en → `flutter gen-l10n` → reemplazar `context.l10n.*` → verificar y commit), una vez por cada módulo restante, en este orden sugerido (de mayor a menor densidad de strings de cara al usuario final):

- [ ] `lib/features/stores/`
- [ ] `lib/features/services/`
- [ ] `lib/features/premium/` (amenities, asambleas, circulares, finanzas, multas, manual de convivencia, PQRS, dashboard, subscriptions)
- [ ] `lib/features/super_admin/`
- [ ] `lib/features/profile/`
- [ ] `lib/features/onboarding/`
- [ ] `lib/features/notifications/`
- [ ] `lib/features/external_services/`
- [ ] `lib/features/admin/`
- [ ] `lib/shared/widgets/` (widgets compartidos con texto embebido)

Cada módulo es su propio commit, revisable de forma independiente.

### Task 19: Revisión de traducciones EN y coherencia de locale en fechas

**Files:**
- Modify: `lib/l10n/app_en.arb` (revisión de calidad de las traducciones agregadas en las Tasks 17-18)
- Modify: `lib/main.dart:30-35` (si se decide que el locale deje de estar fijo en español)

**Interfaces:**
- Ninguna.

- [ ] **Step 1: El usuario revisa manualmente todas las traducciones EN agregadas** (no delegar esta revisión — el dominio "administración de conjuntos residenciales en Colombia" tiene terminología específica que una traducción automática puede errar).

- [ ] **Step 2: Si la app pasa a soportar cambio de idioma en runtime, actualizar `timeago`/`DateFormat` para que sigan el locale activo en vez de estar fijos en `'es'`**

```dart
// lib/main.dart:30-35 — reemplazar el locale fijo por inicialización de ambos
timeago.setLocaleMessages('es', timeago.EsMessages());
timeago.setLocaleMessages('en', timeago.EnMessages());
await initializeDateFormatting('es', null);
await initializeDateFormatting('en', null);
```

Y usar `Localizations.localeOf(context).languageCode` donde hoy se llama `timeago.format(date)` sin locale explícito (buscar con `grep -rn "timeago.format" lib/`).

- [ ] **Step 3: `flutter test` completo y commit**

```bash
flutter test
git add lib/main.dart lib/l10n/app_en.arb
git commit -m "fix(i18n): soportar locale dinamico en fechas relativas"
```

---

## Self-Review

**Cobertura del pedido original (auditoría de Play Store):**
- Firma release debug → Fase 1, Task 1. ✅
- Minify/ProGuard ausente → Fase 1, Task 2. ✅
- `baseUrl`/Wompi placeholders → Fase 2, Tasks 3-4. ✅
- Permisos cámara/galería no declarados → Fase 3, Task 5. ✅
- `permission_handler` sin uso → Fase 3, Task 6. ✅
- `storage.rules` sin chequeo de pertenencia → Fase 4, Task 7. ✅
- Sin Crashlytics/captura global → Fase 5, Tasks 8-9. ✅
- Splash default → Fase 6, Task 10. ✅
- Modelo de cobro de suscripción premium (decisión: Google Play Billing) → Fase 7, Tasks 11-16. ✅
- i18n masivo pendiente → Fase 8, Tasks 17-19. ✅

**Pendiente fuera de este plan (decisión ya tomada, no bloqueante):** sacar `google-services.json` del control de versiones y restringir la API key en Google Cloud Console — es un paso manual de consola sin código asociado; no requiere tarea de ingeniería.
