import 'package:flutter/material.dart';

Widget buildTextFormField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  IconData? suffixIcon,
  VoidCallback? onSuffixIconPressed,
  bool obscureText = false,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
  void Function(String)? onChanged,
  bool enabled = true,
  bool readOnly = false, // Add readOnly parameter
  VoidCallback? onTap, // Add onTap parameter
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    validator: validator,
    onChanged: onChanged,
    enabled: enabled,
    readOnly: readOnly, // Use readOnly parameter
    onTap: onTap, // Use onTap parameter
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      suffixIcon: suffixIcon != null
          ? IconButton(
              onPressed: onSuffixIconPressed,
              icon: Icon(suffixIcon),
            )
          : null,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    ),
  );
}