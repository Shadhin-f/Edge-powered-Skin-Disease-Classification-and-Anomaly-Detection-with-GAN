// custom_button.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget child = isLoading
        ? SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          type == ButtonType.primary
              ? Colors.white
              : AppConstants.primaryColor,
        ),
      ),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: type == ButtonType.primary
                ? Colors.white
                : AppConstants.primaryColor,
          ),
          const SizedBox(width: 8.0),
        ],
        Text(
          text,
          style: TextStyle(
            color: type == ButtonType.primary
                ? Colors.white
                : AppConstants.primaryColor,
          ),
        ),
      ],
    );

    switch (type) {
      case ButtonType.primary:
        return FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 24,
            ),
            backgroundColor: AppConstants.primaryColor,
          ),
          child: child,
        );
      case ButtonType.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 24,
            ),
            side: BorderSide(color: AppConstants.primaryColor),
          ),
          child: child,
        );
      case ButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
    }
  }
}

enum ButtonType { primary, secondary, text }
