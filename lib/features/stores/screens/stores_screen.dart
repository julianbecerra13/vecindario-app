import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';
import 'package:vecindario_app/features/stores/providers/stores_provider.dart';
import 'package:vecindario_app/features/stores/widgets/store_card.dart';
import 'package:vecindario_app/shared/widgets/empty_state.dart';
import 'package:vecindario_app/shared/widgets/error_display.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';
import 'package:vecindario_app/shared/providers/community_provider.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';

class StoresScreen extends ConsumerWidget {
  const StoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(storesListProvider);
    final communityAsync = ref.watch(currentCommunityProvider);
    final estrato = communityAsync.whenOrNull(data: (c) => c?.estrato) ?? 3;
    final fee = OrderModel.calculateServiceFee(estrato);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.storeScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => context.push('/stores/orders'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner
          Container(
            margin: const EdgeInsets.all(AppSizes.md),
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.success, AppColors.secondaryDark],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Row(
              children: [
                const Text('🛒', style: TextStyle(fontSize: 28)),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.storeBannerTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        context.l10n.storeBannerSubtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFD1FAE5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Lista
          Expanded(
            child: storesAsync.when(
              data: (stores) {
                if (stores.isEmpty) {
                  return EmptyState(
                    icon: Icons.store_outlined,
                    title: context.l10n.storeEmptyTitle,
                    subtitle: context.l10n.storeEmptySubtitle,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(storesListProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: AppSizes.xxxl),
                    itemCount: stores.length,
                    itemBuilder: (_, i) => StoreCard(
                      store: stores[i],
                      estratoFee: fee,
                      onTap: () => context.push('/stores/${stores[i].id}'),
                    ),
                  ),
                );
              },
              loading: () => const LoadingIndicator(),
              error: (e, _) => ErrorDisplay(
                message: context.l10n.storeLoadError,
                onRetry: () => ref.invalidate(storesListProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
