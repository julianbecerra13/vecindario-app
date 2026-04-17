import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/router/app_router.dart';
import 'package:vecindario_app/core/theme/app_theme.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/features/notifications/providers/notification_providers.dart';

class VecindarioApp extends ConsumerWidget {
  const VecindarioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Inicializar FCM cuando el usuario se autentica
    ref.listen(currentUserProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          ref.read(fcmServiceProvider).initialize(user.id);
        }
      });
    });

    return MaterialApp.router(
      title: 'Vecindario',
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: const Locale('es'),
    );
  }
}
