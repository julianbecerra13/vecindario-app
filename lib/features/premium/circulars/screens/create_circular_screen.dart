import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/core/config/backend_features.dart';
import 'package:vecindario_app/features/premium/models/circular_model.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

class CreateCircularScreen extends ConsumerStatefulWidget {
  const CreateCircularScreen({super.key});

  @override
  ConsumerState<CreateCircularScreen> createState() =>
      _CreateCircularScreenState();
}

class _CreateCircularScreenState extends ConsumerState<CreateCircularScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  CircularPriority _priority = CircularPriority.general;
  bool _requiresSignature = false;
  bool _isLoading = false;
  final List<String> _attachmentUrls = [];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_titleController.text.trim().isEmpty) {
      context.showErrorSnackBar(context.l10n.circularTitleRequired);
      return;
    }
    if (_bodyController.text.trim().isEmpty && _attachmentUrls.isEmpty) {
      context.showErrorSnackBar(context.l10n.circularBodyRequired);
      return;
    }

    setState(() => _isLoading = true);
    final user = ref.read(currentUserProvider).value;
    final communityId = ref.read(currentCommunityIdProvider);
    if (user == null || communityId == null) return;

    final circular = CircularModel(
      id: '',
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      attachmentURLs: List.unmodifiable(_attachmentUrls),
      authorUid: user.id,
      authorName: user.displayName,
      priority: _priority,
      requiresAck: _requiresSignature,
      createdAt: DateTime.now(),
    );

    try {
      await ref
          .read(premiumRepositoryProvider)
          .createCircular(communityId, circular);
      if (mounted) {
        context.showSuccessSnackBar(context.l10n.circularPublished);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(context.l10n.errorGeneric(e));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addAttachmentLink() async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjuntar documento o archivo'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Enlace público',
            hintText: 'https://drive.google.com/...',
            helperText: 'PDF, imagen, audio, video o documento',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Adjuntar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.isEmpty || !mounted) return;
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.hasScheme ||
        !{'http', 'https'}.contains(uri.scheme)) {
      context.showErrorSnackBar('Ingresa un enlace HTTP o HTTPS válido.');
      return;
    }
    setState(() => _attachmentUrls.add(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.circularCreateTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.sm),
            child: FilledButton(
              onPressed: _isLoading ? null : _publish,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(context.l10n.publish),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSizes.paddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prioridad
            Text(context.l10n.circularPriority, style: AppTextStyles.heading3),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: 8,
              children: CircularPriority.values.map((p) {
                final selected = _priority == p;
                return ChoiceChip(
                  avatar: Icon(
                    p.icon,
                    size: 14,
                    color: selected ? Colors.white : p.color,
                  ),
                  label: Text(p.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _priority = p),
                  selectedColor: p.color,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : context.colors.textPrimary,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.lg),

            // Título
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: context.l10n.circularTitleLabel,
                hintText: context.l10n.circularTitleHint,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSizes.md),

            // Cuerpo
            TextField(
              controller: _bodyController,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: context.l10n.circularContentLabel,
                hintText: context.l10n.circularContentHint,
                alignLabelWithHint: true,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSizes.md),

            const Text('Documentos y archivos', style: AppTextStyles.heading3),
            const SizedBox(height: AppSizes.sm),
            if (_attachmentUrls.isNotEmpty)
              ..._attachmentUrls.indexed.map(
                (entry) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.attach_file_rounded),
                    title: Text(
                      Uri.parse(entry.$2).pathSegments.isEmpty
                          ? 'Archivo adjunto'
                          : Uri.parse(entry.$2).pathSegments.last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      entry.$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      tooltip: 'Quitar archivo',
                      onPressed: () =>
                          setState(() => _attachmentUrls.removeAt(entry.$1)),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ),
              ),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _addAttachmentLink,
                  icon: const Icon(Icons.link_rounded),
                  label: const Text('Adjuntar enlace'),
                ),
                OutlinedButton.icon(
                  onPressed: kMediaUploadsEnabled
                      ? () => context.showSnackBar(
                          'Selecciona el archivo desde tu dispositivo.',
                        )
                      : () => context.showSnackBar(
                          kMediaUploadsUnavailableMessage,
                        ),
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Subir archivo'),
                ),
              ],
            ),
            if (!kMediaUploadsEnabled)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Mientras Firebase Storage no esté habilitado, puedes adjuntar enlaces públicos de Drive, PDF, imágenes, audio o video.',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ),
            const SizedBox(height: AppSizes.md),

            // Opciones
            SwitchListTile(
              title: Text(
                context.l10n.circularRequiresAck,
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                context.l10n.circularRequiresAckHelper,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.textSecondary,
                ),
              ),
              value: _requiresSignature,
              onChanged: (v) => setState(() => _requiresSignature = v),
              activeThumbColor: const Color(0xFF8B5CF6),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
