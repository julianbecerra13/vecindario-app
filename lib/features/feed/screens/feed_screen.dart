import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/feed/providers/feed_provider.dart';
import 'package:vecindario_app/features/feed/widgets/post_card.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/community_provider.dart';
import 'package:vecindario_app/shared/widgets/cached_avatar.dart';
import 'package:vecindario_app/shared/widgets/empty_state.dart';
import 'package:vecindario_app/shared/widgets/error_display.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';
import 'package:vecindario_app/features/notifications/providers/notification_providers.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  late TextEditingController _searchController;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final WidgetRef ref = this.ref;
    final postsAsync = ref.watch(feedPostsProvider);
    final communityAsync = ref.watch(currentCommunityProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSizes.md,
        title: _showSearch
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar en el feed...',
                  border: InputBorder.none,
                  hintStyle: const TextStyle(fontSize: 14),
                ),
                onChanged: (value) {
                  ref.read(feedSearchProvider.notifier).state = value;
                },
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MI COMUNIDAD',
                    style: AppTextStyles.caption.copyWith(
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  communityAsync.when(
                    data: (community) => Text(
                      community?.name ?? 'Vecindario',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    loading: () => const Text(
                      'Cargando...',
                      style: TextStyle(fontSize: 16),
                    ),
                    error: (_, __) => const Text(
                      'Vecindario',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
        actions: [
          if (_showSearch)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _showSearch = false;
                  _searchController.clear();
                  ref.read(feedSearchProvider.notifier).state = '';
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _showSearch = true;
                });
              },
            ),
          Builder(
            builder: (context) {
              final unread = ref.watch(unreadCountProvider);
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => context.push('/notifications'),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          unread > 9 ? '9+' : '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.sm),
            child: GestureDetector(
              onTap: () => context.go('/profile'),
              child: userAsync.when(
                data: (user) => CachedAvatar(
                  imageUrl: user?.photoURL,
                  name: user?.displayName ?? '?',
                  radius: 16,
                ),
                loading: () => const CircleAvatar(radius: 16),
                error: (_, __) => const CircleAvatar(radius: 16),
              ),
            ),
          ),
        ],
      ),
      body: postsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const EmptyState(
              icon: Icons.article_outlined,
              title: 'Sin noticias aún',
              subtitle: 'Sé el primero en compartir algo con tu comunidad',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(feedPostsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.only(
                top: AppSizes.sm,
                bottom: AppSizes.xxxl,
              ),
              itemCount: posts.length,
              itemBuilder: (_, i) {
                // Banner publicitario cada 5 posts
                if (i > 0 && i % 5 == 0) {
                  return Column(
                    children: [
                      _AdBanner(),
                      PostCard(
                        post: posts[i],
                        onTap: () => context.push('/feed/${posts[i].id}'),
                      ),
                    ],
                  );
                }
                return PostCard(
                  post: posts[i],
                  onTap: () => context.push('/feed/${posts[i].id}'),
                );
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorDisplay(
          message: 'Error al cargar noticias',
          onRetry: () => ref.invalidate(feedPostsProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'feed_fab',
        onPressed: () => context.push('/feed/create'),
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class _AdBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      padding: const EdgeInsets.all(AppSizes.sm + AppSizes.xs),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primaryDark.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PATROCINADO',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Espacio publicitario disponible',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.ads_click, color: AppColors.textHint, size: 20),
        ],
      ),
    );
  }
}
