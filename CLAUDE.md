# Vecindario - Tu comunidad, conectada

## Stack
- Flutter 3.32+ (Dart 3.8+)
- Firebase: Auth, Firestore, Storage, FCM, Analytics
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

## Firebase (pendiente configuración)
- Ejecutar `flutterfire configure` cuando se tenga proyecto Firebase
- Descomentar Firebase.initializeApp en main.dart
- Configurar google-services.json (Android) y GoogleService-Info.plist (iOS)

## Reglas
- Firestore Security Rules en `firestore.rules`
- Índices en `firestore.indexes.json`
- Verificación de residentes: código invitación + aprobación admin
- Cumplimiento Ley 1581/2012 (Habeas Data Colombia)
