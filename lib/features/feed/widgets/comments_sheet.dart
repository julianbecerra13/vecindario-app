import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/config/backend_features.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/services/media_opener.dart';
import 'package:vecindario_app/core/extensions/datetime_extensions.dart';
import 'package:vecindario_app/features/feed/models/comment_model.dart';
import 'package:vecindario_app/features/feed/models/feed_attachment.dart';
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
  PendingFeedAttachment? _attachment;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    final user = ref.read(currentUserProvider).value;
    final communityId = ref.read(currentCommunityIdProvider);
    if ((text.isEmpty && _attachment == null) ||
        user == null ||
        communityId == null ||
        _sending) {
      return;
    }

    setState(() => _sending = true);
    try {
      final repository = ref.read(feedRepositoryProvider);
      final comment = CommentModel(
        id: '',
        authorUid: user.id,
        authorName: user.displayName,
        authorPhotoURL: user.photoURL,
        text: text,
        createdAt: DateTime.now(),
      );
      if (_attachment == null) {
        await repository.addComment(communityId, widget.postId, comment);
      } else {
        await repository.addCommentWithAttachment(
          communityId,
          widget.postId,
          comment,
          _attachment!,
        );
      }
      _controller.clear();
      if (mounted) setState(() => _attachment = null);
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

  Future<void> _pickAttachment() async {
    if (!kMediaUploadsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(kMediaUploadsUnavailableMessage)),
      );
      return;
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'webp',
        'pdf',
        'mp3',
        'm4a',
        'wav',
        'mp4',
        'mov',
      ],
    );
    final picked = result?.files.single;
    if (picked?.path == null || !mounted) return;
    final extension = (picked!.extension ?? '').toLowerCase();
    final type = {'jpg', 'jpeg', 'png', 'webp'}.contains(extension)
        ? FeedAttachmentType.image
        : {'mp3', 'm4a', 'wav'}.contains(extension)
        ? FeedAttachmentType.audio
        : {'mp4', 'mov'}.contains(extension)
        ? FeedAttachmentType.video
        : FeedAttachmentType.document;
    final maxSize = type == FeedAttachmentType.video
        ? 30 * 1024 * 1024
        : 10 * 1024 * 1024;
    if (picked.size > maxSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El archivo supera el límite permitido.')),
      );
      return;
    }
    setState(() {
      _attachment = PendingFeedAttachment(
        file: File(picked.path!),
        name: picked.name,
        type: type,
        size: picked.size,
      );
    });
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
                                    if (comment.attachment != null) ...[
                                      const SizedBox(height: AppSizes.xs),
                                      ActionChip(
                                        avatar: Icon(
                                          comment.attachment!.type ==
                                                  FeedAttachmentType.image
                                              ? Icons.image_outlined
                                              : Icons.attach_file,
                                          size: 18,
                                        ),
                                        label: Text(comment.attachment!.name),
                                        onPressed: () =>
                                            openMedia(comment.attachment!.url),
                                      ),
                                    ],
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
          if (_attachment != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.sm,
                AppSizes.xs,
                AppSizes.sm,
                0,
              ),
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.attach_file),
                title: Text(_attachment!.name, maxLines: 1),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _attachment = null),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.sm),
            child: Row(
              children: [
                IconButton(
                  tooltip: kMediaUploadsEnabled
                      ? 'Adjuntar archivo'
                      : 'Archivos próximamente',
                  onPressed: _sending ? null : _pickAttachment,
                  icon: const Icon(Icons.attach_file),
                ),
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
