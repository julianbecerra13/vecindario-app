import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/features/services/providers/services_provider.dart';
import 'package:vecindario_app/features/services/widgets/rating_stars.dart';
import 'package:vecindario_app/shared/models/review_model.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

Future<void> showServiceReviewsSheet(BuildContext context, String serviceId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.9,
      child: _ServiceReviewsSheet(serviceId: serviceId),
    ),
  );
}

class _ServiceReviewsSheet extends ConsumerStatefulWidget {
  const _ServiceReviewsSheet({required this.serviceId});
  final String serviceId;

  @override
  ConsumerState<_ServiceReviewsSheet> createState() =>
      _ServiceReviewsSheetState();
}

class _ServiceReviewsSheetState extends ConsumerState<_ServiceReviewsSheet> {
  final _commentController = TextEditingController();
  double _rating = 5;
  bool _anonymous = false;
  bool _sending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null || _sending) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(servicesRepositoryProvider)
          .addReview(
            ReviewModel(
              id: '',
              targetId: widget.serviceId,
              targetType: ReviewTargetType.service,
              authorUid: user.id,
              authorName: _anonymous ? 'Reseña anónima' : user.displayName,
              authorPhotoURL: _anonymous ? null : user.photoURL,
              rating: _rating,
              comment: _commentController.text.trim(),
              createdAt: DateTime.now(),
            ),
          );
      _commentController.clear();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Reseña publicada')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No se pudo publicar: $error')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviews = ref.watch(serviceReviewsProvider(widget.serviceId));
    return Column(
      children: [
        ListTile(
          title: const Text(
            'Calificaciones y reseñas',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: reviews.when(
            data: (items) => items.isEmpty
                ? const Center(child: Text('Todavía no hay reseñas.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.md),
                    itemCount: items.length,
                    itemBuilder: (_, index) {
                      final review = items[index];
                      return Card(
                        child: ListTile(
                          title: Row(
                            children: [
                              Expanded(child: Text(review.authorName)),
                              RatingStars(rating: review.rating, size: 14),
                            ],
                          ),
                          subtitle: review.comment.isEmpty
                              ? null
                              : Text(review.comment),
                        ),
                      );
                    },
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('$error')),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.md,
            AppSizes.sm,
            AppSizes.md,
            MediaQuery.viewInsetsOf(context).bottom + AppSizes.sm,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('Tu calificación:'),
                  const Spacer(),
                  ...List.generate(5, (index) {
                    final value = index + 1.0;
                    return IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => setState(() => _rating = value),
                      icon: Icon(
                        value <= _rating ? Icons.star : Icons.star_border,
                        color: AppColors.warning,
                      ),
                    );
                  }),
                ],
              ),
              TextField(
                controller: _commentController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Cuéntale tu experiencia a la comunidad',
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _anonymous,
                    onChanged: (value) =>
                        setState(() => _anonymous = value ?? false),
                  ),
                  const Expanded(child: Text('Publicar como anónimo')),
                  FilledButton(
                    onPressed: _sending ? null : _submit,
                    child: Text(_sending ? 'Publicando…' : 'Publicar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
