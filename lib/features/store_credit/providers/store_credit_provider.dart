import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/features/store_credit/repositories/store_credit_repository.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';

final storeCreditRepositoryProvider = Provider<StoreCreditRepository>(
  (ref) => StoreCreditRepository(ref.watch(firestoreProvider)),
);
