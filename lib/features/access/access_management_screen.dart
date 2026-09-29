import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/features/access/access_repository.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';

class AccessManagementScreen extends ConsumerWidget {
  const AccessManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null || !user.isCommunityAdmin || user.communityId == null) {
      return const Scaffold(body: Center(child: Text('Acceso restringido')));
    }
    final repo = AccessRepository(ref.watch(firestoreProvider));
    return Scaffold(
      appBar: AppBar(title: const Text('Operarios y control de acceso')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: repo.watchMembers(user.communityId!),
        builder: (context, membersSnapshot) =>
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: repo.watchStaff(user.communityId!),
              builder: (context, staffSnapshot) {
                if (!membersSnapshot.hasData || !staffSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final staff = {
                  for (final doc in staffSnapshot.data!.docs)
                    doc.id: doc.data()['active'] == true,
                };
                final members = membersSnapshot.data!.docs
                    .where((doc) => doc.id != user.id)
                    .toList();
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Solo activa como operarios a empleados autorizados. Un operario puede escanear QR y registrar ingresos, pero no modificar saldos.',
                    ),
                    const SizedBox(height: 12),
                    for (final member in members)
                      Card(
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: Text(
                                member.data()['displayName'] ?? 'Usuario',
                              ),
                              subtitle: Text(
                                '${member.data()['tower'] ?? ''} · ${member.data()['apartment'] ?? ''}\nPermiso para operar el lector QR',
                              ),
                              value: staff[member.id] == true,
                              onChanged: (value) async {
                                try {
                                  await repo.setStaff(
                                    user.communityId!,
                                    member.id,
                                    value,
                                  );
                                } catch (_) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No se pudo cambiar el permiso',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                            StreamBuilder<
                              DocumentSnapshot<Map<String, dynamic>>
                            >(
                              stream: repo.watchAdministrationStatus(
                                user.communityId!,
                                member.id,
                              ),
                              builder: (context, statusSnapshot) {
                                final status =
                                    statusSnapshot.data?.data()?['status'] ??
                                    'unknown';
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    12,
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: status,
                                    decoration: const InputDecoration(
                                      labelText: 'Estado de administración',
                                      isDense: true,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'unknown',
                                        child: Text('Sin información'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'current',
                                        child: Text('Al día'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'overdue',
                                        child: Text('Vencida'),
                                      ),
                                    ],
                                    onChanged: (value) async {
                                      if (value == null) return;
                                      await repo.setAdministrationStatus(
                                        user.communityId!,
                                        member.id,
                                        value,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
      ),
    );
  }
}
