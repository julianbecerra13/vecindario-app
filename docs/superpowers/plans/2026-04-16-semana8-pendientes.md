# Semana 8 — Features Pendientes

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Completar los 3 features técnicos pendientes de Semana 8: reemplazar el calendario manual de Zonas Sociales con `table_calendar`, implementar el procesamiento real de imágenes en Cloud Functions (resize + strip EXIF), y aplicar el rate limiting existente a las Cloud Functions HTTP.

**Architecture:**
- Flutter: reemplazar `GridView.builder` manual en `_AmenityBookingSheet` con `TableCalendar` — misma lógica de booking, solo cambia la UI del calendario.
- Go: reescribir `images.go` para leer el archivo de Cloud Storage, redimensionar a máx 1200px y re-encodear como JPEG (Go's jpeg encoder no escribe EXIF, lo que lo elimina automáticamente).
- Go: aplicar `middleware.RateLimiter` (ya existe en `functions/internal/middleware/ratelimit.go`) a las 3 Cloud Functions HTTP más críticas.

**Tech Stack:** Flutter 3.32+, `table_calendar: ^3.1.3`, Go 1.21, `golang.org/x/image`, `cloud.google.com/go/storage`, Firebase Admin SDK Go v4.

---

## Archivos que se modifican

| Archivo | Acción |
|---|---|
| `lib/features/premium/amenities/screens/amenities_screen.dart` | Modificar — reemplazar calendario manual |
| `functions/fn/images.go` | Modificar — implementar resize + EXIF strip |
| `functions/fn/orders.go` | Modificar — aplicar rate limiting |
| `functions/fn/circulars.go` | Modificar — aplicar rate limiting |
| `functions/fn/amenities.go` | Modificar — aplicar rate limiting |
| `functions/go.mod` | Modificar — agregar `cloud.google.com/go/storage` y `golang.org/x/image` |

---

## Task 1: table_calendar en AmenitiesScreen

**Files:**
- Modify: `lib/features/premium/amenities/screens/amenities_screen.dart:1-13` (imports)
- Modify: `lib/features/premium/amenities/screens/amenities_screen.dart:164-207` (estado y métodos)
- Modify: `lib/features/premium/amenities/screens/amenities_screen.dart:280-384` (UI del calendario)

---

- [ ] **Step 1: Agregar import de table_calendar**

En `lib/features/premium/amenities/screens/amenities_screen.dart`, reemplaza los imports existentes con:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/premium/models/amenity_model.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/services/payment_service.dart';
import 'package:vecindario_app/shared/widgets/empty_state.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';
```

---

- [ ] **Step 2: Actualizar el estado de `_AmenityBookingSheetState`**

Reemplaza las variables de estado y los métodos de navegación (líneas 165–207):

**Antes:**
```dart
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDate;
  Set<int> _bookedDays = {};

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final communityId = ref.read(currentCommunityIdProvider);
    if (communityId == null) return;
    final bookings = await ref
        .read(premiumRepositoryProvider)
        .watchBookings(communityId, widget.amenity.id)
        .first;
    if (mounted) {
      setState(() {
        _bookedDays = bookings
            .where((b) =>
                b.status == BookingStatus.confirmed &&
                b.date.year == _currentMonth.year &&
                b.date.month == _currentMonth.month)
            .map((b) => b.date.day)
            .toSet();
      });
    }
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _selectedDate = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _selectedDate = null;
    });
  }
```

**Después:**
```dart
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;
  Set<DateTime> _bookedDays = {};

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final communityId = ref.read(currentCommunityIdProvider);
    if (communityId == null) return;
    final bookings = await ref
        .read(premiumRepositoryProvider)
        .watchBookings(communityId, widget.amenity.id)
        .first;
    if (mounted) {
      setState(() {
        _bookedDays = bookings
            .where((b) => b.status == BookingStatus.confirmed)
            .map((b) => DateTime(b.date.year, b.date.month, b.date.day))
            .toSet();
      });
    }
  }
```

---

- [ ] **Step 3: Actualizar el `build` — eliminar variables obsoletas**

En el método `build` (línea 211), reemplaza las variables iniciales:

**Antes:**
```dart
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday; // 1=Mon
    final monthName = _monthName(_currentMonth.month);
    final totalCost = widget.amenity.hourlyRate + (widget.amenity.deposit ?? 0);
```

**Después:**
```dart
    final totalCost = widget.amenity.hourlyRate + (widget.amenity.deposit ?? 0);
```

---

- [ ] **Step 4: Reemplazar el bloque del calendario en el `ListView`**

Reemplaza desde `// Header días` hasta la leyenda (el bloque completo lines 298–384):

**Antes (todo este bloque):**
```dart
          // Header días
          Row(
            children: ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do']
                ...
          ),
          const SizedBox(height: 6),

          // Grid calendario
          GridView.builder(
            ...
          ),
          const SizedBox(height: AppSizes.sm),

          // Leyenda
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: AppColors.success.withValues(alpha: 0.15), label: 'Disponible'),
              const SizedBox(width: 16),
              _Legend(color: AppColors.error.withValues(alpha: 0.15), label: 'Reservado'),
              const SizedBox(width: 16),
              _Legend(color: AppColors.success, label: 'Seleccionado'),
            ],
          ),
```

**Después:**
```dart
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) =>
                _selectedDate != null && isSameDay(_selectedDate!, day),
            enabledDayPredicate: (day) {
              final normalized = DateTime(day.year, day.month, day.day);
              return !_bookedDays.contains(normalized) &&
                  !day.isBefore(DateTime.now().subtract(const Duration(days: 1)));
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
                _selectedDate = null;
              });
              _loadBookings();
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              selectedDecoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(color: AppColors.success, fontSize: 12),
              defaultDecoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              defaultTextStyle: const TextStyle(color: AppColors.success, fontSize: 12),
              weekendDecoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(color: AppColors.success, fontSize: 12),
              disabledDecoration: const BoxDecoration(shape: BoxShape.circle),
              disabledTextStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
            calendarBuilders: CalendarBuilders(
              disabledBuilder: (context, day, focusedDay) {
                final normalized = DateTime(day.year, day.month, day.day);
                if (_bookedDays.contains(normalized)) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                    ),
                  );
                }
                return null;
              },
              headerTitleBuilder: (context, day) => Center(
                child: Text(
                  '${_monthName(day.month)} ${day.year}',
                  style: AppTextStyles.heading3,
                ),
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          // Leyenda
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: AppColors.success.withValues(alpha: 0.15), label: 'Disponible'),
              const SizedBox(width: 16),
              _Legend(color: AppColors.error.withValues(alpha: 0.15), label: 'Reservado'),
              const SizedBox(width: 16),
              _Legend(color: AppColors.success, label: 'Seleccionado'),
            ],
          ),
```

---

- [ ] **Step 5: Verificar que la app compila**

```bash
cd C:\Users\becer\OneDrive\Escritorio\vecindario
flutter analyze lib/features/premium/amenities/
```

Esperado: no hay errores (puede haber warnings de unused `_monthName` en contextos ajenos, pero el método aún se usa en `headerTitleBuilder` y `_formatDate`).

---

- [ ] **Step 6: Commit**

```bash
git add lib/features/premium/amenities/screens/amenities_screen.dart
git commit -m "feat: reemplazar calendario manual con table_calendar en zonas sociales"
```

---

## Task 2: ProcessImage — Resize + EXIF Strip (Go)

**Files:**
- Modify: `functions/go.mod` — agregar dependencias
- Modify: `functions/fn/images.go` — reescribir con implementación real

---

- [ ] **Step 1: Agregar dependencias Go**

```bash
cd C:\Users\becer\OneDrive\Escritorio\vecindario\functions
go get cloud.google.com/go/storage
go get golang.org/x/image
go mod tidy
```

Esperado: `go.mod` actualizado con las nuevas dependencias, `go.sum` actualizado.

---

- [ ] **Step 2: Reescribir `functions/fn/images.go`**

Reemplaza el contenido completo del archivo:

```go
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
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"golang.org/x/image/draw"
	"google.golang.org/api/option"
)

const maxImageWidth = 1200

func init() {
	functions.CloudEvent("ProcessImage", processImage)
}

type StorageEvent struct {
	Bucket      string `json:"bucket"`
	Name        string `json:"name"`
	ContentType string `json:"contentType"`
}

func processImage(ctx context.Context, e interface{}) error {
	data, ok := e.(map[string]interface{})
	if !ok {
		return fmt.Errorf("invalid event type: %T", e)
	}

	bucket, _ := data["bucket"].(string)
	name, _ := data["name"].(string)
	contentType, _ := data["contentType"].(string)

	if bucket == "" || name == "" {
		return fmt.Errorf("missing bucket or name in event")
	}

	if !isImageContentType(contentType) {
		return nil
	}

	fs, _, err := initFirebase(ctx)
	if err != nil {
		return err
	}
	defer fs.Close()

	storageClient, err := gcstorage.NewClient(ctx, option.WithoutAuthentication())
	if err != nil {
		// En Cloud Run, las credenciales vienen del entorno automáticamente
		storageClient, err = gcstorage.NewClient(ctx)
		if err != nil {
			return fmt.Errorf("storage client: %v", err)
		}
	}
	defer storageClient.Close()

	obj := storageClient.Bucket(bucket).Object(name)

	reader, err := obj.NewReader(ctx)
	if err != nil {
		return fmt.Errorf("reading object %s/%s: %v", bucket, name, err)
	}
	defer reader.Close()

	img, _, err := image.Decode(reader)
	if err != nil {
		log.Printf("ProcessImage: decode error for %s: %v (skipping)", name, err)
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
		return fmt.Errorf("writing image: %v", err)
	}
	if err := writer.Close(); err != nil {
		return fmt.Errorf("closing storage writer: %v", err)
	}

	_, _, err = fs.Collection("audit_logs").Add(ctx, map[string]interface{}{
		"type":      "image_processed",
		"path":      name,
		"context":   inferImageContext(name),
		"status":    "processed",
		"createdAt": firestore.ServerTimestamp,
	})
	if err != nil {
		log.Printf("ProcessImage: audit log error: %v", err)
	}

	log.Printf("ProcessImage: processed %s (%d bytes)", name, buf.Len())
	return nil
}

func resizeIfNeeded(img image.Image) image.Image {
	bounds := img.Bounds()
	w := bounds.Dx()
	if w <= maxImageWidth {
		return img
	}
	h := bounds.Dy()
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
```

---

- [ ] **Step 3: Verificar que compila**

```bash
cd C:\Users\becer\OneDrive\Escritorio\vecindario\functions
go build ./...
```

Esperado: sin errores. Si hay error de `option.WithoutAuthentication` no encontrado, reemplaza el bloque `storageClient, err := ...` con:
```go
storageClient, err := gcstorage.NewClient(ctx)
if err != nil {
    return fmt.Errorf("storage client: %v", err)
}
```

---

- [ ] **Step 4: Commit**

```bash
cd C:\Users\becer\OneDrive\Escritorio\vecindario
git add functions/fn/images.go functions/go.mod functions/go.sum
git commit -m "feat: implementar resize y strip EXIF en ProcessImage Cloud Function"
```

---

## Task 3: Aplicar Rate Limiting a Cloud Functions HTTP

**Context:** El middleware ya existe en `functions/internal/middleware/ratelimit.go`. Solo hay que importarlo y usarlo en las 3 funciones HTTP críticas. El import path es `github.com/vecindario/functions/internal/middleware`.

**Files:**
- Modify: `functions/fn/orders.go` — CreateOrder
- Modify: `functions/fn/circulars.go` — SendCircular
- Modify: `functions/fn/amenities.go` — BookAmenity

---

- [ ] **Step 1: Agregar rate limiting a `orders.go`**

En `functions/fn/orders.go`, agrega el import del middleware en el bloque de imports:

```go
import (
    "context"
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "strings"
    "time"

    "cloud.google.com/go/firestore"
    "github.com/GoogleCloudPlatform/functions-framework-go/functions"
    "github.com/vecindario/functions/internal/middleware"
)
```

Luego, en `createOrder`, inserta el check justo después de `defer fs.Close()` (después de las líneas `fs, msg, err := initFirebase(ctx)` y `defer fs.Close()`):

```go
	// Rate limiting: máx 10 órdenes por minuto por usuario
	rl := middleware.NewRateLimiter(fs)
	if !rl.Middleware(callerUID, w, r) {
		return
	}
```

---

- [ ] **Step 2: Agregar rate limiting a `circulars.go`**

Primero lee los imports actuales de `circulars.go`:

```bash
head -20 C:\Users\becer\OneDrive\Escritorio\vecindario\functions\fn\circulars.go
```

Agrega el import de middleware igual que en el paso anterior y, en la función `sendCircular`, después de `defer fs.Close()`:

```go
	rl := middleware.NewRateLimiter(fs)
	if !rl.Middleware(callerUID, w, r) {
		return
	}
```

---

- [ ] **Step 3: Agregar rate limiting a `amenities.go`**

Igual que los anteriores. En la función `bookAmenity`, después de `defer fs.Close()`:

```go
	rl := middleware.NewRateLimiter(fs)
	if !rl.Middleware(callerUID, w, r) {
		return
	}
```

---

- [ ] **Step 4: Verificar que compila**

```bash
cd C:\Users\becer\OneDrive\Escritorio\vecindario\functions
go build ./...
```

Esperado: sin errores. Si hay un error de módulo no encontrado en `internal/middleware`, asegúrate de que el path del módulo en `go.mod` es `github.com/vecindario/functions` (ya confirmado).

---

- [ ] **Step 5: Commit**

```bash
cd C:\Users\becer\OneDrive\Escritorio\vecindario
git add functions/fn/orders.go functions/fn/circulars.go functions/fn/amenities.go
git commit -m "feat: aplicar rate limiting a CreateOrder, SendCircular y BookAmenity"
```

---

## Verificación End-to-End

### Task 1 — Calendario
- Corre `flutter run` en dispositivo/emulador
- Navega a Premium → Zonas Sociales
- Toca una zona social → verifica que abre el bottom sheet con `TableCalendar`
- Verifica que los días disponibles están en verde, reservados en rojo
- Cambia de mes con las flechas del header — verifica que recarga bookings
- Selecciona un día disponible → verifica que se resalta en verde sólido
- Verifica que el resumen de reserva aparece debajo del calendario

### Task 2 — ProcessImage
- Esta función se dispara en Cloud Storage. Para probar sin deploy:
  ```bash
  cd functions && go vet ./fn/
  ```
- En producción: sube una imagen JPEG >1200px a Firebase Storage y verifica en Firestore `audit_logs` que aparece un documento con `type: "image_processed"`.

### Task 3 — Rate Limiting
- Para probar el límite localmente, usa curl o Postman enviando >10 requests en un minuto al endpoint de Cloud Functions.
- Verifica que la respuesta 429 con `"Rate limit exceeded"` aparece después de 10 requests.
- En producción, los logs de Cloud Functions mostrarán el bloqueo.
