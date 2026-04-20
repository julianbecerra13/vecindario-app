import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/datetime_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/feed/models/post_model.dart';
import 'package:vecindario_app/features/feed/providers/post_notifier.dart';
import 'package:vecindario_app/features/feed/widgets/image_carousel.dart';
import 'package:vecindario_app/features/feed/widgets/poll_widget.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vecindario_app/shared/widgets/cached_avatar.dart';

class PostCard extends ConsumerWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final VoidCallback? onComment;

  const PostCard({super.key, required this.post, this.onTap, this.onComment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).value;
    final isAuthor = currentUser?.id == post.authorUid;
    final isLiked = currentUser != null && post.isLikedBy(currentUser.id);
    final isAdmin = ref.watch(isAdminProvider);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.type == PostType.alert)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSizes.cardRadius),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.white, size: 18),
                    SizedBox(width: AppSizes.sm),
                    Text(
                      'ALERTA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: AppSizes.paddingCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      CachedAvatar(
                        imageUrl: post.authorPhotoURL,
                        name: post.authorName,
                        radius: 18,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.authorName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              post.createdAt.timeAgoText,
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      if (post.pinned)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.sm,
                            vertical: AppSizes.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusFull,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.push_pin,
                                size: 12,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'Fijado',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            ref
                                .read(postNotifierProvider.notifier)
                                .deletePost(post.id);
                          } else if (value == 'pin') {
                            ref
                                .read(postNotifierProvider.notifier)
                                .pinPost(post.id, !post.pinned);
                          } else if (value == 'report') {
                            _showReportDialog(
                              context,
                              ref,
                              post,
                              currentUser?.id ?? '',
                            );
                          }
                        },
                        itemBuilder: (_) => [
                          if (isAdmin)
                            PopupMenuItem(
                              value: 'pin',
                              child: Text(
                                post.pinned ? 'Desfijar' : 'Fijar arriba',
                              ),
                            ),
                          if (isAuthor || isAdmin)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                'Eliminar',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          if (!isAuthor)
                            const PopupMenuItem(
                              value: 'report',
                              child: Text('Reportar'),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  // Texto
                  Text(post.text, style: AppTextStyles.bodyMedium),
                  // Imágenes
                  if (post.imageURLs.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.sm),
                    ImageCarousel(imageUrls: post.imageURLs),
                  ],
                  // Encuesta
                  if (post.type == PostType.poll &&
                      post.pollOptions != null) ...[
                    const SizedBox(height: AppSizes.sm),
                    PollWidget(
                      options: post.pollOptions!,
                      postId: post.id,
                      currentUid: currentUser?.id ?? '',
                    ),
                  ],
                  const SizedBox(height: AppSizes.sm),
                  const Divider(height: 1),
                  const SizedBox(height: AppSizes.xs),
                  // Footer
                  Row(
                    children: [
                      _ActionButton(
                        icon: isLiked ? Icons.favorite : Icons.favorite_border,
                        label: '${post.likes}',
                        color: isLiked ? AppColors.error : null,
                        onTap: () {
                          if (currentUser == null) return;
                          ref
                              .read(postNotifierProvider.notifier)
                              .toggleLike(post.id, currentUser.id, isLiked);
                        },
                      ),
                      const SizedBox(width: AppSizes.md),
                      _ActionButton(
                        icon: Icons.chat_bubble_outline,
                        label: '${post.commentCount}',
                        onTap: onComment ?? onTap,
                      ),
                      const SizedBox(width: AppSizes.md),
                      _ActionButton(
                        icon: Icons.share_outlined,
                        label: '',
                        onTap: () {
                          Share.share('${post.authorName}: ${post.text}');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showReportDialog(
  BuildContext context,
  WidgetRef ref,
  PostModel post,
  String uid,
) {
  final reasons = [
    'Contenido inapropiado',
    'Spam o publicidad',
    'Información falsa',
    'Acoso o intimidación',
    'Otro',
  ];
  showModalBottomSheet(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text('Reportar publicación', style: AppTextStyles.heading3),
          ),
          ...reasons.map(
            (reason) => ListTile(
              title: Text(reason),
              onTap: () {
                ref
                    .read(postNotifierProvider.notifier)
                    .reportPost(post.id, uid, reason);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reporte enviado')),
                );
              },
            ),
          ),
          const SizedBox(height: AppSizes.md),
        ],
      ),
    ),
  );
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.xs,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: color ?? AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
