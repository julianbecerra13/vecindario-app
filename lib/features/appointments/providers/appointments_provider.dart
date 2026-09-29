import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/features/appointments/models/appointment_model.dart';
import 'package:vecindario_app/features/appointments/repositories/appointments_repository.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';

final appointmentsRepositoryProvider = Provider<AppointmentsRepository>((ref) {
  return AppointmentsRepository(ref.watch(firestoreProvider));
});

final myAppointmentsProvider = StreamProvider<List<AppointmentModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null || user.communityId == null) return const Stream.empty();
  return ref
      .watch(appointmentsRepositoryProvider)
      .watchMine(user.communityId!, user.id);
});
