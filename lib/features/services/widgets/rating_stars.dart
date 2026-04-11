import 'package:flutter/material.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final int? showCount;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.showCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          if (i < rating.floor()) {
            return Icon(Icons.star, size: size, color: Colors.amber);
          } else if (i < rating) {
            return Icon(Icons.star_half, size: size, color: Colors.amber);
          }
          return Icon(Icons.star_border, size: size, color: AppColors.border);
        }),
        if (showCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($showCount)',
            style: TextStyle(
              fontSize: size * 0.75,
              color: AppColors.textHint,
            ),
          ),
        ],
      ],
    );
  }
}
