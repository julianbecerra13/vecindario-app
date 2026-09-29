import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/features/appointments/providers/appointments_provider.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(myAppointmentsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Citas con administración')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/appointments/new'),
        icon: const Icon(Icons.add),
        label: const Text('Solicitar cita'),
      ),
      body: appointments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('No pudimos cargar tus citas.')),
        data: (items) => items.isEmpty
            ? const _EmptyAppointments()
            : ListView.builder(
                padding: const EdgeInsets.all(AppSizes.md),
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(
                          Icons.event_outlined,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      title: Text(
                        DateFormat(
                          'EEEE d MMM · h:mm a',
                          'es',
                        ).format(item.scheduledAt),
                      ),
                      subtitle: Text('${item.reason}\n${item.statusLabel}'),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyAppointments extends StatelessWidget {
  const _EmptyAppointments();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSizes.paddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_available_outlined,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'Todavía no tienes citas',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSizes.sm),
            const Text(
              'Elige una fecha y una hora para hablar con la administración.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
