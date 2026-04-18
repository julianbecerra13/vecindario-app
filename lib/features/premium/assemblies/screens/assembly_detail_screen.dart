import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/datetime_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/premium/models/finance_model.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

class AssemblyDetailScreen extends ConsumerStatefulWidget {
  final String assemblyId;

  const AssemblyDetailScreen({super.key, required this.assemblyId});

  @override
  ConsumerState<AssemblyDetailScreen> createState() =>
      _AssemblyDetailScreenState();
}

class _AssemblyDetailScreenState extends ConsumerState<AssemblyDetailScreen> {
  bool _voting = false;

  @override
  Widget build(BuildContext context) {
    final assemblyAsync = ref.watch(assemblyDetailProvider(widget.assemblyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Asamblea')),
      body: assemblyAsync.when(
        data: (assembly) {
          if (assembly == null) {
            return const Center(child: Text('Asamblea no encontrada'));
          }
          return SingleChildScrollView(
            padding: AppSizes.paddingAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(assembly: assembly),
                const SizedBox(height: AppSizes.lg),
                _InfoSection(assembly: assembly),
                if (assembly.agenda.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.lg),
                  Text('Orden del día', style: AppTextStyles.heading3),
                  const SizedBox(height: AppSizes.sm),
                  ...assembly.agenda.asMap().entries.map(
                        (e) => _AgendaItem(index: e.key + 1, text: e.value),
                      ),
                ],
                if (assembly.votes.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.lg),
                  Text('Votaciones', style: AppTextStyles.heading3),
                  const SizedBox(height: AppSizes.sm),
                  ...assembly.votes.asMap().entries.map(
                        (e) => _VoteCard(
                          assemblyId: assembly.id,
                          voteIndex: e.key,
                          vote: e.value,
                          canVote: assembly.isLive,
                          disabled: _voting,
                          onBeforeVote: () => setState(() => _voting = true),
                          onAfterVote: () => setState(() => _voting = false),
                        ),
                      ),
                ],
                if (assembly.actaPdfURL != null &&
                    assembly.actaPdfURL!.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.lg),
                  OutlinedButton.icon(
                    onPressed: () => _openUrl(assembly.actaPdfURL!),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Ver acta en PDF'),
                  ),
                ],
                const SizedBox(height: AppSizes.xl),
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      context.showErrorSnackBar('No se pudo abrir el enlace');
    }
  }
}

class _Header extends StatelessWidget {
  final AssemblyModel assembly;
  const _Header({required this.assembly});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: assembly.isLive
            ? AppColors.error.withValues(alpha: 0.08)
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: assembly.isLive
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (assembly.isLive)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.white),
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
          const SizedBox(height: AppSizes.sm),
          Text(assembly.title, style: AppTextStyles.heading2),
          const SizedBox(height: AppSizes.xs),
          Text(
            _statusLabel(assembly.status),
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Votación abierta';
      case 'closed':
        return 'Cerrada';
      default:
        return 'Convocada';
    }
  }
}

class _InfoSection extends StatelessWidget {
  final AssemblyModel assembly;
  const _InfoSection({required this.assembly});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(
          icon: Icons.calendar_today,
          text: assembly.date.formatDateLong,
        ),
        if (assembly.location != null && assembly.location!.isNotEmpty)
          _InfoRow(icon: Icons.location_on, text: assembly.location!),
        if (assembly.virtualLink != null && assembly.virtualLink!.isNotEmpty)
          _InfoRow(
            icon: Icons.videocam,
            text: assembly.virtualLink!,
            isLink: true,
          ),
        _InfoRow(
          icon: Icons.people,
          text: '${assembly.quorum} asistentes registrados',
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLink;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: isLink
                ? InkWell(
                    onTap: () async {
                      final uri = Uri.parse(text);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(text, style: AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _AgendaItem extends StatelessWidget {
  final int index;
  final String text;
  const _AgendaItem({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$index.',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

class _VoteCard extends ConsumerWidget {
  final String assemblyId;
  final int voteIndex;
  final VoteItem vote;
  final bool canVote;
  final bool disabled;
  final VoidCallback onBeforeVote;
  final VoidCallback onAfterVote;

  const _VoteCard({
    required this.assemblyId,
    required this.voteIndex,
    required this.vote,
    required this.canVote,
    required this.disabled,
    required this.onBeforeVote,
    required this.onAfterVote,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final hasVoted = user != null && vote.hasVoted(user.id);
    final showResults = hasVoted || !canVote;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vote.topic,
            style: AppTextStyles.bodyLarge
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSizes.sm),
          if (showResults) ..._buildResults()
          else
            ..._buildOptions(context, ref, user?.id),
          const SizedBox(height: AppSizes.xs),
          Text(
            '${vote.totalVotes()} votos',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildResults() {
    return vote.options.map((option) {
      final pct = vote.percentageFor(option);
      final count = vote.results[option]?.length ?? 0;
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(option, style: AppTextStyles.bodySmall),
                Text(
                  '$count (${(pct * 100).round()}%)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 8,
                backgroundColor: AppColors.border,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildOptions(
    BuildContext context,
    WidgetRef ref,
    String? uid,
  ) {
    return vote.options.map((option) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.xs),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: (uid == null || disabled)
                ? null
                : () => _castVote(context, ref, uid, option),
            child: Text(option),
          ),
        ),
      );
    }).toList();
  }

  Future<void> _castVote(
    BuildContext context,
    WidgetRef ref,
    String uid,
    String option,
  ) async {
    final communityId = ref.read(currentCommunityIdProvider);
    if (communityId == null) return;

    onBeforeVote();
    try {
      await ref.read(premiumRepositoryProvider).castVote(
            communityId,
            assemblyId,
            voteIndex,
            option,
            uid,
          );
      if (context.mounted) context.showSuccessSnackBar('Voto registrado');
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar('Error al votar: $e');
      }
    } finally {
      onAfterVote();
    }
  }
}
