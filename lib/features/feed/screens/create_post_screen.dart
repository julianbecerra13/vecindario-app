import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/feed/models/post_model.dart';
import 'package:vecindario_app/features/feed/providers/post_notifier.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _textController = TextEditingController();
  PostType _selectedType = PostType.news;
  final List<TextEditingController> _pollControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    _textController.dispose();
    for (final c in _pollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _publish() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      context.showErrorSnackBar(context.l10n.feedWriteSomething);
      return;
    }

    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    List<PollOption>? pollOptions;
    if (_selectedType == PostType.poll) {
      final options = _pollControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      if (options.length < 2) {
        context.showErrorSnackBar(context.l10n.feedAddAtLeast2Options);
        return;
      }
      pollOptions = options.map((t) => PollOption(text: t)).toList();
    }

    final post = PostModel(
      id: '',
      authorUid: user.id,
      authorName: user.displayName,
      authorPhotoURL: user.photoURL,
      text: text,
      type: _selectedType,
      pollOptions: pollOptions,
      createdAt: DateTime.now(),
    );

    final success = await ref
        .read(postNotifierProvider.notifier)
        .createPost(post);
    if (success && mounted) {
      context.showSuccessSnackBar(context.l10n.feedPublished);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(postNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.publish),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.sm),
            child: ElevatedButton(
              onPressed: actionState.isLoading ? null : _publish,
              style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
              child: actionState.isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(context.l10n.publish),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSizes.paddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo de post
            Wrap(
              spacing: AppSizes.sm,
              children: PostType.values.map((type) {
                final selected = _selectedType == type;
                return ChoiceChip(
                  label: Text(type.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedType = type),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : context.colors.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.md),
            // Texto
            TextField(
              controller: _textController,
              maxLines: null,
              minLines: 4,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: _selectedType == PostType.alert
                    ? context.l10n.feedAlertHint
                    : context.l10n.feedShareHint,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
            // Opciones de encuesta
            if (_selectedType == PostType.poll) ...[
              const SizedBox(height: AppSizes.md),
              Text(
                context.l10n.feedPollOptionsTitle,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: AppSizes.sm),
              ..._pollControllers.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: TextField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      hintText: context.l10n.feedPollOptionHint(entry.key + 1),
                      suffixIcon: _pollControllers.length > 2
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                setState(() {
                                  _pollControllers[entry.key].dispose();
                                  _pollControllers.removeAt(entry.key);
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                );
              }),
              if (_pollControllers.length < 4)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _pollControllers.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: Text(context.l10n.feedAddOption),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
