import 'package:flutter/material.dart';

/// Reusable confirmation and informational dialog
class AppDialog {
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) {
    return showDialog<bool>(
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
            style: confirmColor != null
                ? ElevatedButton.styleFrom(
                    backgroundColor: confirmColor,
                    foregroundColor: Colors.white,
                  )
                : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? confirmText,
    String? cancelLabel,
    String? cancelText,
    Color? confirmColor,
    VoidCallback? onConfirm,
  }) async {
    final result = await showConfirmationDialog(
      context: context,
      title: title,
      message: message,
      confirmText: confirmLabel ?? confirmText ?? 'Confirm',
      cancelText: cancelLabel ?? cancelText ?? 'Cancel',
      confirmColor: confirmColor,
    );
    if (result == true && onConfirm != null) {
      onConfirm();
    }
    return result;
  }
}
