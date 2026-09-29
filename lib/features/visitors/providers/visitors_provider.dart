import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/features/visitors/models/visitor_pass_model.dart';
import 'package:vecindario_app/features/visitors/repositories/visitors_repository.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';

final visitorsRepositoryProvider = Provider<VisitorsRepository>(
  (ref) => VisitorsRepository(ref.watch(firestoreProvider)),
);
final myVisitorPassesProvider = StreamProvider<List<VisitorPassModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null || user.communityId == null) return const Stream.empty();
  return ref
      .watch(visitorsRepositoryProvider)
      .watchMine(user.communityId!, user.id);
});
