import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';
import 'package:vecindario_app/features/premium/models/finance_model.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

class CreateFinanceEntryScreen extends ConsumerStatefulWidget {
  const CreateFinanceEntryScreen({super.key});

  @override
  ConsumerState<CreateFinanceEntryScreen> createState() =>
      _CreateFinanceEntryScreenState();
}

class _CreateFinanceEntryScreenState
    extends ConsumerState<CreateFinanceEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  FinanceType _type = FinanceType.income;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _categoryController.dispose();
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final communityId = ref.read(currentCommunityIdProvider);
    final user = ref.read(currentUserProvider).value;
    if (communityId == null || user == null) {
      context.showErrorSnackBar(context.l10n.errorUserOrCommunityUnavailable);
      return;
    }

    setState(() => _saving = true);
    try {
      final entry = FinanceEntryModel(
        id: '',
        type: _type,
        category: _categoryController.text.trim(),
        description: _descController.text.trim(),
        amount: int.parse(_amountController.text.trim()),
        date: _date,
        approvedByUid: user.id,
        createdAt: DateTime.now(),
      );
      await ref
          .read(premiumRepositoryProvider)
          .createFinanceEntry(communityId, entry);
      if (!mounted) return;
      context.showSuccessSnackBar(context.l10n.financeEntryRegistered);
      context.pop();
    } catch (e) {
      if (mounted) context.showErrorSnackBar(context.l10n.errorGeneric(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.financeNewEntryTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSizes.paddingAll,
          children: [
            SegmentedButton<FinanceType>(
              segments: [
                ButtonSegment(
                  value: FinanceType.income,
                  label: Text(context.l10n.financeIncome),
                  icon: const Icon(
                    Icons.arrow_downward,
                    color: AppColors.success,
                  ),
                ),
                ButtonSegment(
                  value: FinanceType.expense,
                  label: Text(context.l10n.financeExpense),
                  icon: const Icon(Icons.arrow_upward, color: AppColors.error),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _categoryController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: context.l10n.financeCategoryLabel,
                hintText: context.l10n.financeCategoryHint,
                prefixIcon: const Icon(Icons.category_outlined),
                border: const OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'La categoría es obligatoria'
                  : null,
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _descController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: context.l10n.formDescriptionLabel,
                prefixIcon: const Icon(Icons.description_outlined),
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'La descripción es obligatoria'
                  : null,
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.l10n.financeAmountLabel,
                prefixText: '\$ ',
                prefixIcon: const Icon(Icons.attach_money),
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Monto requerido';
                final n = int.tryParse(v.trim());
                if (n == null || n <= 0) return 'Ingresa un número válido';
                return null;
              },
            ),
            const SizedBox(height: AppSizes.md),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(context.l10n.financeDateLabel),
              subtitle: Text(
                '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                side: BorderSide(color: context.colors.border),
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  _saving
                      ? context.l10n.savingEllipsis
                      : context.l10n.financeRegister,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
