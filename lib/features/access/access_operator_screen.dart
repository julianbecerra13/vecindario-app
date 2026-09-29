import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/features/access/access_repository.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';

/// O01-O04 - Herramienta limitada del operario de acceso.
class AccessOperatorScreen extends ConsumerStatefulWidget {
  const AccessOperatorScreen({super.key});
  @override
  ConsumerState<AccessOperatorScreen> createState() =>
      _AccessOperatorScreenState();
}

class _AccessOperatorScreenState extends ConsumerState<AccessOperatorScreen> {
  final _zone = TextEditingController(text: 'Piscina');
  int _residents = 1;
  int _visitors = 0;
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _zone.dispose();
    super.dispose();
  }

  Future<void> _scan(String raw) async {
    if (_busy) return;
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null || user.communityId == null) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final parts = raw.split(':');
      if (parts.length != 3 ||
          !{'vecindario-access', 'vecindario-visitor'}.contains(parts[0]) ||
          parts[1] != user.communityId ||
          !RegExp(r'^[a-zA-Z0-9-]{36}$').hasMatch(parts[2])) {
        throw StateError('invalid');
      }
      final repository = AccessRepository(ref.read(firestoreProvider));
      if (parts[0] == 'vecindario-visitor') {
        final info = await repository.inspectVisitor(
          user.communityId!,
          parts[2],
        );
        if (!mounted) return;
        final accepted = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(
              Icons.badge_outlined,
              color: AppColors.primary,
              size: 42,
            ),
            title: const Text('Visita autorizada'),
            content: Text(
              '${info['visitorName']}\nAutoriza: ${info['residentName']}\n${info['unit']}\n\nEl pase es individual y quedará marcado como usado.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Registrar ingreso'),
              ),
            ],
          ),
        );
        if (accepted == true) {
          await repository.admitVisitor(
            user.communityId!,
            parts[2],
            user.id,
            _zone.text.trim(),
          );
          if (mounted) {
            setState(() => _message = 'Ingreso de visitante registrado.');
          }
        }
        return;
      }
      final info = await repository.inspect(user.communityId!, parts[2]);
      if (!mounted) return;
      final status = switch (info['administrationStatus']) {
        'current' => 'Al día',
        'overdue' => 'Vencida',
        _ => 'Sin información',
      };
      final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(
            Icons.verified_user_outlined,
            color: AppColors.primary,
            size: 42,
          ),
          title: const Text('Identidad validada'),
          content: Text(
            '${info['name']}\n${info['unit']}\n\nAdministración: $status\nZona: ${_zone.text}\nResidentes: $_residents · Visitantes: $_visitors\n\nLa deuda no bloquea automáticamente el ingreso.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Registrar ingreso'),
            ),
          ],
        ),
      );
      if (accepted != true) {
        return;
      }
      await repository.admit(
        user.communityId!,
        parts[2],
        user.id,
        _zone.text.trim(),
        _residents,
        _visitors,
      );
      if (mounted) {
        setState(() => _message = 'Ingreso registrado correctamente.');
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _message = 'QR no válido, vencido, usado o de otro conjunto.',
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
      return const Scaffold(body: Center(child: Text('Acceso restringido')));
    }
    final db = ref.watch(firestoreProvider);
    return StreamBuilder(
      stream: db
          .collection('communities')
          .doc(user.communityId)
          .collection('access_staff')
          .doc(user.id)
          .snapshots(),
      builder: (context, snapshot) {
        final authorized =
            user.isCommunityAdmin || snapshot.data?.data()?['active'] == true;
        if (!authorized) {
          return const Scaffold(
            body: Center(
              child: Text('No tienes permiso para operar el lector.'),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Control de acceso')),
          body: ListView(
            padding: AppSizes.paddingAll,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'OPERARIO ACTIVO · Validación en línea',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              TextField(
                controller: _zone,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Punto o zona de acceso',
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _residents,
                      decoration: const InputDecoration(
                        labelText: 'Residentes',
                      ),
                      items: List.generate(
                        50,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('${i + 1}'),
                        ),
                      ),
                      onChanged: _busy
                          ? null
                          : (value) => setState(() => _residents = value!),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _visitors,
                      decoration: const InputDecoration(
                        labelText: 'Visitantes',
                      ),
                      items: List.generate(
                        51,
                        (i) => DropdownMenuItem(value: i, child: Text('$i')),
                      ),
                      onChanged: _busy
                          ? null
                          : (value) => setState(() => _visitors = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 330,
                  child: MobileScanner(
                    errorBuilder: (_, __, ___) => const Center(
                      child: Text(
                        'No se pudo abrir la cámara. Revisa el permiso.',
                      ),
                    ),
                    onDetect: (capture) {
                      if (_busy || capture.barcodes.isEmpty) return;
                      final raw = capture.barcodes.first.rawValue;
                      if (raw != null) _scan(raw);
                    },
                  ),
                ),
              ),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(),
                ),
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _message!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
