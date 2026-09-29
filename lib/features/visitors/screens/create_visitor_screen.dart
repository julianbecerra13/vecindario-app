import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/features/visitors/providers/visitors_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

class CreateVisitorScreen extends ConsumerStatefulWidget {
  const CreateVisitorScreen({super.key});
  @override
  ConsumerState<CreateVisitorScreen> createState() =>
      _CreateVisitorScreenState();
}

class _CreateVisitorScreenState extends ConsumerState<CreateVisitorScreen> {
  final _nameController = TextEditingController();
  DateTime? _validFrom;
  DateTime? _expiresAt;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      initialDate: initial,
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null || user.communityId == null) return;
    if (_nameController.text.trim().length < 3 ||
        _validFrom == null ||
        _expiresAt == null ||
        !_expiresAt!.isAfter(_validFrom!)) {
      context.showErrorSnackBar('Completa el nombre y una vigencia válida.');
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(visitorsRepositoryProvider)
          .create(
            communityId: user.communityId!,
            residentUid: user.id,
            residentName: user.displayName,
            unit: user.unitInfo,
            visitorName: _nameController.text.trim(),
            validFrom: _validFrom!,
            expiresAt: _expiresAt!,
          );
      if (mounted) {
        context.showSuccessSnackBar('Visita autorizada.');
        context.pop();
      }
    } catch (_) {
      if (mounted) context.showErrorSnackBar('No pudimos autorizar la visita.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Autorizar visita')),
      body: ListView(
        padding: AppSizes.paddingAll,
        children: [
          Text(
            'Crea una autorización individual.',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'Este QR es diferente de tu identificación personal y solo funciona durante la vigencia indicada.',
          ),
          const SizedBox(height: AppSizes.xl),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nombre completo del visitante',
            ),
          ),
          const SizedBox(height: AppSizes.md),
          OutlinedButton.icon(
            onPressed: () async {
              final value = await _pick(
                DateTime.now().add(const Duration(hours: 1)),
              );
              if (value != null) setState(() => _validFrom = value);
            },
            icon: const Icon(Icons.login),
            label: Text(
              _validFrom == null
                  ? 'Inicio de vigencia'
                  : DateFormat('d MMM · h:mm a', 'es').format(_validFrom!),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          OutlinedButton.icon(
            onPressed: () async {
              final value = await _pick(
                (_validFrom ?? DateTime.now()).add(const Duration(hours: 4)),
              );
              if (value != null) setState(() => _expiresAt = value);
            },
            icon: const Icon(Icons.logout),
            label: Text(
              _expiresAt == null
                  ? 'Fin de vigencia'
                  : DateFormat('d MMM · h:mm a', 'es').format(_expiresAt!),
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
                : const Text('Crear autorización'),
          ),
        ],
      ),
    );
  }
}
