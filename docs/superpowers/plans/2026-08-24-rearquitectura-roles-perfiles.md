# Rearquitectura de Roles y Perfiles — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Separar el actual `UserModel.role` (enum plano de 5 valores mutuamente excluyentes) en tres ejes independientes — `communityRole` (resident/admin), `platformRole` (super_admin, opcional) y capacidades derivadas (hasStore/offersService, no exclusivas) — y fusionar los dos paneles de administración de conjunto hoy separados (`/admin` y `/premium`) en uno solo, con el router partido por perfil.

**Architecture:** Cambio de esquema en `UserModel` + Firestore rules + backend Go (10 call sites que leen `role`), sin tocar la navegación de fondo (se mantiene un solo app Flutter con `HomeShell` como casa de resident/admin). Las "capacidades" de negocio (tienda, servicio ofertado) dejan de vivir en el rol y se derivan de queries a `stores`/`services` por `ownerUid` — ya es así de facto en las reglas de Firestore actuales, solo se formaliza en el modelo Dart. El router se parte en `resident_routes.dart` / `community_admin_routes.dart` / `super_admin_routes.dart`, ensamblados por `app_router.dart`, que retiene únicamente el `redirect` de alto nivel.

**Tech Stack:** Flutter/Dart (Riverpod, GoRouter, Freezed no aplica aquí — `UserModel` es una clase plana escrita a mano), Firebase (Firestore + Security Rules), Cloud Functions en Go.

**Spec:** No hay spec formal escrito — el usuario pidió saltar ese paso. El diseño aprobado en el chat de brainstorming (2026-08-24) es la referencia: separar `communityRole`/`platformRole`/capacidades, fusionar `/admin` + `/premium` en un solo módulo, partir el router por perfil, un solo app Flutter (no apps separadas).

## Global Constraints

- NUNCA incluir "Co-Authored-By: Claude" ni ningún rastro de IA en commits, código o comentarios (regla global del usuario).
- Responder siempre en español; comentarios de código solo donde el archivo ya los tenía, sin añadir bloques nuevos de documentación.
- Cada commit debe dejar el árbol en verde: `flutter analyze` sin errores, `flutter test` en verde, `go build ./...` y `go test ./...` en verde donde aplique.
- No renombrar rutas públicas existentes (`/premium`, `/super-admin`, etc.) salvo las explícitamente listadas en este plan (`/admin/*` se retira, sus pantallas se remontan bajo `/premium/*`).
- No tocar `pending_approvals_screen.dart` ni `community_settings_screen.dart` por dentro — solo cambia desde dónde se llega a ellas.

---

## Task 1: `CommunityRole` + `platformRole` en `UserModel`

**Files:**
- Modify: `lib/shared/models/user_model.dart`
- Test: `test/models/user_model_test.dart`

**Interfaces:**
- Produces: `enum CommunityRole { resident, admin }` con `.label`, `.fromString(String)`, `.toValue()`. `const String kSuperAdminPlatformRole = 'super_admin'`. `UserModel` con campos `communityRole` (`CommunityRole`, default `resident`) y `platformRole` (`String?`, default `null`), y getters `bool get isCommunityAdmin`, `bool get isSuperAdmin`, `bool get isAdmin`.
- Consumes: nada (es la base del resto de tasks).

- [ ] **Step 1: Reescribir el test de modelo primero (fallará porque el modelo aún no existe)**

Reemplazar el contenido completo de `test/models/user_model_test.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/shared/models/user_model.dart';

void main() {
  group('CommunityRole', () {
    test('fromString devuelve el rol correcto', () {
      expect(CommunityRole.fromString('admin'), CommunityRole.admin);
      expect(CommunityRole.fromString('resident'), CommunityRole.resident);
      expect(CommunityRole.fromString('unknown'), CommunityRole.resident);
    });

    test('toValue devuelve el string correcto', () {
      expect(CommunityRole.admin.toValue(), 'admin');
      expect(CommunityRole.resident.toValue(), 'resident');
    });
  });

  group('UserModel', () {
    test('fromFirestore crea modelo correctamente', () {
      final data = {
        'displayName': 'Juan Pérez',
        'email': 'juan@test.com',
        'phone': '3001234567',
        'photoURL': 'https://example.com/photo.jpg',
        'communityId': 'comm1',
        'communityRole': 'admin',
        'estrato': 4,
        'verified': true,
        'tower': 'T1',
        'apartment': '501',
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      };

      final user = UserModel.fromFirestore(data, 'uid1');

      expect(user.id, 'uid1');
      expect(user.displayName, 'Juan Pérez');
      expect(user.email, 'juan@test.com');
      expect(user.communityRole, CommunityRole.admin);
      expect(user.platformRole, isNull);
      expect(user.estrato, 4);
      expect(user.verified, true);
      expect(user.tower, 'T1');
      expect(user.apartment, '501');
    });

    test('fromFirestore reconoce platformRole de super_admin', () {
      final data = {
        'displayName': 'Ada',
        'email': 'ada@test.com',
        'phone': '3000000000',
        'communityRole': 'resident',
        'platformRole': 'super_admin',
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      };

      final user = UserModel.fromFirestore(data, 'uid2');

      expect(user.platformRole, 'super_admin');
      expect(user.isSuperAdmin, true);
      expect(user.isCommunityAdmin, false);
      expect(user.isAdmin, true);
    });

    test('toFirestore serializa correctamente', () {
      final user = UserModel(
        id: 'uid1',
        displayName: 'María López',
        email: 'maria@test.com',
        phone: '3009876543',
        communityRole: CommunityRole.resident,
        verified: false,
        createdAt: DateTime(2026, 3, 15),
      );

      final data = user.toFirestore();

      expect(data['displayName'], 'María López');
      expect(data['email'], 'maria@test.com');
      expect(data['communityRole'], 'resident');
      expect(data.containsKey('platformRole'), false);
      expect(data['verified'], false);
    });

    test('isAdmin es true para admin de comunidad y para super_admin', () {
      final communityAdmin = UserModel(
        id: '1',
        displayName: '',
        email: '',
        phone: '',
        communityRole: CommunityRole.admin,
        createdAt: DateTime.now(),
      );
      final superAdmin = UserModel(
        id: '2',
        displayName: '',
        email: '',
        phone: '',
        platformRole: 'super_admin',
        createdAt: DateTime.now(),
      );
      final resident = UserModel(
        id: '3',
        displayName: '',
        email: '',
        phone: '',
        createdAt: DateTime.now(),
      );

      expect(communityAdmin.isAdmin, true);
      expect(communityAdmin.isCommunityAdmin, true);
      expect(communityAdmin.isSuperAdmin, false);
      expect(superAdmin.isAdmin, true);
      expect(superAdmin.isSuperAdmin, true);
      expect(superAdmin.isCommunityAdmin, false);
      expect(resident.isAdmin, false);
    });

    test('initials funciona correctamente', () {
      final user = UserModel(
        id: '1',
        displayName: 'Juan Pérez',
        email: '',
        phone: '',
        createdAt: DateTime.now(),
      );
      expect(user.initials, 'JP');

      final singleName = UserModel(
        id: '2',
        displayName: 'Ana',
        email: '',
        phone: '',
        createdAt: DateTime.now(),
      );
      expect(singleName.initials, 'A');
    });

    test('unitInfo formatea torre y apartamento', () {
      final user = UserModel(
        id: '1',
        displayName: 'Test',
        email: '',
        phone: '',
        tower: '3',
        apartment: '402',
        createdAt: DateTime.now(),
      );
      expect(user.unitInfo, 'Torre 3 - Apto 402');
    });

    test('copyWith actualiza campos correctamente', () {
      final user = UserModel(
        id: '1',
        displayName: 'Original',
        email: 'old@test.com',
        phone: '',
        verified: false,
        createdAt: DateTime.now(),
      );

      final updated = user.copyWith(displayName: 'Actualizado', verified: true);

      expect(updated.displayName, 'Actualizado');
      expect(updated.verified, true);
      expect(updated.email, 'old@test.com'); // No cambió
      expect(updated.id, '1'); // Nunca cambia
    });
  });
}
```

- [ ] **Step 2: Correr el test y verificar que falla**

Run: `flutter test test/models/user_model_test.dart`
Expected: FAIL — `UserRole`/`role` ya no coincide con lo que el test espera (`CommunityRole` no existe todavía).

- [ ] **Step 3: Reescribir `lib/shared/models/user_model.dart`**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum CommunityRole {
  resident('Residente'),
  admin('Administrador');

  final String label;
  const CommunityRole(this.label);

  static CommunityRole fromString(String value) {
    switch (value) {
      case 'admin':
        return CommunityRole.admin;
      default:
        return CommunityRole.resident;
    }
  }

  String toValue() {
    switch (this) {
      case CommunityRole.admin:
        return 'admin';
      case CommunityRole.resident:
        return 'resident';
    }
  }
}

/// Único valor válido hoy para el rol de plataforma. Vive aparte de
/// [CommunityRole] porque un super_admin no pertenece a ninguna comunidad.
const String kSuperAdminPlatformRole = 'super_admin';

class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String phone;
  final String? photoURL;
  final String? communityId;
  final CommunityRole communityRole;
  final String? platformRole;
  final int? estrato;
  final bool verified;
  final String? tower;
  final String? apartment;
  final DateTime createdAt;
  final DateTime? deletedAt;

  const UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    required this.phone,
    this.photoURL,
    this.communityId,
    this.communityRole = CommunityRole.resident,
    this.platformRole,
    this.estrato,
    this.verified = false,
    this.tower,
    this.apartment,
    required this.createdAt,
    this.deletedAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      photoURL: data['photoURL'],
      communityId: data['communityId'],
      communityRole: CommunityRole.fromString(
        data['communityRole'] ?? 'resident',
      ),
      platformRole: data['platformRole'],
      estrato: data['estrato'],
      verified: data['verified'] ?? false,
      tower: data['tower'],
      apartment: data['apartment'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'photoURL': photoURL,
      'communityId': communityId,
      'communityRole': communityRole.toValue(),
      if (platformRole != null) 'platformRole': platformRole,
      'estrato': estrato,
      'verified': verified,
      'tower': tower,
      'apartment': apartment,
      'createdAt': Timestamp.fromDate(createdAt),
      if (deletedAt != null) 'deletedAt': Timestamp.fromDate(deletedAt!),
    };
  }

  UserModel copyWith({
    String? displayName,
    String? email,
    String? phone,
    String? photoURL,
    String? communityId,
    CommunityRole? communityRole,
    String? platformRole,
    int? estrato,
    bool? verified,
    String? tower,
    String? apartment,
    DateTime? deletedAt,
  }) {
    return UserModel(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoURL: photoURL ?? this.photoURL,
      communityId: communityId ?? this.communityId,
      communityRole: communityRole ?? this.communityRole,
      platformRole: platformRole ?? this.platformRole,
      estrato: estrato ?? this.estrato,
      verified: verified ?? this.verified,
      tower: tower ?? this.tower,
      apartment: apartment ?? this.apartment,
      createdAt: createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  /// True solo si el rol dentro de la comunidad es admin.
  bool get isCommunityAdmin => communityRole == CommunityRole.admin;

  /// True solo para el super_admin de plataforma (no pertenece a comunidad).
  bool get isSuperAdmin => platformRole == kSuperAdminPlatformRole;

  /// True si administra el conjunto O es super_admin de plataforma. Úsalo
  /// para mostrar accesos a "Administración" y proteger /premium.
  bool get isAdmin => isCommunityAdmin || isSuperAdmin;

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  String get unitInfo {
    if (tower != null && apartment != null) {
      return 'Torre $tower - Apto $apartment';
    }
    return '';
  }
}
```

- [ ] **Step 4: Correr el test y verificar que pasa**

Run: `flutter test test/models/user_model_test.dart`
Expected: PASS (todos los tests en verde)

- [ ] **Step 5: Commit**

```bash
git add lib/shared/models/user_model.dart test/models/user_model_test.dart
git commit -m "refactor(roles): separar communityRole y platformRole en UserModel"
```

---

## Task 2: Actualizar `current_user_provider.dart`

**Files:**
- Modify: `lib/shared/providers/current_user_provider.dart`

**Interfaces:**
- Consumes: `UserModel.isAdmin`, `.isCommunityAdmin`, `.isSuperAdmin` (Task 1).
- Produces: `isAdminProvider` (ya existía, misma firma `Provider<bool>`, comportamiento equivalente pero ahora basado en el modelo de 2 ejes), `isCommunityAdminProvider`, `isSuperAdminProvider` (nuevos, `Provider<bool>`).

- [ ] **Step 1: Reescribir el archivo**

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/shared/models/user_model.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';
import 'package:vecindario_app/shared/repositories/user_repository.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseStorageProvider),
  );
});

final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref.watch(userRepositoryProvider).watchUser(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

final currentCommunityIdProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.whenOrNull(data: (user) => user?.communityId);
});

final isVerifiedProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.whenOrNull(data: (user) => user?.verified ?? false) ??
      false;
});

/// True si administra el conjunto (communityRole == admin) o es super_admin
/// de plataforma. Úsalo para mostrar accesos a "Administración" y proteger
/// las pantallas de /premium.
final isAdminProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.whenOrNull(data: (user) => user?.isAdmin ?? false) ??
      false;
});

/// True solo si el rol dentro de la comunidad es admin (excluye al
/// super_admin de plataforma, que no pertenece a ninguna comunidad).
final isCommunityAdminProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.whenOrNull(data: (user) => user?.isCommunityAdmin ?? false) ??
      false;
});

/// True solo para el super_admin de plataforma.
final isSuperAdminProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.whenOrNull(data: (user) => user?.isSuperAdmin ?? false) ??
      false;
});
```

- [ ] **Step 2: Verificar que compila y los tests siguen en verde**

Run: `flutter analyze lib/shared/providers/current_user_provider.dart`
Expected: sin errores (los 8 call sites existentes de `isAdminProvider` en pantallas premium no cambian de firma, siguen compilando).

Run: `flutter test`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add lib/shared/providers/current_user_provider.dart
git commit -m "refactor(roles): basar isAdminProvider en communityRole/platformRole"
```

---

## Task 3: Capacidad "tiene tienda" — mover `ownerStoreProvider` al provider file

Hoy `store_panel_screen.dart` ya deriva "¿el usuario tiene una tienda?" con `ownerStoreProvider`, que usa `StoresRepository.getStoresForOwner(uid)` (ya existe, `lib/features/stores/repositories/stores_repository.dart:132`). Solo falta moverlo a `stores_provider.dart` para poder reutilizarlo fuera de `features/stores`.

**Files:**
- Modify: `lib/features/stores/providers/stores_provider.dart`
- Modify: `lib/features/stores/screens/store_panel_screen.dart`

**Interfaces:**
- Consumes: `StoresRepository.getStoresForOwner(String ownerUid)` (ya existe, sin cambios).
- Produces: `ownerStoreProvider` (`StreamProvider<StoreModel?>`), ahora ubicado en `stores_provider.dart`.

- [ ] **Step 1: Mover `ownerStoreProvider` a `stores_provider.dart`**

Reemplazar el contenido completo de `lib/features/stores/providers/stores_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/features/stores/models/store_item_model.dart';
import 'package:vecindario_app/features/stores/models/store_model.dart';
import 'package:vecindario_app/features/stores/repositories/stores_repository.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

final storesRepositoryProvider = Provider<StoresRepository>((ref) {
  return StoresRepository(ref.watch(firestoreProvider));
});

final storesListProvider = StreamProvider<List<StoreModel>>((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return Stream.value([]);
  return ref.watch(storesRepositoryProvider).watchStores(communityId);
});

final storeItemsProvider = StreamProvider.family<List<StoreItemModel>, String>((
  ref,
  storeId,
) {
  return ref.watch(storesRepositoryProvider).watchStoreItems(storeId);
});

/// La tienda del usuario actual, si tiene una. Null si no es dueño de
/// ninguna tienda — esta es la capacidad "hasStore", derivada de datos
/// reales (ownerUid) en vez de un rol exclusivo.
final ownerStoreProvider = StreamProvider<StoreModel?>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(null);
  return ref
      .watch(storesRepositoryProvider)
      .getStoresForOwner(user.id)
      .map((list) => list.isEmpty ? null : list.first);
});
```

- [ ] **Step 2: Quitar la definición duplicada de `store_panel_screen.dart` y usar la importada**

En `lib/features/stores/screens/store_panel_screen.dart`, reemplazar las líneas 1-23:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/datetime_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';
import 'package:vecindario_app/features/stores/models/store_item_model.dart';
import 'package:vecindario_app/features/stores/models/store_model.dart';
import 'package:vecindario_app/features/stores/providers/stores_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/widgets/empty_state.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

final storeOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final store = ref.watch(ownerStoreProvider).value;
  final user = ref.watch(currentUserProvider).value;
  if (store == null || user == null) return Stream.value([]);
  return ref
      .watch(storesRepositoryProvider)
      .watchStoreOrders(store.id, user.id);
});

final storeAllItemsProvider = StreamProvider<List<StoreItemModel>>((ref) {
  final store = ref.watch(ownerStoreProvider).value;
  if (store == null) return Stream.value([]);
  return ref.watch(storesRepositoryProvider).watchAllStoreItems(store.id);
});
```

(Se retiró la definición de `ownerStoreProvider` porque ahora vive en `stores_provider.dart`, que ya está importado. El resto del archivo, desde `class StorePanelScreen extends ConsumerWidget {`, no cambia.)

- [ ] **Step 3: Verificar**

Run: `flutter analyze lib/features/stores`
Expected: sin errores.

Run: `flutter test`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/features/stores/providers/stores_provider.dart lib/features/stores/screens/store_panel_screen.dart
git commit -m "refactor(stores): mover ownerStoreProvider a stores_provider.dart"
```

---

## Task 4: Capacidad "ofrece un servicio" — `getServicesForOwner` + `ownerServiceProvider`

`services_repository.dart` no tiene un método simétrico a `getStoresForOwner`. Se agrega con TDD.

**Files:**
- Modify: `lib/features/services/repositories/services_repository.dart`
- Modify: `lib/features/services/providers/services_provider.dart`
- Test: `test/repositories/services_repository_test.dart`

**Interfaces:**
- Produces: `ServicesRepository.getServicesForOwner(String ownerUid)` (`Stream<List<ServiceModel>>`), `ownerServiceProvider` (`StreamProvider<ServiceModel?>`).

- [ ] **Step 1: Escribir el test que falla**

Agregar al final del `group('ServicesRepository', ...)` en `test/repositories/services_repository_test.dart`, antes del cierre `});` final del grupo:

```dart
    test('getServicesForOwner devuelve solo los servicios del dueño', () async {
      await fakeFirestore.collection('services').doc('s1').set({
        'communityId': 'comm1',
        'title': 'Plomería Juan',
        'category': 'hogar',
        'active': true,
        'ownerUid': 'owner1',
        'ownerName': 'Juan',
        'description': 'desc',
        'imageURLs': [],
        'rating': 0,
        'ratingCount': 0,
        'orderCount': 0,
        'createdAt': DateTime(2026, 4, 1),
      });

      await fakeFirestore.collection('services').doc('s2').set({
        'communityId': 'comm1',
        'title': 'Belleza María',
        'category': 'belleza',
        'active': true,
        'ownerUid': 'owner2',
        'ownerName': 'María',
        'description': 'desc',
        'imageURLs': [],
        'rating': 0,
        'ratingCount': 0,
        'orderCount': 0,
        'createdAt': DateTime(2026, 4, 1),
      });

      final owned = await repo.getServicesForOwner('owner1').first;
      expect(owned.length, 1);
      expect(owned.first.ownerUid, 'owner1');
    });
```

- [ ] **Step 2: Correr el test y verificar que falla**

Run: `flutter test test/repositories/services_repository_test.dart`
Expected: FAIL — `getServicesForOwner` no existe en `ServicesRepository`.

- [ ] **Step 3: Implementar el método**

Agregar a `lib/features/services/repositories/services_repository.dart`, después de `getService`:

```dart
  Stream<List<ServiceModel>> getServicesForOwner(String ownerUid) {
    return _firestore
        .collection(FirestorePaths.services)
        .where('ownerUid', isEqualTo: ownerUid)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ServiceModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }
```

- [ ] **Step 4: Correr el test y verificar que pasa**

Run: `flutter test test/repositories/services_repository_test.dart`
Expected: PASS

- [ ] **Step 5: Agregar `ownerServiceProvider` a `services_provider.dart`**

Agregar al final de `lib/features/services/providers/services_provider.dart`:

```dart
import 'package:vecindario_app/shared/providers/current_user_provider.dart' show currentUserProvider;

/// El primer servicio ofrecido por el usuario actual, si tiene alguno. Null
/// si no ofrece ningún servicio — capacidad "offersService", derivada de
/// datos reales (ownerUid) en vez de un rol exclusivo.
final ownerServiceProvider = StreamProvider<ServiceModel?>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(null);
  return ref
      .watch(servicesRepositoryProvider)
      .getServicesForOwner(user.id)
      .map((list) => list.isEmpty ? null : list.first);
});
```

Nota: `current_user_provider.dart` ya se importa como `currentCommunityIdProvider` en la línea 5 del archivo original (`import 'package:vecindario_app/shared/providers/current_user_provider.dart';` sin `show`) — usar esa misma línea de import existente en vez de duplicarla; solo agregar el provider nuevo al final del archivo.

- [ ] **Step 6: Verificar**

Run: `flutter analyze lib/features/services`
Expected: sin errores.

Run: `flutter test`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add lib/features/services/repositories/services_repository.dart lib/features/services/providers/services_provider.dart test/repositories/services_repository_test.dart
git commit -m "feat(services): agregar getServicesForOwner para derivar capacidad offersService"
```

---

## Task 5: `capabilities_provider.dart` — `hasStoreProvider` / `offersServiceProvider`

**Files:**
- Create: `lib/shared/providers/capabilities_provider.dart`

**Interfaces:**
- Consumes: `ownerStoreProvider` (Task 3), `ownerServiceProvider` (Task 4).
- Produces: `hasStoreProvider` (`Provider<bool>`), `offersServiceProvider` (`Provider<bool>`).

- [ ] **Step 1: Crear el archivo**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/features/services/providers/services_provider.dart';
import 'package:vecindario_app/features/stores/providers/stores_provider.dart';

/// Capacidades del usuario actual que no son roles exclusivos: un residente
/// (o un admin) puede tener una tienda y ofrecer un servicio a la vez, sin
/// dejar de ser residente. Se derivan de datos reales (ownerUid en stores y
/// services), no de un campo de rol.

final hasStoreProvider = Provider<bool>((ref) {
  return ref.watch(ownerStoreProvider).valueOrNull != null;
});

final offersServiceProvider = Provider<bool>((ref) {
  return ref.watch(ownerServiceProvider).valueOrNull != null;
});
```

- [ ] **Step 2: Verificar**

Run: `flutter analyze lib/shared/providers/capabilities_provider.dart`
Expected: sin errores.

- [ ] **Step 3: Commit**

```bash
git add lib/shared/providers/capabilities_provider.dart
git commit -m "feat(roles): agregar capabilities_provider (hasStore, offersService)"
```

---

## Task 6: Actualizar call sites de UI que leían el rol viejo

**Files:**
- Modify: `lib/features/feed/screens/feed_screen.dart:158`
- Modify: `lib/features/profile/screens/profile_screen.dart`
- Modify: `lib/features/super_admin/screens/super_admin_panel_screen.dart:23`
- Modify: `lib/features/super_admin/repositories/super_admin_repository.dart:72` (gap encontrado en revisión crítica al ejecutar: `assignAdmin` escribe `'role': 'admin'` directo en Firestore, fuera de `UserModel.toFirestore()`)
- Modify: `test/repositories/super_admin_repository_test.dart:86,95`

**Interfaces:**
- Consumes: `hasStoreProvider` (Task 5), `isAdminProvider`/`isSuperAdminProvider` (Task 2), `UserModel.isSuperAdmin` (Task 1).

- [ ] **Step 1: `feed_screen.dart`**

En `lib/features/feed/screens/feed_screen.dart`, agregar el import:

```dart
import 'package:vecindario_app/shared/providers/capabilities_provider.dart';
```

Dentro del `build`, agregar (junto a donde ya se lee `isAdmin`):

```dart
final hasStore = ref.watch(hasStoreProvider);
```

Reemplazar la línea 158:

```dart
          if (userAsync.value?.role == UserRole.storeOwner)
```

por:

```dart
          if (hasStore)
```

- [ ] **Step 2: `profile_screen.dart`**

Agregar el import:

```dart
import 'package:vecindario_app/shared/providers/capabilities_provider.dart';
```

Dentro del `build`, agregar junto a `isAdmin`:

```dart
final hasStore = ref.watch(hasStoreProvider);
```

Reemplazar el bloque de las líneas 65-96 (las dos secciones separadas "Plataforma" → `/super-admin` y "Administración" → `/admin`, más "Vecindario Admin" → `/premium`) por una única fusión:

```dart
              // Super Admin (plataforma)
              if (user.isSuperAdmin) ...[
                const Divider(),
                _SectionTitle('Plataforma'),
                _SettingsTile(
                  icon: Icons.shield,
                  title: 'Super Admin Panel',
                  subtitle: 'Gestionar comunidades y clientes',
                  onTap: () => context.push('/super-admin'),
                ),
              ],
              // Administración del conjunto (fusiona lo que antes eran dos
              // entradas separadas: panel admin y Vecindario Admin)
              if (isAdmin) ...[
                const Divider(),
                _SectionTitle('Administración'),
                _SettingsTile(
                  icon: Icons.business,
                  title: 'Administración del conjunto',
                  subtitle: 'Aprobaciones, circulares, multas, finanzas, PQRS y más',
                  onTap: () => context.push('/premium'),
                ),
              ],
```

Reemplazar la línea 98 (`if (user.role != UserRole.superAdmin &&`) por:

```dart
              if (!user.isSuperAdmin && user.communityId != null) ...[
```

Reemplazar la línea 144 (`if (user.role == UserRole.storeOwner) ...[`) por:

```dart
              if (hasStore) ...[
```

- [ ] **Step 3: `super_admin_panel_screen.dart`**

Reemplazar la línea 23:

```dart
    if (user == null || user.role.toValue() != 'super_admin') {
```

por:

```dart
    if (user == null || !user.isSuperAdmin) {
```

- [ ] **Step 4: Verificar**

Run: `flutter analyze`
Expected: sin errores (ya no debe quedar ninguna referencia a `UserRole` en `lib/`).

Run: `grep -rn "UserRole" lib --include="*.dart"` (o buscar con la herramienta Grep)
Expected: sin resultados.

Run: `flutter test`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/feed/screens/feed_screen.dart lib/features/profile/screens/profile_screen.dart lib/features/super_admin/screens/super_admin_panel_screen.dart
git commit -m "refactor(roles): migrar UI de UserRole a communityRole/platformRole/capabilities"
```

---

## Task 7: Fusionar `AdminPanelScreen` dentro de `AdminShell` y eliminar `/admin`

`AdminPanelScreen` (ruta `/admin`) y `_AdminHomePage` dentro de `AdminShell` (ruta `/premium`) hoy muestran contenido redundante (código de invitación, solicitudes pendientes, accesos rápidos). Se fusiona todo en `_AdminHomePage` y se elimina el panel duplicado.

**Files:**
- Modify: `lib/features/premium/screens/admin_shell.dart`
- Delete: `lib/features/admin/screens/admin_panel_screen.dart`

**Interfaces:**
- Consumes: `pendingResidentsProvider`, `currentCommunityIdProvider`, `currentCommunityProvider`, `communityRepositoryProvider` (`firebase_providers.dart`), `subscriptionPlanProvider`, `allPqrsProvider`, `monthlyRevenueProvider`, `cloudFunctionsProvider` (todos ya existentes, sin cambios de firma).

- [ ] **Step 1: Reescribir `lib/features/premium/screens/admin_shell.dart`**

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/premium/circulars/screens/circulars_screen.dart';
import 'package:vecindario_app/features/premium/finances/screens/finances_screen.dart';
import 'package:vecindario_app/features/premium/amenities/screens/amenities_screen.dart';
import 'package:vecindario_app/features/premium/pqrs/screens/pqrs_screen.dart';
import 'package:vecindario_app/features/premium/providers/premium_provider.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/features/admin/providers/admin_providers.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/community_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';
import 'package:vecindario_app/shared/services/cloud_functions_service.dart';
import 'package:go_router/go_router.dart';

/// Shell del módulo único de Administración del conjunto — fusiona lo que
/// antes eran dos paneles separados (/admin y /premium). 5 tabs según
/// wireframe: Inicio | Circulares | Finanzas | Zonas | PQRS.
class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _AdminHomePage(),
      const CircularsScreen(),
      const FinancesScreen(),
      const AmenitiesScreen(),
      const PqrsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.success,
        unselectedItemColor: AppColors.textHint,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            activeIcon: Icon(Icons.campaign),
            label: 'Circulares',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_outlined),
            activeIcon: Icon(Icons.account_balance),
            label: 'Finanzas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pool_outlined),
            activeIcon: Icon(Icons.pool),
            label: 'Zonas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'PQRS',
          ),
        ],
      ),
    );
  }
}

String _generateInviteCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final rng = Random();
  return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
}

/// Página de inicio del admin: código de invitación, stats, solicitudes
/// pendientes y accesos rápidos a todos los módulos (incluye lo que antes
/// vivía en el panel /admin separado: aprobaciones y configuración).
class _AdminHomePage extends ConsumerWidget {
  const _AdminHomePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityAsync = ref.watch(currentCommunityProvider);
    final communityId = ref.watch(currentCommunityIdProvider);
    final plan = ref.watch(subscriptionPlanProvider).value;
    final pendingAsync = ref.watch(pendingResidentsProvider);
    final pqrsAsync = ref.watch(allPqrsProvider);
    final revenue = communityId != null
        ? ref.watch(monthlyRevenueProvider(communityId)).value ?? 0
        : 0;

    final communityName = communityAsync.value?.name ?? 'Mi comunidad';
    final memberCount = communityAsync.value?.memberCount ?? 0;
    final openPqrs =
        pqrsAsync.value
            ?.where(
              (p) => p.status.name != 'resolved' && p.status.name != 'closed',
            )
            .length ??
        0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/feed');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vecindario Admin',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.success,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              communityName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                pendingAsync.when(
                  data: (list) => list.isNotEmpty
                      ? Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${list.length}',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            tooltip: 'Solicitudes pendientes',
            onPressed: () => context.push('/premium/pending'),
          ),
          if (plan != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  plan.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // Código de invitación
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A5F), Color(0xFF1A2744)],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CÓDIGO DE INVITACIÓN',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF60A5FA),
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        communityAsync.value?.inviteCode ?? '------',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _InviteCodeButton(
                      icon: Icons.copy,
                      label: 'Copiar',
                      onTap: () {
                        final code = communityAsync.value?.inviteCode;
                        if (code != null) {
                          Clipboard.setData(ClipboardData(text: code));
                          context.showSuccessSnackBar('Código copiado');
                        }
                      },
                    ),
                    const SizedBox(height: 6),
                    _InviteCodeButton(
                      icon: Icons.refresh,
                      label: 'Rotar',
                      onTap: () async {
                        if (communityId == null) return;
                        final newCode = _generateInviteCode();
                        await ref
                            .read(communityRepositoryProvider)
                            .regenerateInviteCode(communityId, newCode);
                        if (context.mounted) {
                          context.showSuccessSnackBar('Nuevo código: $newCode');
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Stats
          Row(
            children: [
              _StatCard(
                value: '$memberCount',
                label: 'Residentes',
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              _StatCard(
                value: '$openPqrs',
                label: 'PQRS abiertos',
                color: AppColors.warning,
              ),
              const SizedBox(width: 6),
              _StatCard(
                value: _formatCOP(revenue),
                label: 'Recaudo mes',
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          // Acciones rápidas
          Text('ACCIONES RÁPIDAS', style: AppTextStyles.label),
          const SizedBox(height: AppSizes.sm),
          _QuickAction(
            icon: Icons.person_add,
            color: AppColors.primary,
            title: 'Solicitudes pendientes',
            subtitle: 'Aprobar o rechazar residentes',
            onTap: () => context.push('/premium/pending'),
          ),
          _QuickAction(
            icon: Icons.settings,
            color: AppColors.textSecondary,
            title: 'Configuración de comunidad',
            subtitle: 'Nombre, código de invitación, estrato',
            onTap: () => context.push('/premium/settings'),
          ),
          _QuickAction(
            icon: Icons.campaign,
            color: AppColors.info,
            title: 'Nueva Circular',
            subtitle: 'Enviar comunicado oficial',
            onTap: () => context.push('/premium/circulars/create'),
          ),
          _QuickAction(
            icon: Icons.warning_amber,
            color: AppColors.error,
            title: 'Registrar Multa',
            subtitle: 'Crear sanción con evidencia',
            onTap: () => context.push('/premium/fines/create'),
          ),
          _QuickAction(
            icon: Icons.account_balance,
            color: AppColors.success,
            title: 'Finanzas',
            subtitle: 'Presupuesto y ejecución',
            onTap: () => context.push('/premium/finances'),
          ),
          _QuickAction(
            icon: Icons.how_to_vote,
            color: const Color(0xFF8B5CF6),
            title: 'Convocar Asamblea',
            subtitle: 'Crear convocatoria con agenda',
            onTap: () => context.push('/premium/assemblies'),
          ),

          const SizedBox(height: AppSizes.lg),

          // Solicitudes pendientes
          pendingAsync.when(
            data: (pending) {
              if (pending.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SOLICITUDES PENDIENTES (${pending.length})',
                    style: AppTextStyles.label,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  ...pending
                      .take(5)
                      .map(
                        (user) => Card(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              child: Text(
                                user.displayName.isNotEmpty
                                    ? user.displayName[0]
                                    : '?',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            title: Text(
                              user.displayName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'T${user.tower ?? '-'} · Apto ${user.apartment ?? '-'}',
                              style: AppTextStyles.caption,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _MiniButton(
                                  icon: Icons.check,
                                  color: AppColors.success,
                                  onTap: () async {
                                    final communityId = ref.read(
                                      currentCommunityIdProvider,
                                    );
                                    if (communityId != null) {
                                      await ref
                                          .read(cloudFunctionsProvider)
                                          .approveResident(
                                            user.id,
                                            communityId,
                                          );
                                    }
                                  },
                                ),
                                const SizedBox(width: 4),
                                _MiniButton(
                                  icon: Icons.close,
                                  color: AppColors.textHint,
                                  onTap: () async {
                                    final communityId = ref.read(
                                      currentCommunityIdProvider,
                                    );
                                    if (communityId != null) {
                                      await ref
                                          .read(cloudFunctionsProvider)
                                          .rejectResident(user.id, communityId);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(fontSize: 9, color: AppColors.textHint),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textHint,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _MiniButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}

class _InviteCodeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _InviteCodeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: const Color(0xFF60A5FA)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF60A5FA),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatCOP(int cop) {
  if (cop == 0) return '\$0';
  if (cop >= 1000000) {
    final m = cop / 1000000;
    return '\$${m.toStringAsFixed(m >= 10 ? 0 : 1)}M';
  }
  if (cop >= 1000) {
    final k = cop / 1000;
    return '\$${k.toStringAsFixed(k >= 10 ? 0 : 1)}K';
  }
  return '\$$cop';
}
```

- [ ] **Step 2: Eliminar el panel duplicado**

```bash
git rm lib/features/admin/screens/admin_panel_screen.dart
```

- [ ] **Step 3: Verificar (fallará hasta Task 8, que actualiza el router — es esperado)**

Run: `flutter analyze lib/features/premium/screens/admin_shell.dart`
Expected: sin errores en este archivo. El proyecto completo puede seguir marcando error en `app_router.dart` porque todavía importa `admin_panel_screen.dart` — se corrige en el siguiente task, no hacer commit todavía si `flutter analyze` falla por esa razón.

- [ ] **Step 4: Commit**

```bash
git add lib/features/premium/screens/admin_shell.dart
git commit -m "refactor(admin): fusionar AdminPanelScreen dentro de AdminShell"
```

---

## Task 8: Partir el router en `resident_routes.dart` / `community_admin_routes.dart` / `super_admin_routes.dart`

**Files:**
- Create: `lib/core/router/resident_routes.dart`
- Create: `lib/core/router/community_admin_routes.dart`
- Create: `lib/core/router/super_admin_routes.dart`
- Modify: `lib/core/router/app_router.dart`

**Interfaces:**
- Consumes: `hasStoreProvider` (Task 5), `UserModel.isAdmin/.isSuperAdmin` (Task 1).
- Produces: `residentRoutes`, `communityAdminRoutes`, `superAdminRoutes` (todos `List<RouteBase>`), importados y expandidos (`...`) dentro de `routerProvider`.

- [ ] **Step 1: Crear `lib/core/router/resident_routes.dart`**

```dart
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/features/external_services/screens/external_services_screen.dart';
import 'package:vecindario_app/features/external_services/screens/recommend_external_service_screen.dart';
import 'package:vecindario_app/features/feed/screens/create_post_screen.dart';
import 'package:vecindario_app/features/feed/screens/feed_screen.dart';
import 'package:vecindario_app/features/feed/screens/feed_detail_screen.dart';
import 'package:vecindario_app/features/home/screens/home_shell.dart';
import 'package:vecindario_app/features/notifications/screens/notifications_screen.dart';
import 'package:vecindario_app/features/profile/screens/privacy_screen.dart';
import 'package:vecindario_app/features/profile/screens/profile_screen.dart';
import 'package:vecindario_app/features/profile/screens/edit_profile_screen.dart';
import 'package:vecindario_app/features/profile/screens/terms_screen.dart';
import 'package:vecindario_app/features/profile/screens/privacy_policy_screen.dart';
import 'package:vecindario_app/features/services/screens/services_screen.dart';
import 'package:vecindario_app/features/services/screens/create_service_screen.dart';
import 'package:vecindario_app/features/services/screens/service_detail_screen.dart';
import 'package:vecindario_app/features/stores/screens/stores_screen.dart';
import 'package:vecindario_app/features/stores/screens/store_detail_screen.dart';
import 'package:vecindario_app/features/stores/screens/order_tracking_screen.dart';
import 'package:vecindario_app/features/stores/screens/my_orders_screen.dart';
import 'package:vecindario_app/features/stores/screens/store_panel_screen.dart';
import 'package:vecindario_app/features/stores/screens/rate_order_screen.dart';

/// Rutas de la experiencia "residente": el shell de 4 tabs (Noticias,
/// Vecinos, Tiendas, Servicios Externos) y las pantallas globales de
/// perfil/tienda/notificaciones. communityRole == resident y
/// communityRole == admin comparten este shell — un admin también vive el
/// conjunto como residente. La entrada a administración vive en
/// community_admin_routes.dart, bajo /premium.
final List<RouteBase> residentRoutes = [
  StatefulShellRoute.indexedStack(
    builder: (_, __, navigationShell) =>
        HomeShell(navigationShell: navigationShell),
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/feed',
            builder: (_, __) => const FeedScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (_, __) => const CreatePostScreen(),
              ),
              GoRoute(
                path: ':postId',
                builder: (_, state) => FeedDetailScreen(
                  postId: state.pathParameters['postId'] ?? '',
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/services',
            builder: (_, __) => const ServicesScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (_, __) => const CreateServiceScreen(),
              ),
              GoRoute(
                path: ':serviceId',
                builder: (_, state) => ServiceDetailScreen(
                  serviceId: state.pathParameters['serviceId'] ?? '',
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/stores',
            builder: (_, __) => const StoresScreen(),
            routes: [
              GoRoute(
                path: 'orders',
                builder: (_, __) => const MyOrdersScreen(),
              ),
              GoRoute(
                path: 'order/:orderId',
                builder: (_, state) => OrderTrackingScreen(
                  orderId: state.pathParameters['orderId'] ?? '',
                ),
              ),
              GoRoute(
                path: 'rate/:orderId',
                builder: (_, state) => RateOrderScreen(
                  orderId: state.pathParameters['orderId'] ?? '',
                ),
              ),
              GoRoute(
                path: ':storeId',
                builder: (_, state) => StoreDetailScreen(
                  storeId: state.pathParameters['storeId'] ?? '',
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/external-services',
            builder: (_, __) => const ExternalServicesScreen(),
            routes: [
              GoRoute(
                path: 'recommend',
                builder: (_, __) => const RecommendExternalServiceScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  GoRoute(
    path: '/profile',
    builder: (_, __) => const ProfileScreen(),
    routes: [
      GoRoute(path: 'edit', builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: 'privacy', builder: (_, __) => const PrivacyScreen()),
      GoRoute(path: 'terms', builder: (_, __) => const TermsScreen()),
      GoRoute(
        path: 'privacy-policy',
        builder: (_, __) => const PrivacyPolicyScreen(),
      ),
    ],
  ),
  GoRoute(path: '/store-panel', builder: (_, __) => const StorePanelScreen()),
  GoRoute(
    path: '/notifications',
    builder: (_, __) => const NotificationsScreen(),
  ),
];
```

- [ ] **Step 2: Crear `lib/core/router/community_admin_routes.dart`**

```dart
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/features/admin/screens/community_settings_screen.dart';
import 'package:vecindario_app/features/admin/screens/pending_approvals_screen.dart';
import 'package:vecindario_app/features/premium/circulars/screens/circulars_screen.dart';
import 'package:vecindario_app/features/premium/circulars/screens/create_circular_screen.dart';
import 'package:vecindario_app/features/premium/fines/screens/fines_screen.dart';
import 'package:vecindario_app/features/premium/fines/screens/create_fine_screen.dart';
import 'package:vecindario_app/features/premium/fines/screens/fine_detail_screen.dart';
import 'package:vecindario_app/features/premium/amenities/screens/amenities_screen.dart';
import 'package:vecindario_app/features/premium/amenities/screens/create_amenity_screen.dart';
import 'package:vecindario_app/features/premium/finances/screens/create_finance_entry_screen.dart';
import 'package:vecindario_app/features/premium/finances/screens/finances_screen.dart';
import 'package:vecindario_app/features/premium/finances/screens/account_statement_screen.dart';
import 'package:vecindario_app/features/premium/pqrs/screens/pqrs_screen.dart';
import 'package:vecindario_app/features/premium/pqrs/screens/create_pqrs_screen.dart';
import 'package:vecindario_app/features/premium/assemblies/screens/assemblies_screen.dart';
import 'package:vecindario_app/features/premium/assemblies/screens/assembly_detail_screen.dart';
import 'package:vecindario_app/features/premium/assemblies/screens/create_assembly_screen.dart';
import 'package:vecindario_app/features/premium/manual/screens/manual_screen.dart';
import 'package:vecindario_app/features/premium/screens/admin_shell.dart';
import 'package:vecindario_app/features/premium/screens/premium_dashboard_screen.dart';
import 'package:vecindario_app/features/premium/subscriptions/screens/subscription_plans_screen.dart';

/// Rutas del módulo único de "Administración del conjunto" — fusiona lo que
/// antes eran dos paneles separados (/admin y /premium: PendingApprovals y
/// CommunitySettings vivían bajo /admin, ahora cuelgan de /premium). El
/// guard fino (communityRole == admin || platformRole == super_admin) vive
/// en app_router.dart.
final List<RouteBase> communityAdminRoutes = [
  GoRoute(path: '/premium', builder: (_, __) => const AdminShell()),
  GoRoute(
    path: '/premium/dashboard',
    builder: (_, __) => const PremiumDashboardScreen(),
  ),
  GoRoute(
    path: '/premium/pending',
    builder: (_, __) => const PendingApprovalsScreen(),
  ),
  GoRoute(
    path: '/premium/settings',
    builder: (_, __) => const CommunitySettingsScreen(),
  ),
  GoRoute(
    path: '/premium/circulars',
    builder: (_, __) => const CircularsScreen(),
  ),
  GoRoute(
    path: '/premium/circulars/create',
    builder: (_, __) => const CreateCircularScreen(),
  ),
  GoRoute(path: '/premium/fines', builder: (_, __) => const FinesScreen()),
  GoRoute(
    path: '/premium/fines/create',
    builder: (_, __) => const CreateFineScreen(),
  ),
  GoRoute(
    path: '/premium/fines/:fineId',
    builder: (_, state) =>
        FineDetailScreen(fineId: state.pathParameters['fineId'] ?? ''),
  ),
  GoRoute(path: '/premium/pqrs', builder: (_, __) => const PqrsScreen()),
  GoRoute(
    path: '/premium/pqrs/create',
    builder: (_, __) => const CreatePqrsScreen(),
  ),
  GoRoute(
    path: '/premium/amenities',
    builder: (_, __) => const AmenitiesScreen(),
  ),
  GoRoute(
    path: '/premium/amenities/create',
    builder: (_, __) => const CreateAmenityScreen(),
  ),
  GoRoute(
    path: '/premium/finances',
    builder: (_, __) => const FinancesScreen(),
  ),
  GoRoute(
    path: '/premium/finances/create',
    builder: (_, __) => const CreateFinanceEntryScreen(),
  ),
  GoRoute(
    path: '/premium/account-statement',
    builder: (_, __) => const AccountStatementScreen(),
  ),
  GoRoute(path: '/premium/manual', builder: (_, __) => const ManualScreen()),
  GoRoute(
    path: '/premium/assemblies',
    builder: (_, __) => const AssembliesScreen(),
  ),
  GoRoute(
    path: '/premium/assemblies/create',
    builder: (_, __) => const CreateAssemblyScreen(),
  ),
  GoRoute(
    path: '/premium/assemblies/:assemblyId',
    builder: (_, state) => AssemblyDetailScreen(
      assemblyId: state.pathParameters['assemblyId'] ?? '',
    ),
  ),
  GoRoute(
    path: '/premium/plans',
    builder: (_, __) => const SubscriptionPlansScreen(),
  ),
];
```

- [ ] **Step 3: Crear `lib/core/router/super_admin_routes.dart`**

```dart
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/features/super_admin/screens/community_detail_admin_screen.dart';
import 'package:vecindario_app/features/super_admin/screens/create_community_screen.dart';
import 'package:vecindario_app/features/super_admin/screens/super_admin_panel_screen.dart';

/// Rutas del panel de plataforma, exclusivas de platformRole == super_admin.
final List<RouteBase> superAdminRoutes = [
  GoRoute(
    path: '/super-admin',
    builder: (_, __) => const SuperAdminPanelScreen(),
    routes: [
      GoRoute(
        path: 'create-community',
        builder: (_, __) => const CreateCommunityScreen(),
      ),
      GoRoute(
        path: 'community/:communityId',
        builder: (_, state) => CommunityDetailAdminScreen(
          communityId: state.pathParameters['communityId'] ?? '',
        ),
      ),
    ],
  ),
];
```

- [ ] **Step 4: Reescribir `lib/core/router/app_router.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/router/community_admin_routes.dart';
import 'package:vecindario_app/core/router/resident_routes.dart';
import 'package:vecindario_app/core/router/super_admin_routes.dart';
import 'package:vecindario_app/features/auth/screens/forgot_password_screen.dart';
import 'package:vecindario_app/features/auth/screens/join_community_screen.dart';
import 'package:vecindario_app/features/auth/screens/login_screen.dart';
import 'package:vecindario_app/features/auth/screens/pending_approval_screen.dart';
import 'package:vecindario_app/features/auth/screens/phone_verification_screen.dart';
import 'package:vecindario_app/features/auth/screens/register_screen.dart';
import 'package:vecindario_app/features/onboarding/screens/onboarding_screen.dart';
import 'package:vecindario_app/shared/providers/capabilities_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

/// Ensambla las rutas de los 3 perfiles (resident_routes, community_admin_routes,
/// super_admin_routes) y retiene solo el guard de alto nivel: login, unirse a
/// comunidad, aprobación pendiente, y el enrutamiento forzado por perfil. El
/// guard fino de cada sección (ej. "/premium requiere isAdmin") vive aquí
/// porque depende del estado global de auth/usuario que ya está siendo
/// observado por routerProvider.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final currentUser = ref.watch(currentUserProvider);
  final hasStore = ref.watch(hasStoreProvider);

  return GoRouter(
    initialLocation: '/feed',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/onboarding' ||
          state.matchedLocation.startsWith('/verify-phone');

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) {
        final user = currentUser.valueOrNull;
        if (user == null) return null;
        if (user.isSuperAdmin) return '/super-admin';
        if (user.communityId == null) return '/join-community';
        if (!user.verified) return '/pending-approval';
        return '/feed';
      }

      if (isLoggedIn) {
        final user = currentUser.valueOrNull;
        final isLoading = currentUser.isLoading;

        // super_admin siempre vive en /super-admin (excepto /profile)
        if (user != null && user.isSuperAdmin) {
          final isSuperAdminArea = state.matchedLocation.startsWith(
            '/super-admin',
          );
          final isProfileArea = state.matchedLocation.startsWith('/profile');
          if (!isSuperAdminArea && !isProfileArea) {
            return '/super-admin';
          }
        }

        // Todo usuario de comunidad (resident o admin) debe unirse primero,
        // y esperar aprobación si aún no está verificado.
        if (user != null && !user.isSuperAdmin) {
          final onJoin = state.matchedLocation == '/join-community';
          final onPending = state.matchedLocation == '/pending-approval';
          if (user.communityId == null && !onJoin) {
            return '/join-community';
          }
          if (user.communityId != null && !user.verified && !onPending) {
            return '/pending-approval';
          }
        }

        // Guard: /premium (Administración del conjunto) solo para
        // communityRole == admin o super_admin de plataforma.
        final isCommunityAdminRoute = state.matchedLocation.startsWith(
          '/premium',
        );
        if (isCommunityAdminRoute && isLoading) return null;
        if (isCommunityAdminRoute && user != null && !user.isAdmin) {
          return '/feed';
        }

        // Guard: /super-admin exclusivo para super_admin de plataforma
        final isSuperAdminRoute = state.matchedLocation.startsWith(
          '/super-admin',
        );
        if (isSuperAdminRoute && isLoading) return '/feed';
        if (isSuperAdminRoute && user != null && !user.isSuperAdmin) {
          return '/feed';
        }

        // Guard: /store-panel solo para quien tiene al menos una tienda
        // propia (capacidad derivada de datos, ya no un rol exclusivo).
        final isStorePanel = state.matchedLocation.startsWith('/store-panel');
        if (isStorePanel && !hasStore) {
          return '/feed';
        }
      }

      return null;
    },
    routes: [
      // Rutas públicas
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-phone/:phone',
        builder: (_, state) => PhoneVerificationScreen(
          phoneNumber: state.pathParameters['phone'] ?? '',
        ),
      ),
      GoRoute(
        path: '/join-community',
        builder: (_, __) => const JoinCommunityScreen(),
      ),
      GoRoute(
        path: '/pending-approval',
        builder: (_, __) => const PendingApprovalScreen(),
      ),
      ...residentRoutes,
      ...communityAdminRoutes,
      ...superAdminRoutes,
    ],
  );
});
```

Nota sobre el guard de `/store-panel`: antes de este cambio dependía de un rol estático (`role.toValue() != 'store_owner'`), lo que ya era incorrecto porque `firestore.rules` nunca exigió ese rol para crear una tienda (`allow create: if isVerified();`). El nuevo guard usa `hasStoreProvider`, que sí refleja si el usuario tiene una tienda real. Como `hasStore` empieza en `false` mientras el stream carga, hay un instante donde un dueño de tienda que abre `/store-panel` directo (deep link) podría rebotar a `/feed` antes de que cargue el dato — comportamiento aceptable para este alcance (ya existía una ventana de carga similar en el guard viejo vía `isLoading`); no se resuelve aquí por ser un caso límite fuera del foco de este plan.

- [ ] **Step 5: Verificar**

Run: `flutter analyze`
Expected: sin errores.

Run: `flutter test`
Expected: PASS

Run: `dart format lib/core/router lib/features/premium/screens/admin_shell.dart lib/features/profile/screens/profile_screen.dart lib/features/feed/screens/feed_screen.dart`
Expected: aplica formato exigido por CI sin romper nada.

- [ ] **Step 6: Commit**

```bash
git add lib/core/router
git commit -m "refactor(router): partir app_router.dart por perfil (resident/community_admin/super_admin)"
```

---

## Task 9: Firestore Security Rules — `communityRole` / `platformRole`

**Files:**
- Modify: `firestore.rules`

**Interfaces:**
- Produces: funciones helper `isCommunityAdmin(communityId)` e `isSuperAdmin()` con la misma firma, ahora leyendo `communityRole`/`platformRole`.

- [ ] **Step 1: Actualizar las funciones helper**

Reemplazar las líneas 22-37 de `firestore.rules`:

```
    function isCommunityAdmin(communityId) {
      return isCommunityMember(communityId) && getUserData().communityRole == 'admin';
    }

    function isVerified() {
      return isAuthenticated() && getUserData().verified == true;
    }

    function isVerifiedMember(communityId) {
      return isCommunityMember(communityId)
        && (getUserData().verified == true || getUserData().communityRole == 'admin');
    }

    function isSuperAdmin() {
      return isAuthenticated() && getUserData().platformRole == 'super_admin';
    }
```

- [ ] **Step 2: Actualizar los campos protegidos de `users/{uid}`**

Reemplazar la línea 44-45:

```
      allow update: if isOwner(uid)
        && !request.resource.data.diff(resource.data).affectedKeys()
            .hasAny(['verified', 'communityRole', 'platformRole']);
```

(El resto de `firestore.rules` no cambia — todas las demás reglas ya llamaban a `isCommunityAdmin(...)` / `isSuperAdmin()` por función, no leían `role` directamente.)

- [ ] **Step 3: Validar sintaxis de las reglas**

Run: `firebase deploy --only firestore:rules --dry-run` (si el usuario tiene Firebase CLI autenticado y el proyecto linkeado; si no, pedir al usuario que lo corra manualmente antes de continuar — no desplegar reglas sin confirmación explícita, es una acción que afecta el proyecto de Firebase real).

- [ ] **Step 4: Commit**

```bash
git add firestore.rules
git commit -m "refactor(rules): leer communityRole/platformRole en vez de role"
```

**No desplegar estas reglas a Firebase todavía** — se despliegan junto con el resto de cambios al final (Task 12), después de correr el script de migración de datos (Task 11), para no dejar usuarios existentes sin acceso mientras sus documentos aún tienen el campo `role` viejo.

---

## Task 10: Backend Go — 10 call sites de `Data()["role"]`

**Files:**
- Modify: `functions/fn/residents.go` (3 ocurrencias: líneas 73, 149, 213)
- Modify: `functions/fn/amenities.go` (línea 189)
- Modify: `functions/fn/assemblies.go` (línea 53)
- Modify: `functions/fn/circulars.go` (línea 61)
- Modify: `functions/fn/finances.go` (línea 111)
- Modify: `functions/fn/fines.go` (línea 58)
- Modify: `functions/fn/notifications.go` (línea 340)

**Interfaces:**
- No cambia ninguna firma pública — solo el nombre del campo Firestore leído.

- [ ] **Step 1: `residents.go`**

En las 3 ocurrencias, reemplazar:

```go
	callerRole, _ := callerDoc.Data()["role"].(string)
```

por:

```go
	callerRole, _ := callerDoc.Data()["communityRole"].(string)
```

(La comparación `if callerRole != "admin" || ...` no cambia — `"admin"` sigue siendo el valor de comunidad, ahora bajo `communityRole`.)

- [ ] **Step 2: `amenities.go`, `assemblies.go`, `circulars.go`, `finances.go`, `fines.go`**

En cada archivo, reemplazar:

```go
	if err != nil || callerDoc.Data()["role"] != "admin" {
```

por:

```go
	if err != nil || callerDoc.Data()["communityRole"] != "admin" {
```

- [ ] **Step 3: `notifications.go`**

Reemplazar la línea 340:

```go
	iter := fs.Collection("users").Where("communityId", "==", communityID).Where("role", "==", "admin").Documents(ctx)
```

por:

```go
	iter := fs.Collection("users").Where("communityId", "==", communityID).Where("communityRole", "==", "admin").Documents(ctx)
```

- [ ] **Step 4: Verificar**

Run: `cd functions && go build ./...`
Expected: sin errores.

Run: `cd functions && go vet ./...`
Expected: sin errores.

Run: `cd functions && go test ./...`
Expected: PASS (los tests existentes — `fines_test.go`, `orders_test.go`, `payments_test.go`, `payments_checkout_test.go`, `residents_test.go` — no leen el campo `role`/`communityRole` en sus fixtures, así que no requieren cambios).

- [ ] **Step 5: Commit**

```bash
git add functions/fn/residents.go functions/fn/amenities.go functions/fn/assemblies.go functions/fn/circulars.go functions/fn/finances.go functions/fn/fines.go functions/fn/notifications.go
git commit -m "refactor(functions): leer communityRole en vez de role en Cloud Functions"
```

---

## Task 11: Script de migración de datos — `role` → `communityRole`/`platformRole`

Todo lo anterior asume que los documentos existentes en `users/{uid}` ya tienen `communityRole`/`platformRole` en vez de `role`. Falta reescribir los documentos reales de Firestore. Se hace con un script Go de un solo uso, ejecutado manualmente por el usuario contra su proyecto Firebase (no se ejecuta automáticamente desde este plan — requiere credenciales del proyecto real).

**Files:**
- Create: `functions/cmd/migrate_roles/main.go`

**Interfaces:**
- Produce un binario ejecutable manualmente (`go run ./cmd/migrate_roles`), no expone ninguna función pública consumida por el resto del código.

- [ ] **Step 1: Crear el script**

```go
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
```

- [ ] **Step 2: Verificar que compila**

Run: `cd functions && go build ./cmd/migrate_roles`
Expected: compila sin errores.

- [ ] **Step 3: Commit**

```bash
git add functions/cmd/migrate_roles/main.go
git commit -m "feat(functions): agregar script de migración role -> communityRole/platformRole"
```

- [ ] **Step 4: Ejecutar manualmente contra el proyecto real (acción del usuario, no automática)**

Esto **requiere que el usuario lo confirme y lo corra él mismo** (o autorice explícitamente correrlo), porque modifica datos reales de producción:

```bash
cd functions
go run ./cmd/migrate_roles -project=<PROJECT_ID> -dry-run   # revisar el output primero
go run ./cmd/migrate_roles -project=<PROJECT_ID>              # aplicar de verdad
```

---

## Task 12: Verificación final y despliegue de reglas

**Files:** ninguno (solo comandos de verificación y, si el usuario lo autoriza, deploy).

- [ ] **Step 1: Verificación completa de Flutter**

Run: `flutter analyze`
Expected: 0 errores (se permiten los infos de estilo preexistentes que ya tolera el proyecto).

Run: `flutter test`
Expected: todos los tests en verde, incluyendo los nuevos de `user_model_test.dart` y `services_repository_test.dart`.

Run: `dart format --set-exit-if-changed lib test`
Expected: sin diffs pendientes (si hay, correr `dart format lib test` sin el flag y volver a commitear).

- [ ] **Step 2: Verificación completa de Go**

Run: `cd functions && go build ./... && go vet ./... && go test ./...`
Expected: todo en verde.

- [ ] **Step 3: Confirmar con el usuario antes de desplegar reglas de Firestore**

Las nuevas `firestore.rules` (Task 9) solo deben desplegarse **después** de correr el script de migración (Task 11, Step 4) contra el proyecto real — si se despliegan antes, los usuarios existentes (que todavía tienen `role` en vez de `communityRole`) perderían permisos de admin/super_admin hasta que se migren. Preguntar al usuario si ya corrió la migración antes de ejecutar:

```bash
firebase deploy --only firestore:rules
```

- [ ] **Step 4: Commit final de verificación (si `dart format` generó cambios)**

```bash
git add -A
git commit -m "style: aplicar dart format tras la rearquitectura de roles"
```
