import 'package:flutter/material.dart';
import 'package:petzy/features/core/colors.dart';

class CustomDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    VoidCallback? onConfirm,
    String? cancelText,
    VoidCallback? onCancel,
    bool isDestructive = false,
  }) {
    return showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              style: TextStyle(
                color: secondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              message,
              style: TextStyle(color: grey600, fontSize: 16),
            ),
            actions: [
              if (cancelText != null)
                TextButton(
                  onPressed: onCancel ?? () => Navigator.of(context).pop(),
                  child: Text(
                    cancelText,
                    style: TextStyle(
                      color: greyColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: onConfirm ?? () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDestructive ? redColor : primaryColor,
                  foregroundColor: whiteColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  confirmText,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );
  }
}
