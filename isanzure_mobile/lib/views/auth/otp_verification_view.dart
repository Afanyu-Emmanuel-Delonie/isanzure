import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_theme.dart';
import 'reset_password_view.dart';
import 'widgets/auth_widgets.dart';

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({super.key, required this.email});
  final String email;

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  static const _length = 6;
  final _controllers = List.generate(_length, (_) => TextEditingController());
  final _focusNodes = List.generate(_length, (_) => FocusNode());

  bool _loading = false;
  int _resendSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendSeconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds == 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.length == 1 && index < _length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_otp.length == _length) _verify();
  }

  void _onKeyDown(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verify() async {
    if (_otp.length < _length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enter the 6-digit code',
              style: GoogleFonts.inter(fontSize: 13)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) => ResetPasswordView(email: widget.email)),
    );
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    if (name.length <= 2) return email;
    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final masked = _maskEmail(widget.email);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back button ──────────────────────────────────────────────
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7F0)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 40),

              // ── Icon + title ─────────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.verified_outlined,
                          size: 32, color: AppColors.primary),
                    ),
                    const SizedBox(height: 20),
                    Text('Verify your email',
                        style: GoogleFonts.sora(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                    const SizedBox(height: 8),
                    Text('We sent a 6-digit code to $masked',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.bodyTextSecondary,
                            height: 1.6)),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ── OTP boxes ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_length, (i) {
                  return _OtpBox(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    onChanged: (v) => _onChanged(i, v),
                    onKeyEvent: (e) => _onKeyDown(i, e),
                  );
                }),
              ),
              const SizedBox(height: 40),

              AuthPrimaryButton(
                label: 'Verify Code',
                loading: _loading,
                onPressed: _verify,
              ),
              const SizedBox(height: 32),

              // ── Resend ───────────────────────────────────────────────────
              Center(
                child: _resendSeconds > 0
                    ? RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.bodyTextSecondary),
                          children: [
                            const TextSpan(text: 'Resend code in '),
                            TextSpan(
                              text: '${_resendSeconds}s',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: _startTimer,
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.bodyTextSecondary),
                            children: [
                              const TextSpan(text: "Didn't receive it? "),
                              TextSpan(
                                text: 'Resend',
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<RawKeyEvent> onKeyEvent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 56,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: onKeyEvent,
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          onChanged: onChanged,
          style: GoogleFonts.sora(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.zero,
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
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
