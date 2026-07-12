import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_theme.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
  });
  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : Text(label,
                style: GoogleFonts.sora(
                    fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE5E7F0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.bodyTextSecondary)),
        ),
        const Expanded(child: Divider(color: Color(0xFFE5E7F0))),
      ],
    );
  }
}

class AuthSocialButton extends StatelessWidget {
  const AuthSocialButton({
    super.key,
    required this.brand,
    required this.label,
    required this.onPressed,
  });
  final SocialBrand brand;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.bodyText,
          side: const BorderSide(color: Color(0xFFE5E7F0), width: 1.2),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _BrandIcon(brand: brand),
            const SizedBox(width: 10),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bodyText)),
          ],
        ),
      ),
    );
  }
}

enum SocialBrand { google, apple }

class _BrandIcon extends StatelessWidget {
  const _BrandIcon({required this.brand});
  final SocialBrand brand;

  @override
  Widget build(BuildContext context) {
    if (brand == SocialBrand.apple) {
      return const Icon(Icons.apple, size: 22, color: Colors.black);
    }
    // Google — four-colour G painted manually
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Draw full circle background (white)
    canvas.drawCircle(
        Offset(cx, cy), r, Paint()..color = Colors.white);

    // Clip to circle
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)));

    // Quadrant colours
    final paints = [
      Paint()..color = const Color(0xFF4285F4), // blue  — top-right
      Paint()..color = const Color(0xFF34A853), // green — bottom-right
      Paint()..color = const Color(0xFFFBBC05), // yellow — bottom-left
      Paint()..color = const Color(0xFFEA4335), // red   — top-left
    ];
    final angles = [0.0, 90.0, 180.0, 270.0];
    for (int i = 0; i < 4; i++) {
      final sweep = 90.0 * (3.14159265 / 180);
      final start = angles[i] * (3.14159265 / 180) - (3.14159265 / 2);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        start,
        sweep,
        true,
        paints[i],
      );
    }

    // White inner circle (donut)
    canvas.drawCircle(
        Offset(cx, cy), r * 0.58, Paint()..color = Colors.white);

    // Blue right bar (the horizontal bar of the G)
    final barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - r * 0.18, r * 0.95, r * 0.36),
      barPaint,
    );

    // Re-clip inner white ring gap
    canvas.drawCircle(
        Offset(cx, cy), r * 0.58, Paint()..color = Colors.white);

    // Blue arc fill for right side of G
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.58),
      -0.52,
      1.04,
      true,
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AuthFooter extends StatelessWidget {
  const AuthFooter({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });
  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(question,
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.bodyTextSecondary)),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onTap,
          child: Text(action,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
        ),
      ],
    );
  }
}

class AuthPasswordField extends StatelessWidget {
  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.validator,
    this.hint = 'Enter your password',
  });
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.bodyText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
            fontSize: 13, color: AppColors.bodyTextSecondary),
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            size: 18, color: Colors.black54),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 18,
            color: AppColors.bodyTextSecondary,
          ),
        ),
        filled: true,
        fillColor: AppColors.surface,
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
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}
