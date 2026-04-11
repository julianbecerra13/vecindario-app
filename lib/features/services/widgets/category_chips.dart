import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/features/services/models/service_model.dart';
import 'package:vecindario_app/features/services/providers/services_provider.dart';

class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.sm),
            child: ChoiceChip(
              label: const Text('Todas'),
              selected: selected == null,
              onSelected: (_) =>
                  ref.read(selectedCategoryProvider.notifier).state = null,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selected == null ? Colors.white : AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          ...ServiceCategory.values.map((cat) {
            final isSelected = selected == cat;
            return Padding(
              padding: const EdgeInsets.only(right: AppSizes.sm),
              child: ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon, size: 14,
                      color: isSelected ? Colors.white : cat.color),
                    const SizedBox(width: 4),
                    Text(cat.label),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) =>
                    ref.read(selectedCategoryProvider.notifier).state =
                        isSelected ? null : cat,
                selectedColor: cat.color,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
