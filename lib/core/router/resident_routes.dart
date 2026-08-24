import 'package:go_router/go_router.dart';
import 'package:vecindario_app/features/external_services/screens/external_services_screen.dart';
import 'package:vecindario_app/features/external_services/screens/recommend_external_service_screen.dart';
import 'package:vecindario_app/features/feed/screens/create_post_screen.dart';
import 'package:vecindario_app/features/feed/screens/feed_screen.dart';
import 'package:vecindario_app/features/feed/screens/feed_detail_screen.dart';
import 'package:vecindario_app/features/home/screens/home_shell.dart';
import 'package:vecindario_app/features/notifications/screens/notifications_screen.dart';
import 'package:vecindario_app/features/profile/screens/privacy_screen.dart';
import 'package:vecindario_app/features/profile/screens/profile_screen.dart';
import 'package:vecindario_app/features/profile/screens/edit_profile_screen.dart';
import 'package:vecindario_app/features/profile/screens/terms_screen.dart';
import 'package:vecindario_app/features/profile/screens/privacy_policy_screen.dart';
import 'package:vecindario_app/features/services/screens/services_screen.dart';
import 'package:vecindario_app/features/services/screens/create_service_screen.dart';
import 'package:vecindario_app/features/services/screens/service_detail_screen.dart';
import 'package:vecindario_app/features/stores/screens/stores_screen.dart';
import 'package:vecindario_app/features/stores/screens/store_detail_screen.dart';
import 'package:vecindario_app/features/stores/screens/order_tracking_screen.dart';
import 'package:vecindario_app/features/stores/screens/my_orders_screen.dart';
import 'package:vecindario_app/features/stores/screens/store_panel_screen.dart';
import 'package:vecindario_app/features/stores/screens/rate_order_screen.dart';

/// Rutas de la experiencia "residente": el shell de 4 tabs (Noticias,
/// Vecinos, Tiendas, Servicios Externos) y las pantallas globales de
/// perfil/tienda/notificaciones. communityRole == resident y
/// communityRole == admin comparten este shell — un admin también vive el
/// conjunto como residente. La entrada a administración vive en
/// community_admin_routes.dart, bajo /premium.
final List<RouteBase> residentRoutes = [
  StatefulShellRoute.indexedStack(
    builder: (_, __, navigationShell) =>
        HomeShell(navigationShell: navigationShell),
    branches: [
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
              GoRoute(
                path: ':postId',
                builder: (_, state) => FeedDetailScreen(
                  postId: state.pathParameters['postId'] ?? '',
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/services',
            builder: (_, __) => const ServicesScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (_, __) => const CreateServiceScreen(),
              ),
              GoRoute(
                path: ':serviceId',
                builder: (_, state) => ServiceDetailScreen(
                  serviceId: state.pathParameters['serviceId'] ?? '',
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/stores',
            builder: (_, __) => const StoresScreen(),
            routes: [
              GoRoute(
                path: 'orders',
                builder: (_, __) => const MyOrdersScreen(),
              ),
              GoRoute(
                path: 'order/:orderId',
                builder: (_, state) => OrderTrackingScreen(
                  orderId: state.pathParameters['orderId'] ?? '',
                ),
              ),
              GoRoute(
                path: 'rate/:orderId',
                builder: (_, state) => RateOrderScreen(
                  orderId: state.pathParameters['orderId'] ?? '',
                ),
              ),
              GoRoute(
                path: ':storeId',
                builder: (_, state) => StoreDetailScreen(
                  storeId: state.pathParameters['storeId'] ?? '',
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/external-services',
            builder: (_, __) => const ExternalServicesScreen(),
            routes: [
              GoRoute(
                path: 'recommend',
                builder: (_, __) => const RecommendExternalServiceScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  GoRoute(
    path: '/profile',
    builder: (_, __) => const ProfileScreen(),
    routes: [
      GoRoute(path: 'edit', builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: 'privacy', builder: (_, __) => const PrivacyScreen()),
      GoRoute(path: 'terms', builder: (_, __) => const TermsScreen()),
      GoRoute(
        path: 'privacy-policy',
        builder: (_, __) => const PrivacyPolicyScreen(),
      ),
    ],
  ),
  GoRoute(path: '/store-panel', builder: (_, __) => const StorePanelScreen()),
  GoRoute(
    path: '/notifications',
    builder: (_, __) => const NotificationsScreen(),
  ),
];
