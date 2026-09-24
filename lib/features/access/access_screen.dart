import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vecindario_app/features/access/access_repository.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';

class AccessScreen extends ConsumerStatefulWidget {
  const AccessScreen({super.key});
  @override
  ConsumerState<AccessScreen> createState() => _AccessScreenState();
}

class _AccessScreenState extends ConsumerState<AccessScreen> {
  String? token;
  DateTime? expires;
  String? message;
  bool busy = false;
  bool scanning = false;
  final zone = TextEditingController(text: 'Piscina');
  int residents = 1;
  int visitors = 0;

  @override
  void dispose() {
    zone.dispose();
    super.dispose();
  }

  Future<void> perform(Future<void> Function() action) async {
    if (busy) return;
    setState(() {
      busy = true;
      message = null;
    });
    try {
      await action();
    } catch (_) {
      if (mounted)
        setState(
          () => message =
              'No fue posible validar la operación. Revisa la conexión, permisos y vigencia del QR.',
        );
    } finally {
      if (mounted) setState(() => busy = false);
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
    final repository = AccessRepository(db);
    return Scaffold(
      appBar: AppBar(title: const Text('Acceso a zonas comunes')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (user.isCommunityAdmin)
            OutlinedButton.icon(
              onPressed: () => context.push('/premium/access-management'),
              icon: const Icon(Icons.manage_accounts_outlined),
              label: const Text('Administrar operarios'),
            ),
          Text(user.displayName, style: Theme.of(context).textTheme.titleLarge),
          const Text(
            'QR temporal de un solo ingreso. Requiere conexión para validarlo.',
          ),
          if (token != null) ...[
            Center(
              child: QrImageView(
                data: 'vecindario-access:${user.communityId}:$token',
                size: 240,
                backgroundColor: Colors.white,
              ),
            ),
            Text(
              'Válido hasta ${expires!.hour.toString().padLeft(2, '0')}:${expires!.minute.toString().padLeft(2, '0')}. Si vence, genera otro.',
            ),
          ],
          FilledButton.icon(
            onPressed: busy
                ? null
                : () => perform(() async {
                    final value = await repository.issue(user);
                    if (mounted)
                      setState(() {
                        token = value;
                        expires = DateTime.now().add(
                          const Duration(minutes: 5),
                        );
                      });
                  }),
            icon: const Icon(Icons.qr_code),
            label: const Text('Generar mi QR'),
          ),
          if (busy) const LinearProgressIndicator(),
          if (message != null)
            Padding(padding: const EdgeInsets.all(12), child: Text(message!)),
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
              return Column(
                children: [
                  const Divider(),
                  const Text('Operario · registrar ingreso'),
                  TextField(
                    controller: zone,
                    decoration: const InputDecoration(labelText: 'Zona común'),
                    maxLength: 100,
                  ),
                  Row(
                    children: [
                      const Text('Residentes: '),
                      DropdownButton<int>(
                        value: residents,
                        items: List.generate(
                          50,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text('${i + 1}'),
                          ),
                        ),
                        onChanged: busy
                            ? null
                            : (v) => setState(() => residents = v!),
                      ),
                      const SizedBox(width: 12),
                      const Text('Visitantes: '),
                      DropdownButton<int>(
                        value: visitors,
                        items: List.generate(
                          51,
                          (i) => DropdownMenuItem(value: i, child: Text('$i')),
                        ),
                        onChanged: busy
                            ? null
                            : (v) => setState(() => visitors = v!),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: busy
                        ? null
                        : () => setState(() => scanning = !scanning),
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(scanning ? 'Cerrar lector' : 'Escanear QR'),
                  ),
                  if (scanning)
                    SizedBox(
                      height: 260,
                      child: MobileScanner(
                        errorBuilder: (_, error, child) => const Center(
                          child: Text(
                            'No se pudo abrir la cámara. Revisa sus permisos.',
                          ),
                        ),
                        onDetect: (capture) {
                          if (busy || capture.barcodes.isEmpty) return;
                          final raw = capture.barcodes.first.rawValue;
                          if (raw == null) return;
                          perform(() async {
                            final parts = raw.split(':');
                            if (parts.length != 3 ||
                                parts[0] != 'vecindario-access' ||
                                parts[1] != user.communityId ||
                                !RegExp(
                                  r'^[a-zA-Z0-9-]{36}$',
                                ).hasMatch(parts[2])) {
                              throw StateError(
                                'QR de otro conjunto o formato inválido',
                              );
                            }
                            if (mounted) setState(() => scanning = false);
                            final info = await repository.inspect(
                              user.communityId!,
                              parts[2],
                            );
                            if (!context.mounted) return;
                            final status =
                                switch (info['administrationStatus']) {
                                  'current' => 'Al día',
                                  'overdue' => 'Vencida',
                                  _ => 'Sin información',
                                };
                            final accepted = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(info['name'] as String),
                                content: Text(
                                  '${info['unit']}\nAdministración: $status\nZona: ${zone.text}\nResidentes: $residents · Visitantes: $visitors\nEl estado de deuda no bloquea el ingreso.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Registrar ingreso'),
                                  ),
                                ],
                              ),
                            );
                            if (accepted != true) return;
                            await repository.admit(
                              user.communityId!,
                              parts[2],
                              user.id,
                              zone.text.trim(),
                              residents,
                              visitors,
                            );
                            if (mounted)
                              setState(
                                () => message =
                                    'Ingreso registrado correctamente',
                              );
                          });
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
