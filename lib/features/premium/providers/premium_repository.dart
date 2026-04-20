import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecindario_app/core/constants/firestore_paths.dart';
import 'package:vecindario_app/features/premium/models/circular_model.dart';
import 'package:vecindario_app/features/premium/models/fine_model.dart';
import 'package:vecindario_app/features/premium/models/amenity_model.dart';
import 'package:vecindario_app/features/premium/models/pqrs_model.dart';
import 'package:vecindario_app/features/premium/models/finance_model.dart';

class PremiumRepository {
  final FirebaseFirestore _firestore;

  PremiumRepository(this._firestore);

  // ==================== CIRCULARES ====================
  Stream<List<CircularModel>> watchCirculars(String communityId) {
    return _firestore
        .collection(FirestorePaths.circulars(communityId))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => CircularModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> createCircular(
    String communityId,
    CircularModel circular,
  ) async {
    await _firestore
        .collection(FirestorePaths.circulars(communityId))
        .add(circular.toFirestore());
  }

  Future<void> markCircularAsRead(
    String communityId,
    String circularId,
    String uid,
  ) async {
    await _firestore
        .collection(FirestorePaths.circulars(communityId))
        .doc(circularId)
        .update({
          'readBy': FieldValue.arrayUnion([
            {'uid': uid, 'timestamp': Timestamp.now()},
          ]),
        });
  }

  Future<void> acknowledgeCircular(
    String communityId,
    String circularId,
    String uid,
  ) async {
    await _firestore
        .collection(FirestorePaths.circulars(communityId))
        .doc(circularId)
        .update({
          'ackBy': FieldValue.arrayUnion([
            {'uid': uid, 'timestamp': Timestamp.now()},
          ]),
        });
  }

  // ==================== MULTAS ====================
  Stream<List<FineModel>> watchFines(String communityId) {
    return _firestore
        .collection(FirestorePaths.fines(communityId))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => FineModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<FineModel>> watchMyFines(String communityId, String uid) {
    return _firestore
        .collection(FirestorePaths.fines(communityId))
        .where('residentUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => FineModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> createFine(String communityId, FineModel fine) async {
    await _firestore
        .collection(FirestorePaths.fines(communityId))
        .add(fine.toFirestore());
  }

  Future<void> submitDefense(
    String communityId,
    String fineId,
    String defenseText,
  ) async {
    await _firestore
        .collection(FirestorePaths.fines(communityId))
        .doc(fineId)
        .update({
          'defenseText': defenseText,
          'status': FineStatus.defense.name,
        });
  }

  Stream<FineModel?> watchFine(String communityId, String fineId) {
    return _firestore
        .collection(FirestorePaths.fines(communityId))
        .doc(fineId)
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) return null;
          return FineModel.fromFirestore(doc.data()!, doc.id);
        });
  }

  Future<void> updateFine(String fineId, Map<String, dynamic> data) async {
    // Buscar la multa en cualquier comunidad (usar collectionGroup si es necesario)
    // Por simplicidad, usamos el communityId del usuario actual
    final query = await _firestore
        .collectionGroup('fines')
        .where(FieldPath.documentId, isEqualTo: fineId)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update(data);
    }
  }

  Future<void> updateFineStatus(
    String communityId,
    String fineId,
    FineStatus status,
  ) async {
    await _firestore
        .collection(FirestorePaths.fines(communityId))
        .doc(fineId)
        .update({'status': status.name});
  }

  // ==================== AMENIDADES ====================
  Stream<List<AmenityModel>> watchAmenities(String communityId) {
    return _firestore
        .collection(FirestorePaths.amenities(communityId))
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => AmenityModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<BookingModel>> watchBookings(
    String communityId,
    String amenityId,
  ) {
    return _firestore
        .collection(FirestorePaths.bookings(communityId))
        .where('amenityId', isEqualTo: amenityId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => BookingModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<BookingModel>> watchMyBookings(String communityId, String uid) {
    return _firestore
        .collection(FirestorePaths.bookings(communityId))
        .where('residentUid', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => BookingModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> createBooking(String communityId, BookingModel booking) async {
    await _firestore
        .collection(FirestorePaths.bookings(communityId))
        .add(booking.toFirestore());
  }

  // ==================== PQRS ====================
  Stream<List<PqrsModel>> watchAllPqrs(String communityId) {
    return _firestore
        .collection(FirestorePaths.pqrs(communityId))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => PqrsModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<PqrsModel>> watchMyPqrs(String communityId, String uid) {
    return _firestore
        .collection(FirestorePaths.pqrs(communityId))
        .where('residentUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => PqrsModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> createPqrs(String communityId, PqrsModel pqrs) async {
    await _firestore
        .collection(FirestorePaths.pqrs(communityId))
        .add(pqrs.toFirestore());
  }

  Future<void> updatePqrsStatus(
    String communityId,
    String pqrsId,
    PqrsStatus status, {
    String? response,
  }) async {
    final data = <String, dynamic>{'status': status.name};
    if (response != null) data['response'] = response;
    if (status == PqrsStatus.resolved) {
      data['resolvedAt'] = FieldValue.serverTimestamp();
    }
    await _firestore
        .collection(FirestorePaths.pqrs(communityId))
        .doc(pqrsId)
        .update(data);
  }

  // ==================== FINANZAS ====================
  Stream<List<FinanceEntryModel>> watchFinances(
    String communityId, {
    int? year,
    int? month,
  }) {
    Query query = _firestore
        .collection(FirestorePaths.finances(communityId))
        .orderBy('date', descending: true);
    return query.snapshots().map(
      (snap) => snap.docs
          .map(
            (doc) => FinanceEntryModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList(),
    );
  }

  Stream<int> watchMonthlyIncome(String communityId, DateTime startOfMonth) {
    return _firestore
        .collection(FirestorePaths.finances(communityId))
        .where('type', isEqualTo: 'income')
        .snapshots()
        .map((snap) {
          var total = 0;
          for (final doc in snap.docs) {
            final data = doc.data();
            final ts = data['date'];
            if (ts is Timestamp && !ts.toDate().isBefore(startOfMonth)) {
              total += (data['amount'] ?? 0) as int;
            }
          }
          return total;
        });
  }

  Stream<AccountStatementModel?> watchAccountStatement(
    String communityId,
    String uid,
  ) {
    return _firestore
        .collection(FirestorePaths.accountStatements(communityId))
        .where('residentUid', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return null;
          return AccountStatementModel.fromFirestore(
            snap.docs.first.data(),
            snap.docs.first.id,
          );
        });
  }

  // ==================== ASAMBLEAS ====================
  Stream<List<AssemblyModel>> watchAssemblies(String communityId) {
    return _firestore
        .collection(FirestorePaths.assemblies(communityId))
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => AssemblyModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> createAssembly(
    String communityId,
    AssemblyModel assembly,
  ) async {
    await _firestore
        .collection(FirestorePaths.assemblies(communityId))
        .add(assembly.toFirestore());
  }

  Future<void> castVote(
    String communityId,
    String assemblyId,
    int voteIndex,
    String option,
    String uid,
  ) async {
    final ref = _firestore
        .collection(FirestorePaths.assemblies(communityId))
        .doc(assemblyId);

    await _firestore.runTransaction((tx) async {
      final doc = await tx.get(ref);
      final data = doc.data()!;
      final votes = (data['votes'] as List)
          .map((e) => VoteItem.fromMap(e as Map<String, dynamic>))
          .toList();

      final vote = votes[voteIndex];
      final updatedResults = Map<String, List<String>>.from(vote.results);
      if (!updatedResults.containsKey(option)) {
        updatedResults[option] = [];
      }
      updatedResults[option]!.add(uid);

      votes[voteIndex] = VoteItem(
        topic: vote.topic,
        options: vote.options,
        results: updatedResults,
      );

      tx.update(ref, {'votes': votes.map((e) => e.toMap()).toList()});
    });
  }
}
