import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/features/appointments/providers/appointments_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

class CreateAppointmentScreen extends ConsumerStatefulWidget {
  const CreateAppointmentScreen({super.key});

  @override
  ConsumerState<CreateAppointmentScreen> createState() =>
      _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState
    extends ConsumerState<CreateAppointmentScreen> {
  final _reasonController = TextEditingController();
  DateTime? _scheduledAt;
  bool _saving = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickSchedule() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day + 1),
      lastDate: now.add(const Duration(days: 90)),
      initialDate: now.add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return;
    setState(
      () => _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null || user.communityId == null) return;
    if (_scheduledAt == null || _reasonController.text.trim().length < 10) {
      context.showErrorSnackBar(
        'Elige fecha y hora y explica brevemente el motivo.',
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(appointmentsRepositoryProvider)
          .create(
            communityId: user.communityId!,
            residentUid: user.id,
            residentName: user.displayName,
            scheduledAt: _scheduledAt!,
            reason: _reasonController.text.trim(),
          );
      if (mounted) {
        context.showSuccessSnackBar('Tu cita quedó solicitada.');
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        context.showErrorSnackBar(
          'No pudimos solicitar la cita. Intenta de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cita con administración')),
      body: ListView(
        padding: AppSizes.paddingAll,
        children: [
          Text(
            'Reserva una hora, no envíes una queja.',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'La administración confirmará la disponibilidad o propondrá una nueva hora.',
          ),
          const SizedBox(height: AppSizes.xl),
          OutlinedButton.icon(
            onPressed: _pickSchedule,
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(
              _scheduledAt == null
                  ? 'Elegir fecha y hora'
                  : DateFormat(
                      'EEEE d MMMM · h:mm a',
                      'es',
                    ).format(_scheduledAt!),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          TextField(
            controller: _reasonController,
            minLines: 4,
            maxLines: 6,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Motivo de la cita',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          ElevatedButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Solicitar cita'),
          ),
        ],
      ),
    );
  }
}
