import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/features/visitors/providers/visitors_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

class VisitorsScreen extends ConsumerWidget {
  const VisitorsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final passes = ref.watch(myVisitorPassesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mis visitas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/visitors/new'),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Autorizar visita'),
      ),
      body: passes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('No pudimos cargar tus visitas.')),
        data: (items) => items.isEmpty
            ? const Center(
                child: Padding(
                  padding: AppSizes.paddingAll,
                  child: Text('Todavía no has autorizado visitas.'),
                ),
              )
            : ListView.builder(
                padding: AppSizes.paddingAll,
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final pass = items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: pass.isActive
                            ? AppColors.primaryLight
                            : null,
                        child: Icon(
                          Icons.person_outline,
                          color: pass.isActive ? AppColors.primaryDark : null,
                        ),
                      ),
                      title: Text(
                        pass.visitorName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        '${DateFormat('d MMM · h:mm a', 'es').format(pass.validFrom)} · ${pass.used
                            ? 'Usada o cancelada'
                            : pass.isActive
                            ? 'Vigente'
                            : 'Programada o vencida'}',
                      ),
                      children: [
                        if (!pass.used && user?.communityId != null) ...[
                          QrImageView(
                            data:
                                'vecindario-visitor:${user!.communityId}:${pass.id}',
                            size: 190,
                            backgroundColor: Colors.white,
                          ),
                          TextButton.icon(
                            onPressed: () => ref
                                .read(visitorsRepositoryProvider)
                                .cancel(user.communityId!, pass.id),
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Cancelar autorización'),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
