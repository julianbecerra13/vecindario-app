import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/utils/image_utils.dart';

Future<File?> showImagePickerSheet(BuildContext context) async {
  return showModalBottomSheet<File?>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            const Text(
              'Seleccionar imagen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.md),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () async {
                final file = await ImageUtils.pickFromCamera();
                if (context.mounted) Navigator.of(context).pop(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de galería'),
              onTap: () async {
                final file = await ImageUtils.pickFromGallery();
                if (context.mounted) Navigator.of(context).pop(file);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
