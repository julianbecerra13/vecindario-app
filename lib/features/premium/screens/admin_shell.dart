import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/premium/circulars/screens/circulars_screen.dart';
import 'package:vecindario_app/features/premium/finances/screens/finances_screen.dart';
import 'package:vecindario_app/features/premium/amenities/screens/amenities_screen.dart';
import 'package:vecindario_app/features/premium/pqrs/screens/pqrs_screen.dart';
import 'package:vecindario_app/features/premium/providers/premium_provider.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';
import 'package:vecindario_app/features/auth/screens/join_community_screen.dart';
import 'package:go_router/go_router.dart';

/// Shell del módulo Admin con 5 tabs según wireframe:
/// Inicio | Circulares | Finanzas | Zonas | PQRS
class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _AdminHomePage(),
      const CircularsScreen(),
      const FinancesScreen(),
      const AmenitiesScreen(),
      const PqrsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.success,
        unselectedItemColor: AppColors.textHint,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), activeIcon: Icon(Icons.campaign), label: 'Circulares'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_outlined), activeIcon: Icon(Icons.account_balance), label: 'Finanzas'),
          BottomNavigationBarItem(icon: Icon(Icons.pool_outlined), activeIcon: Icon(Icons.pool), label: 'Zonas'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'PQRS'),
        ],
      ),
    );
  }
}

/// Página de inicio del admin con stats, acciones rápidas y solicitudes
class _AdminHomePage extends ConsumerWidget {
  const _AdminHomePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityAsync = ref.watch(communityProvider);
    final plan = ref.watch(subscriptionPlanProvider).value;
    final pendingAsync = ref.watch(pendingResidentsProvider);
    final pqrsAsync = ref.watch(allPqrsProvider);

    final communityName = communityAsync.value?.name ?? 'Mi comunidad';
    final memberCount = communityAsync.value?.memberCount ?? 0;
    final openPqrs = pqrsAsync.value?.where((p) => p.status.name != 'resolved' && p.status.name != 'closed').length ?? 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vecindario Admin', style: TextStyle(fontSize: 10, color: AppColors.success, letterSpacing: 1, fontWeight: FontWeight.w600)),
            Text(communityName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          if (plan != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  plan.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // Stats
          Row(
            children: [
              _StatCard(value: '$memberCount', label: 'Residentes', color: AppColors.primary),
              const SizedBox(width: 6),
              _StatCard(value: '$openPqrs', label: 'PQRS abiertos', color: AppColors.warning),
              const SizedBox(width: 6),
              _StatCard(value: '\$4.2M', label: 'Recaudo mes', color: AppColors.success),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          // Acciones rápidas
          Text('ACCIONES RÁPIDAS', style: AppTextStyles.label),
          const SizedBox(height: AppSizes.sm),
          _QuickAction(
            icon: Icons.campaign, color: AppColors.info,
            title: 'Nueva Circular', subtitle: 'Enviar comunicado oficial',
            onTap: () => context.push('/premium/circulars/create'),
          ),
          _QuickAction(
            icon: Icons.warning_amber, color: AppColors.error,
            title: 'Registrar Multa', subtitle: 'Crear sanción con evidencia',
            onTap: () => context.push('/premium/fines/create'),
          ),
          _QuickAction(
            icon: Icons.account_balance, color: AppColors.success,
            title: 'Finanzas', subtitle: 'Presupuesto y ejecución',
            onTap: () => context.push('/premium/finances'),
          ),
          _QuickAction(
            icon: Icons.how_to_vote, color: const Color(0xFF8B5CF6),
            title: 'Convocar Asamblea', subtitle: 'Crear convocatoria con agenda',
            onTap: () => context.push('/premium/assemblies'),
          ),

          const SizedBox(height: AppSizes.lg),

          // Solicitudes pendientes
          pendingAsync.when(
            data: (pending) {
              if (pending.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SOLICITUDES PENDIENTES (${pending.length})', style: AppTextStyles.label),
                  const SizedBox(height: AppSizes.sm),
                  ...pending.take(5).map((user) => Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          user.displayName.isNotEmpty ? user.displayName[0] : '?',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 12),
                        ),
                      ),
                      title: Text(user.displayName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      subtitle: Text('T${user.tower} · Apto ${user.apartment}', style: AppTextStyles.caption),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _MiniButton(icon: Icons.check, color: AppColors.success, onTap: () {}),
                          const SizedBox(width: 4),
                          _MiniButton(icon: Icons.close, color: AppColors.textHint, onTap: () {}),
                        ],
                      ),
                    ),
                  )),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// Necesitamos importar estos providers que ya existen
final communityProvider = StreamProvider((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return Stream.value(null);
  return ref.watch(communityRepositoryProvider).watchCommunity(communityId);
});

final pendingResidentsProvider = StreamProvider((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return Stream.value([]);
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('users')
      .where('communityId', isEqualTo: communityId)
      .where('verified', isEqualTo: false)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final data = doc.data();
            return _PendingUser(
              id: doc.id,
              displayName: data['displayName'] ?? '',
              tower: data['tower'] ?? '',
              apartment: data['apartment'] ?? '',
            );
          }).toList());
});

class _PendingUser {
  final String id, displayName, tower, apartment;
  const _PendingUser({required this.id, required this.displayName, required this.tower, required this.apartment});
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textHint), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint, size: 18),
        onTap: onTap,
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _MiniButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}
