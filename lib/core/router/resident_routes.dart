import 'package:go_router/go_router.dart';
import 'package:vecindario_app/features/access/access_screen.dart';
import 'package:vecindario_app/features/access/access_operator_screen.dart';
import 'package:vecindario_app/features/appointments/screens/appointments_screen.dart';
import 'package:vecindario_app/features/appointments/screens/create_appointment_screen.dart';
import 'package:vecindario_app/features/external_services/screens/external_services_screen.dart';
import 'package:vecindario_app/features/community_center/screens/community_center_screen.dart';
import 'package:vecindario_app/features/external_services/screens/recommend_external_service_screen.dart';
import 'package:vecindario_app/features/feed/screens/create_post_screen.dart';
import 'package:vecindario_app/features/feed/screens/feed_screen.dart';
import 'package:vecindario_app/features/feed/screens/feed_detail_screen.dart';
import 'package:vecindario_app/features/home/screens/home_shell.dart';
import 'package:vecindario_app/features/home/screens/neighborhood_screen.dart';
import 'package:vecindario_app/features/home/screens/resident_home_screen.dart';
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
import 'package:vecindario_app/features/store_credit/screens/store_credit_account_screen.dart';
import 'package:vecindario_app/features/visitors/screens/create_visitor_screen.dart';
import 'package:vecindario_app/features/visitors/screens/visitors_screen.dart';

/// Rutas de la experiencia residente: cinco destinos estables (Inicio,
/// Comunidad, Barrio, Mi conjunto y Cuenta) y sus pantallas de detalle.
/// perfil/tienda/notificaciones. communityRole == resident y
/// communityRole == admin comparten este shell — un admin también vive el
/// conjunto como residente. La entrada a administración vive en
/// community_admin_routes.dart, bajo /premium.
final List<RouteBase> residentRoutes = [
  GoRoute(path: '/community-access', builder: (_, __) => const AccessScreen()),
  GoRoute(
    path: '/access-control',
    builder: (_, __) => const AccessOperatorScreen(),
  ),
  GoRoute(
    path: '/visitors',
    builder: (_, __) => const VisitorsScreen(),
    routes: [
      GoRoute(path: 'new', builder: (_, __) => const CreateVisitorScreen()),
    ],
  ),
  GoRoute(
    path: '/appointments',
    builder: (_, __) => const AppointmentsScreen(),
    routes: [
      GoRoute(path: 'new', builder: (_, __) => const CreateAppointmentScreen()),
    ],
  ),
  StatefulShellRoute.indexedStack(
    builder: (_, __, navigationShell) =>
        HomeShell(navigationShell: navigationShell),
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const ResidentHomeScreen(),
          ),
        ],
      ),
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
            path: '/barrio',
            builder: (_, __) => const NeighborhoodScreen(),
          ),
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
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/community-center',
            builder: (_, __) => const CommunityCenterScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (_, __) => const EditProfileScreen(),
              ),
              GoRoute(
                path: 'privacy',
                builder: (_, __) => const PrivacyScreen(),
              ),
              GoRoute(path: 'terms', builder: (_, __) => const TermsScreen()),
              GoRoute(
                path: 'privacy-policy',
                builder: (_, __) => const PrivacyPolicyScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  GoRoute(path: '/store-panel', builder: (_, __) => const StorePanelScreen()),
  GoRoute(
    path: '/store-credit/:storeId/:residentUid',
    builder: (_, state) => StoreCreditAccountScreen(
      storeId: state.pathParameters['storeId'] ?? '',
      residentUid: state.pathParameters['residentUid'] ?? '',
      residentName: state.extra as String?,
    ),
  ),
  GoRoute(
    path: '/notifications',
    builder: (_, __) => const NotificationsScreen(),
  ),
];
