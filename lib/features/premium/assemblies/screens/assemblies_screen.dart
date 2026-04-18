import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/datetime_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/widgets/empty_state.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

/// Asambleas - dos capas:
/// Admin: convoca, gestiona orden del día, abre/cierra votaciones
/// Residente: asiste, vota en tiempo real, ve resultados
class AssembliesScreen extends ConsumerWidget {
  const AssembliesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assembliesAsync = ref.watch(assembliesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Asambleas')),
      body: assembliesAsync.when(
        data: (assemblies) {
          if (assemblies.isEmpty) {
            return const EmptyState(
              icon: Icons.how_to_vote_outlined,
              title: 'Sin asambleas',
              subtitle: 'Las convocatorias de asamblea aparecerán aquí',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: assemblies.length,
            itemBuilder: (_, i) {
              final assembly = assemblies[i];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSizes.md),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  onTap: () =>
                      context.push('/premium/assemblies/${assembly.id}'),
                  child: Padding(
                    padding: AppSizes.paddingCard,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (assembly.isLive) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius:
                                      BorderRadius.circular(AppSizes.radiusFull),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.circle,
                                        size: 8, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'EN VIVO',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSizes.sm),
                            ],
                            Expanded(
                              child: Text(
                                assembly.title,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 14, color: AppColors.textHint),
                            const SizedBox(width: 4),
                            Text(
                              assembly.date.formatDateLong,
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                        if (assembly.location != null) ...[
                          const SizedBox(height: AppSizes.xs),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 14, color: AppColors.textHint),
                              const SizedBox(width: 4),
                              Text(
                                assembly.location!,
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: AppSizes.sm),
                        // Agenda preview
                        Text(
                          'Orden del día: ${assembly.agenda.length} puntos',
                          style: AppTextStyles.caption,
                        ),
                        // Quórum
                        if (assembly.quorum > 0) ...[
                          const SizedBox(height: AppSizes.xs),
                          Text(
                            '${assembly.quorum} asistentes registrados',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                        // Votaciones activas
                        if (assembly.isLive && assembly.votes.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.md),
                          ...assembly.votes.asMap().entries.map((entry) {
                            final vote = entry.value;
                            final user =
                                ref.read(currentUserProvider).value;
                            final hasVoted = user != null && vote.hasVoted(user.id);

                            return Container(
                              margin:
                                  const EdgeInsets.only(bottom: AppSizes.sm),
                              padding: const EdgeInsets.all(AppSizes.sm),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMd),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vote.topic,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.sm),
                                  ...vote.options.map((option) {
                                    final pct = vote.percentageFor(option);
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: AppSizes.xs),
                                      child: hasVoted
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(option,
                                                        style: AppTextStyles
                                                            .caption),
                                                    Text(
                                                      '${(pct * 100).round()}%',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  child:
                                                      LinearProgressIndicator(
                                                    value: pct,
                                                    minHeight: 6,
                                                    backgroundColor:
                                                        AppColors.border,
                                                    color: AppColors.success,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : SizedBox(
                                              width: double.infinity,
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  if (user == null) return;
                                                  final communityId = ref.read(
                                                      currentCommunityIdProvider);
                                                  if (communityId == null) return;
                                                  ref
                                                      .read(
                                                          premiumRepositoryProvider)
                                                      .castVote(
                                                        communityId,
                                                        assembly.id,
                                                        entry.key,
                                                        option,
                                                        user.id,
                                                      );
                                                  context.showSuccessSnackBar(
                                                      'Voto registrado');
                                                },
                                                child: Text(option),
                                              ),
                                            ),
                                    );
                                  }),
                                  Text(
                                    '${vote.totalVotes()} votos',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
