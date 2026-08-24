import 'package:go_router/go_router.dart';
import 'package:vecindario_app/features/admin/screens/community_settings_screen.dart';
import 'package:vecindario_app/features/admin/screens/pending_approvals_screen.dart';
import 'package:vecindario_app/features/premium/circulars/screens/circulars_screen.dart';
import 'package:vecindario_app/features/premium/circulars/screens/create_circular_screen.dart';
import 'package:vecindario_app/features/premium/fines/screens/fines_screen.dart';
import 'package:vecindario_app/features/premium/fines/screens/create_fine_screen.dart';
import 'package:vecindario_app/features/premium/fines/screens/fine_detail_screen.dart';
import 'package:vecindario_app/features/premium/amenities/screens/amenities_screen.dart';
import 'package:vecindario_app/features/premium/amenities/screens/create_amenity_screen.dart';
import 'package:vecindario_app/features/premium/finances/screens/create_finance_entry_screen.dart';
import 'package:vecindario_app/features/premium/finances/screens/finances_screen.dart';
import 'package:vecindario_app/features/premium/finances/screens/account_statement_screen.dart';
import 'package:vecindario_app/features/premium/pqrs/screens/pqrs_screen.dart';
import 'package:vecindario_app/features/premium/pqrs/screens/create_pqrs_screen.dart';
import 'package:vecindario_app/features/premium/assemblies/screens/assemblies_screen.dart';
import 'package:vecindario_app/features/premium/assemblies/screens/assembly_detail_screen.dart';
import 'package:vecindario_app/features/premium/assemblies/screens/create_assembly_screen.dart';
import 'package:vecindario_app/features/premium/manual/screens/manual_screen.dart';
import 'package:vecindario_app/features/premium/screens/admin_shell.dart';
import 'package:vecindario_app/features/premium/screens/premium_dashboard_screen.dart';
import 'package:vecindario_app/features/premium/subscriptions/screens/subscription_plans_screen.dart';

/// Rutas del módulo único de "Administración del conjunto" — fusiona lo que
/// antes eran dos paneles separados (/admin y /premium: PendingApprovals y
/// CommunitySettings vivían bajo /admin, ahora cuelgan de /premium). El
/// guard fino (communityRole == admin || platformRole == super_admin) vive
/// en app_router.dart.
final List<RouteBase> communityAdminRoutes = [
  GoRoute(path: '/premium', builder: (_, __) => const AdminShell()),
  GoRoute(
    path: '/premium/dashboard',
    builder: (_, __) => const PremiumDashboardScreen(),
  ),
  GoRoute(
    path: '/premium/pending',
    builder: (_, __) => const PendingApprovalsScreen(),
  ),
  GoRoute(
    path: '/premium/settings',
    builder: (_, __) => const CommunitySettingsScreen(),
  ),
  GoRoute(
    path: '/premium/circulars',
    builder: (_, __) => const CircularsScreen(),
  ),
  GoRoute(
    path: '/premium/circulars/create',
    builder: (_, __) => const CreateCircularScreen(),
  ),
  GoRoute(path: '/premium/fines', builder: (_, __) => const FinesScreen()),
  GoRoute(
    path: '/premium/fines/create',
    builder: (_, __) => const CreateFineScreen(),
  ),
  GoRoute(
    path: '/premium/fines/:fineId',
    builder: (_, state) =>
        FineDetailScreen(fineId: state.pathParameters['fineId'] ?? ''),
  ),
  GoRoute(path: '/premium/pqrs', builder: (_, __) => const PqrsScreen()),
  GoRoute(
    path: '/premium/pqrs/create',
    builder: (_, __) => const CreatePqrsScreen(),
  ),
  GoRoute(
    path: '/premium/amenities',
    builder: (_, __) => const AmenitiesScreen(),
  ),
  GoRoute(
    path: '/premium/amenities/create',
    builder: (_, __) => const CreateAmenityScreen(),
  ),
  GoRoute(
    path: '/premium/finances',
    builder: (_, __) => const FinancesScreen(),
  ),
  GoRoute(
    path: '/premium/finances/create',
    builder: (_, __) => const CreateFinanceEntryScreen(),
  ),
  GoRoute(
    path: '/premium/account-statement',
    builder: (_, __) => const AccountStatementScreen(),
  ),
  GoRoute(path: '/premium/manual', builder: (_, __) => const ManualScreen()),
  GoRoute(
    path: '/premium/assemblies',
    builder: (_, __) => const AssembliesScreen(),
  ),
  GoRoute(
    path: '/premium/assemblies/create',
    builder: (_, __) => const CreateAssemblyScreen(),
  ),
  GoRoute(
    path: '/premium/assemblies/:assemblyId',
    builder: (_, state) => AssemblyDetailScreen(
      assemblyId: state.pathParameters['assemblyId'] ?? '',
    ),
  ),
  GoRoute(
    path: '/premium/plans',
    builder: (_, __) => const SubscriptionPlansScreen(),
  ),
];
