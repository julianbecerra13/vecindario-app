import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/router/community_admin_routes.dart';
import 'package:vecindario_app/core/router/resident_routes.dart';
import 'package:vecindario_app/core/router/super_admin_routes.dart';
import 'package:vecindario_app/features/auth/screens/forgot_password_screen.dart';
import 'package:vecindario_app/features/auth/screens/join_community_screen.dart';
import 'package:vecindario_app/features/auth/screens/login_screen.dart';
import 'package:vecindario_app/features/auth/screens/pending_approval_screen.dart';
import 'package:vecindario_app/features/auth/screens/phone_verification_screen.dart';
import 'package:vecindario_app/features/auth/screens/register_screen.dart';
import 'package:vecindario_app/features/onboarding/screens/onboarding_screen.dart';
import 'package:vecindario_app/shared/providers/capabilities_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

/// Ensambla las rutas de los 3 perfiles (resident_routes, community_admin_routes,
/// super_admin_routes) y retiene solo el guard de alto nivel: login, unirse a
/// comunidad, aprobación pendiente, y el enrutamiento forzado por perfil. El
/// guard fino de cada sección (ej. "/premium requiere isAdmin") vive aquí
/// porque depende del estado global de auth/usuario que ya está siendo
/// observado por routerProvider.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final currentUser = ref.watch(currentUserProvider);
  final hasStore = ref.watch(hasStoreProvider);

  return GoRouter(
    initialLocation: '/feed',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/onboarding' ||
          state.matchedLocation.startsWith('/verify-phone');

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) {
        final user = currentUser.valueOrNull;
        if (user == null) return null;
        if (user.isSuperAdmin) return '/super-admin';
        if (user.communityId == null) return '/join-community';
        if (!user.verified) return '/pending-approval';
        return '/feed';
      }

      if (isLoggedIn) {
        final user = currentUser.valueOrNull;
        final isLoading = currentUser.isLoading;

        // super_admin siempre vive en /super-admin (excepto /profile)
        if (user != null && user.isSuperAdmin) {
          final isSuperAdminArea = state.matchedLocation.startsWith(
            '/super-admin',
          );
          final isProfileArea = state.matchedLocation.startsWith('/profile');
          if (!isSuperAdminArea && !isProfileArea) {
            return '/super-admin';
          }
        }

        // Todo usuario de comunidad (resident o admin) debe unirse primero,
        // y esperar aprobación si aún no está verificado.
        if (user != null && !user.isSuperAdmin) {
          final onJoin = state.matchedLocation == '/join-community';
          final onPending = state.matchedLocation == '/pending-approval';
          if (user.communityId == null && !onJoin) {
            return '/join-community';
          }
          if (user.communityId != null && !user.verified && !onPending) {
            return '/pending-approval';
          }
        }

        // Guard: /premium (Administración del conjunto) solo para
        // communityRole == admin o super_admin de plataforma.
        final isCommunityAdminRoute = state.matchedLocation.startsWith(
          '/premium',
        );
        if (isCommunityAdminRoute && isLoading) return null;
        if (isCommunityAdminRoute && user != null && !user.isAdmin) {
          return '/feed';
        }

        // Guard: /super-admin exclusivo para super_admin de plataforma
        final isSuperAdminRoute = state.matchedLocation.startsWith(
          '/super-admin',
        );
        if (isSuperAdminRoute && isLoading) return '/feed';
        if (isSuperAdminRoute && user != null && !user.isSuperAdmin) {
          return '/feed';
        }

        // Guard: /store-panel solo para quien tiene al menos una tienda
        // propia (capacidad derivada de datos, ya no un rol exclusivo).
        final isStorePanel = state.matchedLocation.startsWith('/store-panel');
        if (isStorePanel && !hasStore) {
          return '/feed';
        }
      }

      return null;
    },
    routes: [
      // Rutas públicas
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-phone/:phone',
        builder: (_, state) => PhoneVerificationScreen(
          phoneNumber: state.pathParameters['phone'] ?? '',
        ),
      ),
      GoRoute(
        path: '/join-community',
        builder: (_, __) => const JoinCommunityScreen(),
      ),
      GoRoute(
        path: '/pending-approval',
        builder: (_, __) => const PendingApprovalScreen(),
      ),
      ...residentRoutes,
      ...communityAdminRoutes,
      ...superAdminRoutes,
    ],
  );
});
