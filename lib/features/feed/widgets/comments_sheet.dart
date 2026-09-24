import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/datetime_extensions.dart';
import 'package:vecindario_app/features/feed/models/comment_model.dart';
import 'package:vecindario_app/features/feed/providers/comments_provider.dart';
import 'package:vecindario_app/features/feed/providers/feed_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/widgets/cached_avatar.dart';

Future<void> showCommentsSheet(BuildContext context, String postId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.9,
      child: _CommentsSheet(postId: postId),
    ),
  );
}

class _CommentsSheet extends ConsumerStatefulWidget {
  const _CommentsSheet({required this.postId});

  final String postId;

  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    final user = ref.read(currentUserProvider).value;
    final communityId = ref.read(currentCommunityIdProvider);
    if (text.isEmpty || user == null || communityId == null || _sending) return;

    setState(() => _sending = true);
    try {
      await ref
          .read(feedRepositoryProvider)
          .addComment(
            communityId,
            widget.postId,
            CommentModel(
              id: '',
              authorUid: user.id,
              authorName: user.displayName,
              authorPhotoURL: user.photoURL,
              text: text,
              createdAt: DateTime.now(),
            ),
          );
      _controller.clear();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo publicar el comentario: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(commentsProvider(widget.postId));

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md,
              AppSizes.sm,
              AppSizes.xs,
              AppSizes.sm,
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Comentarios',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: comments.when(
              data: (items) => items.isEmpty
                  ? const Center(
                      child: Text('Sé la primera persona en comentar.'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSizes.md),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        final comment = items[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CachedAvatar(
                              imageUrl: comment.authorPhotoURL,
                              name: comment.authorName,
                              radius: 18,
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment.authorName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(comment.text),
                                    const SizedBox(height: 2),
                                    Text(
                                      comment.createdAt.timeAgoText,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('No se pudieron cargar los comentarios: $error'),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSizes.sm),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un comentario…',
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: AppSizes.xs),
                IconButton.filled(
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: _sending ? null : _send,
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
