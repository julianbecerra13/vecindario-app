import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/admin/providers/admin_providers.dart';
import 'package:vecindario_app/shared/models/user_model.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/services/cloud_functions_service.dart';
import 'package:vecindario_app/shared/widgets/cached_avatar.dart';
import 'package:vecindario_app/shared/widgets/empty_state.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

class PendingApprovalsScreen extends ConsumerWidget {
  const PendingApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingResidentsProvider);
    final communityId = ref.watch(currentCommunityIdProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.adminPendingApprovalsTitle)),
      body: pendingAsync.when(
        data: (residents) {
          if (residents.isEmpty) {
            return EmptyState(
              icon: Icons.check_circle_outline,
              title: context.l10n.adminAllCaughtUp,
              subtitle: context.l10n.adminNoPendingRequests,
            );
          }
          return ListView.builder(
            padding: AppSizes.paddingAll,
            itemCount: residents.length,
            itemBuilder: (_, i) => _ApprovalCard(
              user: residents[i],
              onApprove: () async {
                if (communityId == null) return;
                try {
                  await ref
                      .read(cloudFunctionsProvider)
                      .approveResident(residents[i].id, communityId);
                  if (context.mounted) {
                    context.showSuccessSnackBar(
                      context.l10n.adminUserApproved(residents[i].displayName),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    context.showErrorSnackBar(
                      context.l10n.adminApproveError('$e'),
                    );
                  }
                }
              },
              onReject: () async {
                if (communityId == null) return;
                try {
                  await ref
                      .read(cloudFunctionsProvider)
                      .rejectResident(residents[i].id, communityId);
                  if (context.mounted) {
                    context.showSnackBar(context.l10n.adminRequestRejected);
                  }
                } catch (e) {
                  if (context.mounted) {
                    context.showErrorSnackBar(
                      context.l10n.adminRejectError('$e'),
                    );
                  }
                }
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) =>
            Center(child: Text(context.l10n.adminGenericError('$e'))),
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApprovalCard({
    required this.user,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Padding(
        padding: AppSizes.paddingCard,
        child: Row(
          children: [
            CachedAvatar(
              imageUrl: user.photoURL,
              name: user.displayName,
              radius: 24,
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(user.unitInfo, style: AppTextStyles.bodySmall),
                  Text(user.email, style: AppTextStyles.caption),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.error),
              onPressed: onReject,
            ),
            const SizedBox(width: AppSizes.xs),
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.success),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.successLight,
              ),
              onPressed: onApprove,
            ),
          ],
        ),
      ),
    );
  }
}
