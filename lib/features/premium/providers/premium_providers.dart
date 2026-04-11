import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/features/premium/models/circular_model.dart';
import 'package:vecindario_app/features/premium/models/fine_model.dart';
import 'package:vecindario_app/features/premium/models/amenity_model.dart';
import 'package:vecindario_app/features/premium/models/pqrs_model.dart';
import 'package:vecindario_app/features/premium/models/finance_model.dart';
import 'package:vecindario_app/features/premium/providers/premium_repository.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';

final premiumRepositoryProvider = Provider<PremiumRepository>((ref) {
  return PremiumRepository(ref.watch(firestoreProvider));
});

// ==================== CIRCULARES ====================
final circularsProvider = StreamProvider<List<CircularModel>>((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return Stream.value([]);
  return ref.watch(premiumRepositoryProvider).watchCirculars(communityId);
});

// ==================== MULTAS ====================
// Admin: todas las multas
final allFinesProvider = StreamProvider<List<FineModel>>((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return Stream.value([]);
  return ref.watch(premiumRepositoryProvider).watchFines(communityId);
});

// Residente: solo mis multas
final myFinesProvider = StreamProvider<List<FineModel>>((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  final user = ref.watch(currentUserProvider).value;
  if (communityId == null || user == null) return Stream.value([]);
  return ref.watch(premiumRepositoryProvider).watchMyFines(communityId, user.id);
});

// ==================== AMENIDADES ====================
final amenitiesProvider = StreamProvider<List<AmenityModel>>((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return Stream.value([]);
  return ref.watch(premiumRepositoryProvider).watchAmenities(communityId);
});

final myBookingsProvider = StreamProvider<List<BookingModel>>((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  final user = ref.watch(currentUserProvider).value;
  if (communityId == null || user == null) return Stream.value([]);
  return ref
      .watch(premiumRepositoryProvider)
      .watchMyBookings(communityId, user.id);
});

// ==================== PQRS ====================
// Admin: todos
final allPqrsProvider = StreamProvider<List<PqrsModel>>((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return Stream.value([]);
  return ref.watch(premiumRepositoryProvider).watchAllPqrs(communityId);
});

// Residente: solo los míos
final myPqrsProvider = StreamProvider<List<PqrsModel>>((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  final user = ref.watch(currentUserProvider).value;
  if (communityId == null || user == null) return Stream.value([]);
  return ref.watch(premiumRepositoryProvider).watchMyPqrs(communityId, user.id);
});

// ==================== FINANZAS ====================
final financesProvider = StreamProvider<List<FinanceEntryModel>>((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return Stream.value([]);
  return ref.watch(premiumRepositoryProvider).watchFinances(communityId);
});

final myAccountStatementProvider =
    StreamProvider<AccountStatementModel?>((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  final user = ref.watch(currentUserProvider).value;
  if (communityId == null || user == null) return Stream.value(null);
  return ref
      .watch(premiumRepositoryProvider)
      .watchAccountStatement(communityId, user.id);
});

// ==================== DETALLE DE MULTA ====================
final fineDetailProvider =
    StreamProvider.family<FineModel?, String>((ref, fineId) {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return Stream.value(null);
  return ref.watch(premiumRepositoryProvider).watchFine(communityId, fineId);
});

// ==================== ASAMBLEAS ====================
final assembliesProvider = StreamProvider<List<AssemblyModel>>((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return Stream.value([]);
  return ref.watch(premiumRepositoryProvider).watchAssemblies(communityId);
});
