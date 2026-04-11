import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  post('post', 'Publicación'),
  comment('comment', 'Comentario'),
  order('order', 'Pedido'),
  circular('circular', 'Circular'),
  fine('fine', 'Multa'),
  pqrs('pqrs', 'PQRS'),
  booking('booking', 'Reserva'),
  assembly('assembly', 'Asamblea'),
  approval('approval', 'Aprobación'),
  system('system', 'Sistema');

  final String value;
  final String label;
  const NotificationType(this.value, this.label);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.system,
    );
  }
}

class NotificationModel {
  final String id;
  final String uid;
  final NotificationType type;
  final String title;
  final String body;
  final String? route;
  final Map<String, String>? routeParams;
  final bool read;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.uid,
    required this.type,
    required this.title,
    required this.body,
    this.route,
    this.routeParams,
    this.read = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      uid: data['uid'] ?? '',
      type: NotificationType.fromString(data['type'] ?? 'system'),
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      route: data['route'],
      routeParams: data['routeParams'] != null
          ? Map<String, String>.from(data['routeParams'])
          : null,
      read: data['read'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'type': type.value,
    'title': title,
    'body': body,
    'route': route,
    'routeParams': routeParams,
    'read': read,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  NotificationModel copyWith({bool? read}) {
    return NotificationModel(
      id: id,
      uid: uid,
      type: type,
      title: title,
      body: body,
      route: route,
      routeParams: routeParams,
      read: read ?? this.read,
      createdAt: createdAt,
    );
  }
}
