import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vecindario_app/app.dart';
import 'package:vecindario_app/shared/services/remote_config_service.dart';
import 'firebase_options.dart';

/// Handler para notificaciones en background (requerido por FCM)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Registrar handler para notificaciones en background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inicializar Remote Config
  final remoteConfig = RemoteConfigService(FirebaseRemoteConfig.instance);
  await remoteConfig.initialize();

  // Configurar timeago en español
  timeago.setLocaleMessages('es', timeago.EsMessages());
  timeago.setDefaultLocale('es');

  // Inicializar datos de locale para DateFormat (meses/días en español)
  await initializeDateFormatting('es', null);

  runApp(const ProviderScope(child: VecindarioApp()));
}
