import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vecindario_app/core/constants/firestore_paths.dart';

/// Servicio de Firebase Cloud Messaging
/// Maneja permisos, tokens, notificaciones foreground y background
class FCMService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final FlutterLocalNotificationsPlugin _localNotifications;

  FCMService(this._messaging, this._firestore)
      : _localNotifications = FlutterLocalNotificationsPlugin();

  /// Canal de notificaciones Android
  static const _androidChannel = AndroidNotificationChannel(
    'vecindario_channel',
    'Vecindario',
    description: 'Notificaciones de tu comunidad',
    importance: Importance.high,
  );

  /// Inicializar FCM: permisos + token + listeners
  Future<void> initialize(String uid) async {
    // Solicitar permisos
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      debugPrint('FCM: Permisos denegados');
      return;
    }

    // Configurar canal local (Android)
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // Inicializar local notifications
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        // Manejar tap en notificación local
        debugPrint('FCM: Tap en notificación: ${response.payload}');
      },
    );

    // Obtener y guardar token
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveToken(uid, token);
    }

    // Escuchar refresh de token
    _messaging.onTokenRefresh.listen((newToken) {
      _saveToken(uid, newToken);
    });

    // Notificaciones en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Notificación que abrió la app (background → foreground)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Si la app fue abierta por una notificación (terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    debugPrint('FCM: Inicializado correctamente con token: ${token?.substring(0, 20)}...');
  }

  /// Guardar token FCM en Firestore para envío desde Cloud Functions
  Future<void> _saveToken(String uid, String token) async {
    await _firestore.collection(FirestorePaths.users).doc(uid).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }

  /// Remover token al cerrar sesión
  Future<void> removeToken(String uid) async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _firestore.collection(FirestorePaths.users).doc(uid).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
    }
  }

  /// Mostrar notificación local cuando la app está en foreground
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['route'],
    );
  }

  /// Manejar tap en notificación (navegar a ruta)
  void _handleMessageOpenedApp(RemoteMessage message) {
    final route = message.data['route'];
    if (route != null) {
      debugPrint('FCM: Navegar a $route');
      // La navegación se maneja desde el provider que escucha esto
    }
  }

  /// Suscribirse a topic de comunidad
  Future<void> subscribeToCommunity(String communityId) async {
    await _messaging.subscribeToTopic('community_$communityId');
  }

  /// Desuscribirse de topic de comunidad
  Future<void> unsubscribeFromCommunity(String communityId) async {
    await _messaging.unsubscribeFromTopic('community_$communityId');
  }
}
