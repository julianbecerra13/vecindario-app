import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/features/admin/screens/admin_panel_screen.dart';
import 'package:vecindario_app/features/admin/screens/pending_approvals_screen.dart';
import 'package:vecindario_app/features/auth/screens/forgot_password_screen.dart';
import 'package:vecindario_app/features/auth/screens/join_community_screen.dart';
import 'package:vecindario_app/features/auth/screens/login_screen.dart';
import 'package:vecindario_app/features/auth/screens/pending_approval_screen.dart';
import 'package:vecindario_app/features/auth/screens/phone_verification_screen.dart';
import 'package:vecindario_app/features/auth/screens/register_screen.dart';
import 'package:vecindario_app/features/external_services/screens/external_services_screen.dart';
import 'package:vecindario_app/features/feed/screens/create_post_screen.dart';
import 'package:vecindario_app/features/feed/screens/feed_screen.dart';
import 'package:vecindario_app/features/home/screens/home_shell.dart';
import 'package:vecindario_app/features/notifications/screens/notifications_screen.dart';
import 'package:vecindario_app/features/onboarding/screens/onboarding_screen.dart';
import 'package:vecindario_app/features/profile/screens/privacy_screen.dart';
import 'package:vecindario_app/features/profile/screens/profile_screen.dart';
import 'package:vecindario_app/features/services/screens/services_screen.dart';
import 'package:vecindario_app/features/stores/screens/stores_screen.dart';
import 'package:vecindario_app/features/stores/screens/store_detail_screen.dart';
import 'package:vecindario_app/features/stores/screens/order_tracking_screen.dart';
import 'package:vecindario_app/features/stores/screens/my_orders_screen.dart';
import 'package:vecindario_app/features/premium/circulars/screens/circulars_screen.dart';
import 'package:vecindario_app/features/premium/fines/screens/fines_screen.dart';
import 'package:vecindario_app/features/premium/amenities/screens/amenities_screen.dart';
import 'package:vecindario_app/features/premium/finances/screens/finances_screen.dart';
import 'package:vecindario_app/features/premium/finances/screens/account_statement_screen.dart';
import 'package:vecindario_app/features/premium/pqrs/screens/pqrs_screen.dart';
import 'package:vecindario_app/features/premium/assemblies/screens/assemblies_screen.dart';
import 'package:vecindario_app/features/premium/manual/screens/manual_screen.dart';
import 'package:vecindario_app/features/premium/screens/admin_shell.dart';
import 'package:vecindario_app/features/premium/circulars/screens/create_circular_screen.dart';
import 'package:vecindario_app/features/premium/fines/screens/create_fine_screen.dart';
import 'package:vecindario_app/features/premium/fines/screens/fine_detail_screen.dart';
import 'package:vecindario_app/features/premium/pqrs/screens/create_pqrs_screen.dart';
import 'package:vecindario_app/features/premium/subscriptions/screens/subscription_plans_screen.dart';
import 'package:vecindario_app/features/profile/screens/terms_screen.dart';
import 'package:vecindario_app/features/profile/screens/privacy_policy_screen.dart';
import 'package:vecindario_app/features/stores/screens/store_panel_screen.dart';
import 'package:vecindario_app/features/stores/screens/rate_order_screen.dart';
import 'package:vecindario_app/features/super_admin/screens/super_admin_panel_screen.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final currentUser = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/feed',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/onboarding' ||
          state.matchedLocation.startsWith('/verify-phone');

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) {
        final user = currentUser.valueOrNull;
        if (user == null) return null;
        // Super admin no necesita comunidad
        if (user.role.toValue() == 'super_admin') return '/super-admin';
        if (user.communityId == null) return '/join-community';
        if (!user.verified) return '/pending-approval';
        return '/feed';
      }

      // Guard: rutas admin solo para admins
      if (isLoggedIn) {
        final user = currentUser.valueOrNull;
        final isAdminRoute = state.matchedLocation.startsWith('/admin') ||
            state.matchedLocation.startsWith('/premium');
        if (isAdminRoute && user != null && user.role.toValue() != 'admin' && user.role.toValue() != 'super_admin') {
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
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
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

      // Shell con BottomNav (4 tabs: Noticias, Vecinos, Tiendas, Servicios)
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          // Tab 1: Noticias
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/feed',
                builder: (_, __) => const FeedScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (_, __) => const CreatePostScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Tab 2: Vecinos (Servicios vecinales)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/services',
                builder: (_, __) => const ServicesScreen(),
              ),
            ],
          ),
          // Tab 3: Tiendas
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stores',
                builder: (_, __) => const StoresScreen(),
                routes: [
                  GoRoute(
                    path: ':storeId',
                    builder: (_, state) => StoreDetailScreen(
                      storeId: state.pathParameters['storeId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'orders',
                    builder: (_, __) => const MyOrdersScreen(),
                  ),
                  GoRoute(
                    path: 'order/:orderId',
                    builder: (_, state) => OrderTrackingScreen(
                      orderId: state.pathParameters['orderId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'rate/:orderId',
                    builder: (_, state) => RateOrderScreen(
                      orderId: state.pathParameters['orderId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Tab 4: Servicios Externos
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/external-services',
                builder: (_, __) => const ExternalServicesScreen(),
              ),
            ],
          ),
        ],
      ),

      // Rutas globales (fuera del shell)
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'privacy',
            builder: (_, __) => const PrivacyScreen(),
          ),
          GoRoute(
            path: 'terms',
            builder: (_, __) => const TermsScreen(),
          ),
          GoRoute(
            path: 'privacy-policy',
            builder: (_, __) => const PrivacyPolicyScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/store-panel',
        builder: (_, __) => const StorePanelScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (_, __) => const AdminPanelScreen(),
        routes: [
          GoRoute(
            path: 'pending',
            builder: (_, __) => const PendingApprovalsScreen(),
          ),
        ],
      ),

      // Rutas Premium (Vecindario Admin)
      GoRoute(
        path: '/premium',
        builder: (_, __) => const AdminShell(),
      ),
      GoRoute(
        path: '/premium/circulars',
        builder: (_, __) => const CircularsScreen(),
      ),
      GoRoute(
        path: '/premium/circulars/create',
        builder: (_, __) => const CreateCircularScreen(),
      ),
      GoRoute(
        path: '/premium/fines',
        builder: (_, __) => const FinesScreen(),
      ),
      GoRoute(
        path: '/premium/fines/create',
        builder: (_, __) => const CreateFineScreen(),
      ),
      GoRoute(
        path: '/premium/fines/:fineId',
        builder: (_, state) => FineDetailScreen(
          fineId: state.pathParameters['fineId']!,
        ),
      ),
      GoRoute(
        path: '/premium/pqrs',
        builder: (_, __) => const PqrsScreen(),
      ),
      GoRoute(
        path: '/premium/pqrs/create',
        builder: (_, __) => const CreatePqrsScreen(),
      ),
      GoRoute(
        path: '/premium/amenities',
        builder: (_, __) => const AmenitiesScreen(),
      ),
      GoRoute(
        path: '/premium/finances',
        builder: (_, __) => const FinancesScreen(),
      ),
      GoRoute(
        path: '/premium/account-statement',
        builder: (_, __) => const AccountStatementScreen(),
      ),
      GoRoute(
        path: '/premium/manual',
        builder: (_, __) => const ManualScreen(),
      ),
      GoRoute(
        path: '/premium/assemblies',
        builder: (_, __) => const AssembliesScreen(),
      ),
      GoRoute(
        path: '/premium/plans',
        builder: (_, __) => const SubscriptionPlansScreen(),
      ),
      GoRoute(
        path: '/super-admin',
        builder: (_, __) => const SuperAdminPanelScreen(),
      ),
    ],
  );
});
