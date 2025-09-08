// image_preview.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ImagePreview extends StatelessWidget {
  final File? imageFile;
  final VoidCallback? onTap;

  const ImagePreview({
    super.key,
    this.imageFile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        ),
        child: imageFile != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium - 2),
          child: Image.file(
            imageFile!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Tap to select an image',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
