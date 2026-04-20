import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/features/external_services/models/external_service_model.dart';
import 'package:vecindario_app/features/external_services/repositories/external_services_repository.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';

final externalServicesRepositoryProvider = Provider<ExternalServicesRepository>(
  (ref) {
    return ExternalServicesRepository(ref.watch(firestoreProvider));
  },
);

final externalCategoryProvider = StateProvider<ExternalCategory?>(
  (ref) => null,
);

final externalServicesListProvider = StreamProvider<List<ExternalServiceModel>>(
  (ref) {
    final category = ref.watch(externalCategoryProvider);
    return ref
        .watch(externalServicesRepositoryProvider)
        .watchExternalServices(category: category);
  },
);
