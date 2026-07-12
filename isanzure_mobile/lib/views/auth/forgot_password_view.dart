import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_theme.dart';
import '../bookings/widgets/booking_text_field.dart';
import 'otp_verification_view.dart';
import 'widgets/auth_widgets.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationView(email: _emailCtrl.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      child: const Icon(Icons.lock_reset_rounded,
                          size: 32, color: AppColors.primary),
                    ),
                    const SizedBox(height: 20),
                    Text('Reset password',
                        style: GoogleFonts.sora(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                    const SizedBox(height: 8),
                    Text("Enter your email and we'll send a reset code",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.bodyTextSecondary,
                            height: 1.6)),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ── Form ─────────────────────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel(label: 'Email address'),
                    const SizedBox(height: 8),
                    BookingTextField(
                      controller: _emailCtrl,
                      hint: 'you@example.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    AuthPrimaryButton(
                      label: 'Send Reset Code',
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 40),
                    AuthFooter(
                      question: 'Remember your password?',
                      action: 'Sign in',
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
