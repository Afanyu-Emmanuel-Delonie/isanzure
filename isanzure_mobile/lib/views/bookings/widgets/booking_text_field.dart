import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_theme.dart';


class BookingTextField extends StatelessWidget {
  const BookingTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.maxLength,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.bodyText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
            fontSize: 13, color: AppColors.bodyTextSecondary),
        prefixIcon: Icon(icon, size: 18, color: Colors.black54),
        filled: true,
        fillColor: AppColors.surface,
        counterText: '',
        errorStyle: GoogleFonts.inter(fontSize: 11, color: Colors.redAccent),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: GoogleFonts.sora(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.black54
    ),
  );
}