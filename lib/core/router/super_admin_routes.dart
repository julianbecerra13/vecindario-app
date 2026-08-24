import 'package:go_router/go_router.dart';
import 'package:vecindario_app/features/super_admin/screens/community_detail_admin_screen.dart';
import 'package:vecindario_app/features/super_admin/screens/create_community_screen.dart';
import 'package:vecindario_app/features/super_admin/screens/super_admin_panel_screen.dart';

/// Rutas del panel de plataforma, exclusivas de platformRole == super_admin.
final List<RouteBase> superAdminRoutes = [
  GoRoute(
    path: '/super-admin',
    builder: (_, __) => const SuperAdminPanelScreen(),
    routes: [
      GoRoute(
        path: 'create-community',
        builder: (_, __) => const CreateCommunityScreen(),
      ),
      GoRoute(
        path: 'community/:communityId',
        builder: (_, state) => CommunityDetailAdminScreen(
          communityId: state.pathParameters['communityId'] ?? '',
        ),
      ),
    ],
  ),
];
