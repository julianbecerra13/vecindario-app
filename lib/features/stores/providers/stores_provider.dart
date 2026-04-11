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

final storeItemsProvider =
    StreamProvider.family<List<StoreItemModel>, String>((ref, storeId) {
  return ref.watch(storesRepositoryProvider).watchStoreItems(storeId);
});
