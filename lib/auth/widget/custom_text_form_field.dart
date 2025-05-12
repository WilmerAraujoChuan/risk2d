import 'package:flutter/material.dart';
import 'package:risk2d/common/colors.dart'; // Asegúrate de tener definido AppColors.error

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final IconData? icon;
  final Color? iconColor;
  final bool filled;
  final Color? fillColor;
  final Widget? suffixIcon; // ✅ NUEVO parámetro

  const CustomTextFormField({
    super.key,
    this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.icon,
    this.iconColor,
    this.filled = false,
    this.fillColor,
    this.suffixIcon, // ✅ Añadir al constructor
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.grey[800]),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon:
            icon != null
                ? Icon(icon, color: iconColor ?? Colors.grey[600])
                : null,
        suffixIcon: suffixIcon, // ✅ Agregado aquí
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorStyle: TextStyle(
          color: AppColors.error,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        filled: filled,
        fillColor: fillColor ?? Colors.white,
      ),
      validator: validator,
    );
  }
}
