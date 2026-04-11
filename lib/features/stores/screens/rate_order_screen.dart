import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/stores/providers/orders_provider.dart';
import 'package:vecindario_app/features/stores/providers/stores_provider.dart';
import 'package:vecindario_app/shared/models/review_model.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

class RateOrderScreen extends ConsumerStatefulWidget {
  final String orderId;

  const RateOrderScreen({super.key, required this.orderId});

  @override
  ConsumerState<RateOrderScreen> createState() => _RateOrderScreenState();
}

class _RateOrderScreenState extends ConsumerState<RateOrderScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      context.showErrorSnackBar('Selecciona una calificación');
      return;
    }

    setState(() => _isSubmitting = true);

    final order = ref.read(orderDetailProvider(widget.orderId)).value;
    final user = ref.read(currentUserProvider).value;
    if (order == null || user == null) return;

    try {
      final review = ReviewModel(
        id: '',
        targetId: order.storeId,
        targetType: ReviewTargetType.store,
        authorUid: user.id,
        authorName: user.displayName,
        authorPhotoURL: user.photoURL,
        rating: _rating.toDouble(),
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      await ref.read(storesRepositoryProvider).submitOrderReview(
            orderId: widget.orderId,
            review: review,
          );

      if (mounted) {
        context.showSuccessSnackBar('Calificación enviada');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Error al enviar calificación');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Calificar pedido')),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Pedido no encontrado'));
          }
          return SingleChildScrollView(
            padding: AppSizes.paddingAll,
            child: Column(
              children: [
                const SizedBox(height: AppSizes.xl),
                const Icon(Icons.star_outline,
                    size: 64, color: AppColors.warning),
                const SizedBox(height: AppSizes.md),
                Text(
                  '¿Cómo fue tu pedido en ${order.storeName}?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: AppSizes.xl),

                // Estrellas
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final starIndex = i + 1;
                    return GestureDetector(
                      onTap: () => setState(() => _rating = starIndex),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          starIndex <= _rating
                              ? Icons.star
                              : Icons.star_border,
                          size: 44,
                          color: starIndex <= _rating
                              ? AppColors.warning
                              : AppColors.textHint,
                        ),
                      ),
                    );
                  }),
                ),
                if (_rating > 0) ...[
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    _ratingLabel(_rating),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ],

                const SizedBox(height: AppSizes.xl),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Comentario opcional...',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: AppSizes.xl),
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Enviar calificación'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  String _ratingLabel(int r) {
    switch (r) {
      case 1:
        return 'Muy malo';
      case 2:
        return 'Malo';
      case 3:
        return 'Regular';
      case 4:
        return 'Bueno';
      case 5:
        return 'Excelente';
      default:
        return '';
    }
  }
}
