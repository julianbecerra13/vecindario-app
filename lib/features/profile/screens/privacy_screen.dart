import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/core/utils/logger.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({super.key});

  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _analyticsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadConsents();
  }

  Future<void> _loadConsents() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    try {
      final consents = await ref
          .read(userRepositoryProvider)
          .getConsents(user.id);
      if (mounted) {
        setState(() {
          _pushEnabled = consents['pushNotifications'] ?? true;
          _emailEnabled = consents['emailMarketing'] ?? false;
          _analyticsEnabled = consents['analytics'] ?? true;
        });
      }
    } catch (e) {
      AppLogger.error('Error cargando consentimientos', e);
    }
  }

  Future<void> _updateConsent(String key, bool value) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    await ref.read(userRepositoryProvider).updateConsents(user.id, {
      'pushNotifications': _pushEnabled,
      'emailMarketing': _emailEnabled,
      'analytics': _analyticsEnabled,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.privacyTitle)),
      body: ListView(
        padding: AppSizes.paddingAll,
        children: [
          // Header Ley 1581
          Container(
            padding: AppSizes.paddingAll,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield, color: AppColors.primary, size: 32),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.profileLaw1581Title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.profileLaw1581Description,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // === MIS DATOS ===
          _SectionHeader(title: context.l10n.profileMyDataSection),
          const SizedBox(height: AppSizes.sm),
          _PrivacyAction(
            icon: Icons.download,
            title: context.l10n.downloadData,
            subtitle: context.l10n.profileDownloadDataSubtitle,
            onTap: () {
              final user = ref.read(currentUserProvider).value;
              if (user != null) {
                ref.read(userRepositoryProvider).requestDataExport(user.id);
                context.showSuccessSnackBar(
                  context.l10n.profileDataExportRequested,
                );
              }
            },
          ),
          const Divider(height: 1),
          _PrivacyAction(
            icon: Icons.edit,
            title: context.l10n.profileEditPersonalInfoTitle,
            subtitle: context.l10n.profileEditPersonalInfoSubtitle,
            onTap: () => context.push('/profile/edit'),
          ),

          const SizedBox(height: AppSizes.lg),

          // === CONSENTIMIENTOS ===
          _SectionHeader(title: context.l10n.profileConsentsSection),
          const SizedBox(height: AppSizes.sm),
          _ConsentToggle(
            icon: Icons.notifications,
            title: context.l10n.profilePushNotificationsTitle,
            value: _pushEnabled,
            onChanged: (v) {
              setState(() => _pushEnabled = v);
              _updateConsent('pushNotifications', v);
            },
          ),
          const Divider(height: 1),
          _ConsentToggle(
            icon: Icons.email,
            title: context.l10n.profileEmailNewsTitle,
            value: _emailEnabled,
            onChanged: (v) {
              setState(() => _emailEnabled = v);
              _updateConsent('emailMarketing', v);
            },
          ),
          const Divider(height: 1),
          _ConsentToggle(
            icon: Icons.bar_chart,
            title: context.l10n.profileAnalyticsTitle,
            value: _analyticsEnabled,
            onChanged: (v) {
              setState(() => _analyticsEnabled = v);
              _updateConsent('analytics', v);
            },
          ),

          const SizedBox(height: AppSizes.lg),

          // === LEGAL ===
          _SectionHeader(title: context.l10n.profileLegalSection),
          const SizedBox(height: AppSizes.sm),
          _PrivacyAction(
            icon: Icons.description,
            title: context.l10n.privacyPolicy,
            subtitle: context.l10n.profilePrivacyPolicySubtitle,
            onTap: () => context.push('/profile/privacy-policy'),
          ),
          const Divider(height: 1),
          _PrivacyAction(
            icon: Icons.assignment,
            title: context.l10n.termsOfUse,
            subtitle: context.l10n.profileTermsSubtitle,
            onTap: () => context.push('/profile/terms'),
          ),

          const SizedBox(height: AppSizes.lg),

          // === ZONA DE PELIGRO ===
          _SectionHeader(
            title: context.l10n.profileDangerZoneTitle,
            isDestructive: true,
          ),
          const SizedBox(height: AppSizes.sm),
          Container(
            padding: AppSizes.paddingAll,
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      context.l10n.profileIrreversibleAction,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  context.l10n.profileCannotRecoverAfter15Days,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  context.l10n.profileWillBeDeletedLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                _DeleteItem(
                  text: context.l10n.profileProfileAndPhotoItem,
                  isDelete: true,
                ),
                _DeleteItem(
                  text: context.l10n.profileVerificationDocsItem,
                  isDelete: true,
                ),
                _DeleteItem(
                  text: context.l10n.profileTokensSessionsItem,
                  isDelete: true,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  context.l10n.profileWillBeAnonymizedLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                _DeleteItem(
                  text: context.l10n.profilePostsAnonymizedItem,
                  isDelete: false,
                ),
                _DeleteItem(
                  text: context.l10n.profileReviewsAnonymizedItem,
                  isDelete: false,
                ),
                _DeleteItem(
                  text: context.l10n.profileOrdersAnonymizedItem,
                  isDelete: false,
                ),
                const SizedBox(height: AppSizes.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteAccountDialog(context),
                    icon: const Icon(
                      Icons.delete_forever,
                      color: AppColors.error,
                    ),
                    label: Text(
                      context.l10n.profileDeleteAccountButtonLabel,
                      style: const TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final passwordController = TextEditingController();
    bool isLoading = false;
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            context.l10n.profileDeleteAccountDialogTitle,
            style: const TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.profileDeleteConfirmMessage,
                style: TextStyle(fontSize: 13, color: ctx.colors.textSecondary),
              ),
              const SizedBox(height: AppSizes.md),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.l10n.profileConfirmPasswordLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  errorText: errorText,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final password = passwordController.text;
                      if (password.isEmpty) {
                        setDialogState(
                          () => errorText =
                              context.l10n.profileEnterPasswordError,
                        );
                        return;
                      }

                      setDialogState(() {
                        isLoading = true;
                        errorText = null;
                      });

                      try {
                        // Reautenticar con contraseña real
                        final firebaseUser = FirebaseAuth.instance.currentUser!;
                        final credential = EmailAuthProvider.credential(
                          email: firebaseUser.email!,
                          password: password,
                        );
                        await firebaseUser.reauthenticateWithCredential(
                          credential,
                        );

                        // Contraseña correcta — proceder con eliminación
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        final user = ref.read(currentUserProvider).value;
                        if (user != null) {
                          ref
                              .read(userRepositoryProvider)
                              .requestAccountDeletion(user.id);
                          if (context.mounted) {
                            context.showSnackBar(
                              context.l10n.profileAccountDeletionScheduled,
                            );
                          }
                        }
                      } on FirebaseAuthException catch (e) {
                        setDialogState(() {
                          isLoading = false;
                          errorText = e.code == 'wrong-password'
                              ? context.l10n.profileWrongPassword
                              : context.l10n.profileAuthError;
                        });
                      } catch (e) {
                        setDialogState(() {
                          isLoading = false;
                          errorText = context.l10n.profileUnexpectedErrorShort;
                        });
                      }
                    },
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(context.l10n.deleteAccount),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDestructive;

  const _SectionHeader({required this.title, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: isDestructive ? AppColors.error : context.colors.textHint,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _PrivacyAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PrivacyAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      trailing: Icon(Icons.chevron_right, color: context.colors.textHint),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _ConsentToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ConsentToggle({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyMedium),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.success,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _DeleteItem extends StatelessWidget {
  final String text;
  final bool isDelete;

  const _DeleteItem({required this.text, required this.isDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 3),
      child: Row(
        children: [
          Text(
            isDelete ? '✕ ' : '~ ',
            style: TextStyle(
              color: isDelete ? AppColors.error : AppColors.warning,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isDelete ? AppColors.error : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}
