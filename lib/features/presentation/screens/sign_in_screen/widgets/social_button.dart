import 'package:flutter/material.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/core/constants.dart';

// ignore: unused_element
Widget _socialButton(String label, IconData icon) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: whiteColor,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: grey600),
          sizedBoxW10,
          Text(label, style: TextStyle(color: grey600)),
        ],
      ),
    ),
  );
}
