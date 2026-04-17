import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/datetime_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/feed/providers/feed_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

class FeedDetailScreen extends ConsumerWidget {
  final String postId;

  const FeedDetailScreen({required this.postId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postDetailProvider(postId));
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
      ),
      body: postAsync.when(
        data: (post) {
          if (post == null) {
            return const Center(
              child: Text('Post no encontrado'),
            );
          }
          final isLiked = post.likedBy.contains(currentUser?.id);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con info del autor
                Row(
                  children: [
                    if (post.authorPhotoURL != null)
                      CircleAvatar(
                        backgroundImage: NetworkImage(post.authorPhotoURL!),
                        radius: 28,
                      )
                    else
                      const CircleAvatar(
                        child: Icon(Icons.person),
                        radius: 28,
                      ),
                    const SizedBox(width: AppSizes.md),
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
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.push_pin, size: 12, color: AppColors.warning),
                            const SizedBox(width: 2),
                            Text(
                              'Fijado',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),

                // Badge de tipo
                if (post.type.name.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Text(
                      post.type.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSizes.md),

                // Contenido de texto
                Text(
                  post.text,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSizes.lg),

                // Imágenes
                if (post.imageURLs.isNotEmpty) ...[
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSizes.xs,
                      crossAxisSpacing: AppSizes.xs,
                    ),
                    itemCount: post.imageURLs.length,
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      child: Image.network(
                        post.imageURLs[i],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                ],

                // Encuesta si aplica
                if (post.pollOptions != null && post.pollOptions!.isNotEmpty) ...[
                  Text(
                    'Encuesta',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  ...List.generate(post.pollOptions!.length, (i) {
                    final option = post.pollOptions![i];
                    final totalVotes = post.pollOptions!.fold<int>(
                      0,
                      (sum, opt) => sum + opt.votes,
                    );
                    final percentage =
                        totalVotes > 0 ? (option.votes / totalVotes) * 100 : 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  option.text,
                                  style: AppTextStyles.bodySmall,
                                ),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(0)}%',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: AppSizes.lg),
                ],

                // Likes y comentarios
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.sm,
                    horizontal: AppSizes.md,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.border),
                      bottom: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${post.likes} Me gusta',
                        style: AppTextStyles.caption,
                      ),
                      Text(
                        '${post.commentCount} comentarios',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.sm),

                // Botones de interacción
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: currentUser == null
                            ? null
                            : () {
                                ref
                                    .read(feedRepositoryProvider)
                                    .toggleLike('', postId, currentUser.id, isLiked);
                              },
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_outline,
                          color: isLiked ? AppColors.error : AppColors.textHint,
                        ),
                        label: Text(
                          'Me gusta',
                          style: TextStyle(
                            color: isLiked ? AppColors.error : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.comment_outlined),
                        label: const Text('Comentar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(
          child: Text('Error: $e'),
        ),
      ),
    );
  }
}
