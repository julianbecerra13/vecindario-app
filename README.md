# Vecindario - Tu comunidad, conectada 🏘️

Aplicación Flutter para gestión integral de comunidades residenciales en Colombia. Conecta vecinos, facilita transacciones comerciales y digitaliza la administración comunitaria.

## Estado del Proyecto: ✅ COMPLETO

Todas las pantallas y funcionalidades principales han sido implementadas y probadas.

## Stack Tecnológico

- **Frontend**: Flutter 3.32+ (Dart 3.8+)
- **Backend**: Firebase (Auth, Firestore, Storage, FCM, Analytics)
- **Cloud**: Cloud Functions (Go)
- **Pagos**: Wompi / MercadoPago
- **State Management**: Riverpod + Riverpod Annotations
- **Routing**: GoRouter con role-based access control
- **Modelos**: Freezed + json_serializable

## Arquitectura

- **Pattern**: Feature-first con Repository Pattern
- **State**: Riverpod (StreamProvider, FutureProvider, StateProvider)
- **Flujo**: Screen → Provider → Repository → Firebase

```
lib/
├── core/              # Router, constantes, tema, utils
├── shared/            # Modelos y providers compartidos
├── features/          # Módulos por feature
│   ├── auth/          # Autenticación
│   ├── feed/          # Muro de noticias
│   ├── services/      # Servicios vecinales
│   ├── stores/        # Marketplace
│   ├── profile/       # Perfil de usuario
│   ├── admin/         # Panel admin comunitario
│   ├── premium/       # Features premium (circulares, multas, finanzas, etc)
│   ├── super_admin/   # Panel de plataforma
│   └── ...
└── l10n/              # Internacionalización (es/en)
```

## Pantallas Implementadas (45 total)

### 🏠 Shell Principal (4 tabs)
- **Feed** - Muro de noticias y actualizaciones
- **Servicios** - Servicios vecinales ofrecidos por residentes
- **Tiendas** - Marketplace comunitario
- **Servicios Externos** - Directorio de servicios

### 👤 Usuario
- **Perfil** - Información personal, estadísticas (posts, órdenes, membresía)
- **Editar Perfil** - Actualizar datos
- **Privacidad** - Configuración de privacidad
- **Términos y Políticas** - Documentos legales
- **Notificaciones** - Centro de notificaciones

### 🔐 Autenticación
- **Login** - Inicio de sesión
- **Registro** - Crear nueva cuenta
- **Recuperar Contraseña** - Reset de contraseña
- **Verificación de Teléfono** - Confirmación OTP
- **Unirse a Comunidad** - Búsqueda y unión a comunidad
- **Aprobación Pendiente** - Estado de aprobación
- **Onboarding** - Introducción a la app

### 🛍️ Tiendas (Marketplace)
- **Listado de Tiendas** - Catálogo de tiendas activas
- **Detalle de Tienda** - Productos y detalles
- **Mis Órdenes** - Historial de compras
- **Seguimiento de Orden** - Estado real-time
- **Calificar Orden** - Reseña post-compra
- **Panel de Tienda** - Para dueños (crear/editar productos)

### 👔 Servicios Vecinales
- **Listado de Servicios** - Por categoría (hogar, belleza, comida, etc)
- **Detalle de Servicio** - Información y reseñas
- **Crear Servicio** - Para ofertantes
- **Recomendar Servicio** - Invitar servicios externos

### 👨‍💼 Admin Comunitario
- **Panel Admin** - Dashboard de gestión
- **Aprobaciones Pendientes** - Validar nuevos residentes

### 🏛️ Vecindario Admin (Premium - 15 pantallas)
- **Dashboard** - Resumen ejecutivo
- **Circulares** - Crear y gestionar comunicados
- **Multas** - Administrar infracciones y pagos
- **PQRS** - Peticiones, quejas, reclamos y sugerencias
- **Comodidades** - Gestionar amenities (gimnasio, piscina, etc)
- **Finanzas** - Estados de cuenta, porcentajes, ingresos
- **Manual de Convivencia** - Documento guía
- **Asambleas** - Registro de asambleas comunitarias
- **Planes de Suscripción** - Configurar planes premium

### 🔧 Super Admin (Plataforma)
- **Panel de Super Admin** - Gestión de clientes y comunidades

## Funcionalidades Implementadas

✅ **Feed Social**
- Crear, editar, eliminar posts
- Buscar en tiempo real
- Listar, likear y comentar posts
- Posts fijos/anclados

✅ **Servicios Vecinales**
- Listar servicios por categoría
- Filtrar activos/inactivos
- Reseñas y calificaciones
- Crear servicio como ofertante

✅ **Marketplace**
- Listar tiendas activas
- Crear órdenes
- Seguimiento de estado
- Calificar órdenes post-compra

✅ **Perfil**
- Mostrar información del usuario
- Estadísticas (posts, órdenes, membresía)
- Editar datos personales

✅ **Autenticación**
- Login/Register con email y contraseña
- OTP por teléfono
- Recuperar contraseña
- Unirse a comunidad con código
- Aprobación admin de nuevos residentes

✅ **Control de Acceso**
- Guards por rol (admin, super_admin, store_owner, user)
- Protección de rutas premium
- Redirección basada en estado de usuario

✅ **Búsqueda y Filtrado**
- Búsqueda en feed (posts y autores)
- Filtro de servicios por categoría
- Filtro de órdenes por usuario

## Tests Implementados

✅ **Repository Tests** (usando FakeFirebaseFirestore)
- `test/repositories/feed_repository_test.dart` - 5 tests
- `test/repositories/stores_repository_test.dart` - 4 tests
- `test/repositories/services_repository_test.dart` - 6 tests
- `test/repositories/user_repository_test.dart` - existente

## Instalación

```bash
# Clonar repositorio
git clone <repo-url>
cd vecindario

# Instalar dependencias
flutter pub get

# Generar código (Freezed, Riverpod, JSON serialization)
dart run build_runner build

# O en watch mode
dart run build_runner watch
```

## Ejecutar la App

```bash
# Desarrollo
flutter run

# Release
flutter run --release

# En dispositivo específico
flutter run -d <device-id>
```

## Análisis y Tests

```bash
# Análisis estático
flutter analyze

# Ejecutar tests unitarios
flutter test

# Tests específicos
flutter test test/repositories/feed_repository_test.dart
```

## Convenciones de Código

- **Archivos**: snake_case
- **Clases**: PascalCase
- **Providers**: sufijo `Provider` (ej: `feedPostsProvider`)
- **Repositories**: sufijo `Repository` (ej: `FeedRepository`)
- **Modelos**: sufijo `Model` (ej: `PostModel`)
- **Imports**: absolutos con `package:vecindario_app/...`
- **Enums**: valores en snake_case (`post_type`, `service_category`, `order_status`)

## Seguridad

- Firestore Security Rules configuradas por rol
- Validación de usuarios en frontend y backend
- Guards en router para proteger rutas
- Cumplimiento Ley 1581/2012 (Habeas Data Colombia)

## Configuración Firebase

```bash
# Configurar Firebase CLI
flutterfire configure

# Esto genera:
# - lib/firebase_options.dart
# - google-services.json (Android)
# - GoogleService-Info.plist (iOS)
```

## Variables de Entorno

```dart
// lib/firebase_options.dart (generado automáticamente)
// Contiene: projectId, apiKey, authDomain, databaseURL, storageBucket
```

## Próximos Pasos (Post-MVP)

- [ ] Integración pagos (Wompi/MercadoPago)
- [ ] Notificaciones push mejoradas
- [ ] Geolocalización para servicios cercanos
- [ ] Chat en vivo entre vecinos
- [ ] Reportes y estadísticas avanzadas
- [ ] App web para admin
- [ ] Soporte multi-idioma completo (EN)

## Contribuir

1. Crear rama desde `main`
2. Hacer cambios siguiendo convenciones
3. Ejecutar `flutter analyze` y `flutter test`
4. Abrir Pull Request

## Licencia

Propietario - Vecindario SAS

## Contacto

info@kory.com.co

---

**Desarrollado con ❤️ para comunidades conectadas**
