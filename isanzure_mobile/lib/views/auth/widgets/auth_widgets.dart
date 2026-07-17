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

    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = Colors.white);
    canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)));

    final paints = [
      Paint()..color = const Color(0xFF4285F4),
      Paint()..color = const Color(0xFF34A853),
      Paint()..color = const Color(0xFFFBBC05),
      Paint()..color = const Color(0xFFEA4335),
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

    canvas.drawCircle(
        Offset(cx, cy), r * 0.58, Paint()..color = Colors.white);

    final barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - r * 0.18, r * 0.95, r * 0.36),
      barPaint,
    );

    canvas.drawCircle(
        Offset(cx, cy), r * 0.58, Paint()..color = Colors.white);

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

/// ── Shared live-validation visuals ─────────────────────────────────────
/// Both [AuthTextField] and [AuthPasswordField] share the same "touched"
/// state machine: a field stays neutral until the user has typed in it or
/// left it, then shows a green check / red error + inline message as they
/// keep typing — instead of waiting for form submission to reveal problems.
enum _FieldStatus { idle, valid, invalid }

InputBorder _borderFor(Color color, {double width = 1.2}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );

/// A text field with real-time validation feedback: neutral until
/// touched, then a green check or red error icon + message as the user
/// types, re-evaluated on every keystroke and on blur.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.externalTrigger,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;

  /// Optional Listenable (e.g. another field's controller) that should
  /// force this field to re-validate — useful for "confirm password"
  /// style fields whose validity depends on a sibling field.
  final Listenable? externalTrigger;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  final _focusNode = FocusNode();
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSignal);
    widget.externalTrigger?.addListener(_onSignal);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && widget.controller.text.isNotEmpty) {
        setState(() => _touched = true);
      }
    });
  }

  void _onSignal() {
    if (widget.controller.text.isNotEmpty) _touched = true;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSignal);
    widget.externalTrigger?.removeListener(_onSignal);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = _touched ? widget.validator(widget.controller.text) : null;
    final isValid =
        _touched && widget.controller.text.isNotEmpty && error == null;
    final status = !_touched
        ? _FieldStatus.idle
        : (error != null ? _FieldStatus.invalid : _FieldStatus.valid);

    final borderColor = switch (status) {
      _FieldStatus.valid => const Color(0xFF16A34A),
      _FieldStatus.invalid => Colors.redAccent,
      _FieldStatus.idle => const Color(0xFFE5E7F0),
    };

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      validator: widget.validator,
      onChanged: widget.onChanged,
      autovalidateMode: AutovalidateMode.disabled,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.bodyText),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle:
        GoogleFonts.inter(fontSize: 13, color: AppColors.bodyTextSecondary),
        prefixIcon: Icon(widget.icon, size: 18, color: Colors.black54),
        suffixIcon: status == _FieldStatus.idle
            ? null
            : AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: Icon(
            isValid ? Icons.check_circle_rounded : Icons.error_rounded,
            key: ValueKey(isValid),
            size: 20,
            color: isValid ? const Color(0xFF16A34A) : Colors.redAccent,
          ),
        ),
        errorText: error,
        filled: true,
        fillColor: AppColors.surface,
        errorStyle: GoogleFonts.inter(fontSize: 11.5, color: Colors.redAccent),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _borderFor(borderColor),
        enabledBorder: _borderFor(borderColor),
        focusedBorder: _borderFor(
            status == _FieldStatus.invalid ? Colors.redAccent : AppColors.primary,
            width: 1.5),
        errorBorder: _borderFor(Colors.redAccent),
        focusedErrorBorder: _borderFor(Colors.redAccent, width: 1.5),
      ),
    );
  }
}

/// Password field with the same live-validation treatment as
/// [AuthTextField], plus the visibility toggle.
class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.validator,
    this.hint = 'Enter your password',
    this.externalTrigger,
    this.onChanged,
  });
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final String hint;

  /// See [AuthTextField.externalTrigger].
  final Listenable? externalTrigger;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  final _focusNode = FocusNode();
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSignal);
    widget.externalTrigger?.addListener(_onSignal);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && widget.controller.text.isNotEmpty) {
        setState(() => _touched = true);
      }
    });
  }

  void _onSignal() {
    if (widget.controller.text.isNotEmpty) _touched = true;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSignal);
    widget.externalTrigger?.removeListener(_onSignal);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error =
    _touched && widget.validator != null ? widget.validator!(widget.controller.text) : null;
    final isValid =
        _touched && widget.controller.text.isNotEmpty && error == null;
    final status = !_touched
        ? _FieldStatus.idle
        : (error != null ? _FieldStatus.invalid : _FieldStatus.valid);

    final borderColor = switch (status) {
      _FieldStatus.valid => const Color(0xFF16A34A),
      _FieldStatus.invalid => Colors.redAccent,
      _FieldStatus.idle => const Color(0xFFE5E7F0),
    };

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.obscure,
      validator: widget.validator,
      onChanged: widget.onChanged,
      autovalidateMode: AutovalidateMode.disabled,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.bodyText),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle:
        GoogleFonts.inter(fontSize: 13, color: AppColors.bodyTextSecondary),
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            size: 18, color: Colors.black54),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status != _FieldStatus.idle)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  isValid ? Icons.check_circle_rounded : Icons.error_rounded,
                  size: 20,
                  color: isValid ? const Color(0xFF16A34A) : Colors.redAccent,
                ),
              ),
            GestureDetector(
              onTap: widget.onToggle,
              child: Icon(
                widget.obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: AppColors.bodyTextSecondary,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
        errorText: error,
        filled: true,
        fillColor: AppColors.surface,
        errorStyle: GoogleFonts.inter(fontSize: 11.5, color: Colors.redAccent),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _borderFor(borderColor),
        enabledBorder: _borderFor(borderColor),
        focusedBorder: _borderFor(
            status == _FieldStatus.invalid ? Colors.redAccent : AppColors.primary,
            width: 1.5),
        errorBorder: _borderFor(Colors.redAccent),
        focusedErrorBorder: _borderFor(Colors.redAccent, width: 1.5),
      ),
    );
  }
}