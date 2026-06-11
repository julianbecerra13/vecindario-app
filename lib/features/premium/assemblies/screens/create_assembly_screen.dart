import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/premium/models/finance_model.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

class CreateAssemblyScreen extends ConsumerStatefulWidget {
  const CreateAssemblyScreen({super.key});

  @override
  ConsumerState<CreateAssemblyScreen> createState() =>
      _CreateAssemblyScreenState();
}

class _CreateAssemblyScreenState extends ConsumerState<CreateAssemblyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController(text: 'Salón Social');
  final _virtualLinkController = TextEditingController();
  final _agendaItemControllers = <TextEditingController>[
    TextEditingController(text: 'Verificación de quórum'),
    TextEditingController(text: 'Lectura del orden del día'),
  ];
  DateTime _date = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _time = const TimeOfDay(hour: 19, minute: 0);
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _virtualLinkController.dispose();
    for (final c in _agendaItemControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _addAgendaItem() {
    setState(() => _agendaItemControllers.add(TextEditingController()));
  }

  void _removeAgendaItem(int index) {
    setState(() {
      _agendaItemControllers[index].dispose();
      _agendaItemControllers.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final agenda = _agendaItemControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (agenda.isEmpty) {
      context.showErrorSnackBar('Agrega al menos un punto al orden del día');
      return;
    }

    final communityId = ref.read(currentCommunityIdProvider);
    if (communityId == null) {
      context.showErrorSnackBar('Comunidad no disponible');
      return;
    }

    setState(() => _saving = true);
    try {
      final dateTime = DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      );
      final assembly = AssemblyModel(
        id: '',
        title: _titleController.text.trim(),
        agenda: agenda,
        date: dateTime,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        virtualLink: _virtualLinkController.text.trim().isEmpty
            ? null
            : _virtualLinkController.text.trim(),
      );
      await ref
          .read(premiumRepositoryProvider)
          .createAssembly(communityId, assembly);
      if (!mounted) return;
      context.showSuccessSnackBar('Asamblea convocada');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEE d MMM y', 'es').format(_date);
    final timeLabel = _time.format(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Convocar asamblea')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.md),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ej: Asamblea ordinaria 2026',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(dateLabel),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(timeLabel),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Lugar (opcional)',
                hintText: 'Ej: Salón Social',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _virtualLinkController,
              decoration: const InputDecoration(
                labelText: 'Link virtual (opcional)',
                hintText: 'Ej: https://meet.google.com/...',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: AppSizes.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Orden del día',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addAgendaItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            ..._agendaItemControllers.asMap().entries.map((entry) {
              final idx = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        '${idx + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'Punto del orden del día',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.error),
                      onPressed: _agendaItemControllers.length > 1
                          ? () => _removeAgendaItem(idx)
                          : null,
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppSizes.xl),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Convocar asamblea'),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Al convocar, los residentes serán notificados y podrán confirmar asistencia. Las votaciones se pueden iniciar el día de la asamblea.',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
