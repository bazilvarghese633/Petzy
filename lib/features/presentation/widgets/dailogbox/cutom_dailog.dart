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

class CustomPrivacyPolicyDialog {
  static Future<void> show({required BuildContext context}) {
    return showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Privacy Policy",
              style: TextStyle(
                color: secondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: SizedBox(
              height: 350, // fixed height for scroll
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: const Text(
                  '''
At Petzy, we value your privacy and are committed to protecting your personal information. 

1. Information We Collect
   - Personal details you provide (name, email, etc.)
   - Data related to app usage and device information

2. How We Use Your Information
   - To provide and improve our services
   - To personalize your experience
   - To communicate important updates

3. Data Security
   - We use advanced security measures to protect your data
   - Your personal information will never be shared without your consent

4. Third-Party Services
   - Some features may use trusted third-party services
   - These services are bound by their own privacy policies

5. Your Rights
   - You may request deletion of your data at any time
   - You have control over what information you share

For any privacy-related concerns, please contact us at: support@petzy.com
              ''',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );
  }
}
