import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/features/notifications/models/notification_model.dart';
import 'package:vecindario_app/features/notifications/services/fcm_service.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';

/// Provider del servicio FCM
final fcmServiceProvider = Provider<FCMService>((ref) {
  return FCMService(
    ref.watch(firebaseMessagingProvider),
    ref.watch(firestoreProvider),
  );
});

/// Stream de notificaciones del usuario actual
final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);

  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(user.id)
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => NotificationModel.fromFirestore(doc.data(), doc.id))
          .toList());
});

/// Contador de no leídas
final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).value ?? [];
  return notifications.where((n) => !n.read).length;
});

/// Marcar notificación como leída
final markAsReadProvider = Provider<Future<void> Function(String)>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return (_) async {};

  return (String notificationId) async {
    await ref
        .read(firestoreProvider)
        .collection('users')
        .doc(user.id)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  };
});

/// Marcar todas como leídas
final markAllReadProvider = Provider<Future<void> Function()>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return () async {};

  return () async {
    final firestore = ref.read(firestoreProvider);
    final unread = await firestore
        .collection('users')
        .doc(user.id)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();

    final batch = firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  };
});
