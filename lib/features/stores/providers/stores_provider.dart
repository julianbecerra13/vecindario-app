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
