import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/features/access/access_repository.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';

/// A28 - Identificación temporal del residente.
class AccessScreen extends ConsumerStatefulWidget {
  const AccessScreen({super.key});
  @override
  ConsumerState<AccessScreen> createState() => _AccessScreenState();
}

class _AccessScreenState extends ConsumerState<AccessScreen> {
  String? _token;
  DateTime? _expiresAt;
  String? _error;
  bool _busy = false;

  Future<void> _issue() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null || user.communityId == null || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final token = await AccessRepository(
        ref.read(firestoreProvider),
      ).issue(user);
      if (!mounted) return;
      setState(() {
        _token = token;
        _expiresAt = DateTime.now().add(const Duration(minutes: 5));
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'No pudimos generar el QR. Revisa tu conexión.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null || user.communityId == null) {
      return const Scaffold(
        body: Center(child: Text('Selecciona tu conjunto')),
      );
    }
    final db = ref.watch(firestoreProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mi QR de acceso')),
      body: ListView(
        padding: AppSizes.paddingAll,
        children: [
          Text(
            'Identifícate sin compartir información privada.',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'El código dura cinco minutos, funciona una sola vez y requiere conexión para validarse.',
          ),
          const SizedBox(height: AppSizes.lg),
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: _token == null
                ? const SizedBox(
                    height: 240,
                    child: Center(
                      child: Icon(
                        Icons.qr_code_2,
                        size: 130,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      QrImageView(
                        data: 'vecindario-access:${user.communityId}:$_token',
                        size: 230,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        'Válido hasta ${_expiresAt!.hour.toString().padLeft(2, '0')}:${_expiresAt!.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: AppSizes.md),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(
                user.displayName,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(user.unitInfo),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          const SizedBox(height: AppSizes.lg),
          ElevatedButton.icon(
            onPressed: _busy ? null : _issue,
            icon: const Icon(Icons.refresh),
            label: Text(_token == null ? 'Generar mi QR' : 'Generar otro QR'),
          ),
          const SizedBox(height: AppSizes.md),
          StreamBuilder(
            stream: db
                .collection('communities')
                .doc(user.communityId)
                .collection('access_staff')
                .doc(user.id)
                .snapshots(),
            builder: (context, snapshot) {
              final authorized =
                  user.isCommunityAdmin ||
                  snapshot.data?.data()?['active'] == true;
              if (!authorized) return const SizedBox.shrink();
              return OutlinedButton.icon(
                onPressed: () => context.push('/access-control'),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Abrir control de acceso'),
              );
            },
          ),
        ],
      ),
    );
  }
}
