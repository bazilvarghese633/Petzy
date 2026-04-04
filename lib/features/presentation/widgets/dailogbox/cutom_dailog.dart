import 'package:flutter/material.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/presentation/screens/cart_screen/cart_screen.dart'
    as petzy_cart;

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
            title:
                isDestructive
                    ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Transform.rotate(
                                angle: (1.0 - value) * -0.3, // Wobble effect
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: redColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: redColor,
                                    size: 48,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: secondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    )
                    : Text(
                      title,
                      style: const TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            content: Text(
              message,
              style: TextStyle(color: grey600, fontSize: 16),
              textAlign: isDestructive ? TextAlign.center : TextAlign.start,
            ),
            actionsAlignment: isDestructive ? MainAxisAlignment.center : null,
            actions:
                isDestructive && cancelText != null
                    ? [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  onCancel ?? () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: greyColor,
                                side: const BorderSide(
                                  color: greyColor,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              child: Text(
                                cancelText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  onConfirm ??
                                  () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: redColor,
                                foregroundColor: whiteColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              child: Text(
                                confirmText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]
                    : [
                      if (cancelText != null)
                        TextButton(
                          onPressed:
                              onCancel ?? () => Navigator.of(context).pop(),
                          child: Text(
                            cancelText,
                            style: const TextStyle(
                              color: greyColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ElevatedButton(
                        onPressed:
                            onConfirm ?? () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
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

class CustomCartOutcomeDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required IconData iconData,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Large Animated Icon
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Transform.rotate(
                      angle: (1.0 - value) * -0.5,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          iconData,
                          color: primaryColor,
                          size: 64, // Much larger and prominent
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // 🔸 Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
              const SizedBox(height: 12),
              // 🔸 Message
              Text(
                message,
                style: TextStyle(fontSize: 15, color: grey600, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: const BorderSide(color: primaryColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // close dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const petzy_cart.CartScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: whiteColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.shopping_cart, size: 16),
                    label: const Text(
                      'Go to Cart',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
