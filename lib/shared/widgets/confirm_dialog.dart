import 'package:flutter/material.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirmar',
  String cancelText = 'Cancelar',
  bool isDestructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive
                ? AppColors.error
                : AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return result ?? false;
}
