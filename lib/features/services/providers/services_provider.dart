import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/features/services/models/service_model.dart';
import 'package:vecindario_app/features/services/repositories/services_repository.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  return ServicesRepository(ref.watch(firestoreProvider));
});

final selectedCategoryProvider = StateProvider<ServiceCategory?>((ref) => null);

enum ServiceSortBy { recent, rating, popular }

final serviceSortProvider = StateProvider<ServiceSortBy>(
  (ref) => ServiceSortBy.recent,
);

final serviceSearchProvider = StateProvider<String>((ref) => '');

final servicesListProvider = StreamProvider<List<ServiceModel>>((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return Stream.value([]);
  final category = ref.watch(selectedCategoryProvider);
  final sort = ref.watch(serviceSortProvider);
  final search = ref.watch(serviceSearchProvider).toLowerCase();

  return ref
      .watch(servicesRepositoryProvider)
      .watchServices(communityId, category: category)
      .map((services) {
    var filtered = services;

    // Filtrar por búsqueda
    if (search.isNotEmpty) {
      filtered = filtered
          .where((s) =>
              s.title.toLowerCase().contains(search) ||
              s.description.toLowerCase().contains(search) ||
              s.ownerName.toLowerCase().contains(search))
          .toList();
    }

    // Ordenar
    switch (sort) {
      case ServiceSortBy.rating:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
      case ServiceSortBy.popular:
        filtered.sort((a, b) => b.orderCount.compareTo(a.orderCount));
      case ServiceSortBy.recent:
        break; // Ya viene ordenado por fecha desde Firestore
    }

    return filtered;
  });
});
