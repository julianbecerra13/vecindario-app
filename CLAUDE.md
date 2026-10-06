# Vecindario - Tu comunidad, conectada

## Stack
- Flutter 3.32+ (Dart 3.8+)
- Firebase: Auth, Firestore, FCM, Analytics
- Archivos: Cloudinary Free mediante upload preset unsigned
- Cloud Functions: Go
- Pagos: Wompi / MercadoPago

## Arquitectura
- **Feature-first** con Repository Pattern
- **State Management**: Riverpod (flutter_riverpod + riverpod_annotation)
- **Routing**: GoRouter con auth guards
- **Models**: Freezed + json_serializable
- **Patrón**: Screen → Provider → Repository → Firebase

## Convenciones
- Archivos en snake_case
- Clases en PascalCase
- Providers con sufijo Provider (ej: feedPostsProvider)
- Repositories con sufijo Repository
- Modelos con sufijo Model
- Imports absolutos: `package:vecindario_app/...`

## Estructura
```
lib/
├── core/          # Constantes, tema, router, utils, extensions
├── shared/        # Modelos, providers y widgets compartidos
├── features/      # Módulos por feature (auth, feed, services, etc.)
└── l10n/          # Internacionalización (es/en)
```

## Comandos
```bash
flutter pub get                    # Instalar dependencias
dart run build_runner build        # Generar código (freezed, riverpod, json)
dart run build_runner watch        # Watch mode para generación
flutter analyze                    # Análisis estático
flutter test                       # Correr tests
```

## Firebase
- Proyecto configurado: `vecindario-app-a746b`
- Authentication, Firestore y Hosting están activos.
- Las reglas de Firestore se prueban con emuladores antes de desplegarse.
- Las cargas multimedia usan Cloudinary para no requerir facturación de Firebase.
- La compilación necesita `CLOUDINARY_UPLOADS_ENABLED`, `CLOUDINARY_CLOUD_NAME`
  y `CLOUDINARY_UPLOAD_PRESET` mediante `--dart-define`.
- No activar facturación ni desplegar funciones que la requieran sin autorización expresa.

## Reglas
- Firestore Security Rules en `firestore.rules`
- Índices en `firestore.indexes.json`
- Verificación de residentes: código invitación + aprobación admin
- Cumplimiento Ley 1581/2012 (Habeas Data Colombia)
