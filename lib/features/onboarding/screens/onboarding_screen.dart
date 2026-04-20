import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      icon: Icons.groups_rounded,
      title: 'Tu comunidad, conectada',
      description:
          'Noticias, alertas y comunicados de tu conjunto en un solo lugar. Sin perderse nada en el chat.',
    ),
    _OnboardingPage(
      icon: Icons.storefront_rounded,
      title: 'Compra a tus vecinos',
      description:
          'Descubre emprendimientos y servicios de tu comunidad. Apoya a quien vive al lado.',
    ),
    _OnboardingPage(
      icon: Icons.verified_user_rounded,
      title: 'Servicios de confianza',
      description:
          'Directorio de profesionales recomendados por tus vecinos. Electricistas, plomeros y más.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _complete,
                child: const Text('Saltar'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            Padding(
              padding: AppSizes.paddingAll,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => Container(
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _complete();
                      }
                    },
                    child: Text(
                      _currentPage < _pages.length - 1
                          ? 'Siguiente'
                          : 'Comenzar',
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSizes.paddingAll,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 60, color: AppColors.primary),
          ),
          const SizedBox(height: AppSizes.xl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
