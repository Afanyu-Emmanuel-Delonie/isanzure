import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_theme.dart';
import '../../views/main_shell.dart';
import '../bookings/widgets/booking_text_field.dart';
import 'widgets/auth_widgets.dart';
import 'signup_view.dart';
import 'forgot_password_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const MainShell(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
          child: Column(
            children: [
              // ── Logo + title ─────────────────────────────────────────────
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.directions_bus_rounded,
                    size: 30, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text('Welcome back',
                  style: GoogleFonts.sora(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary)),
              const SizedBox(height: 8),
              Text('Sign in to continue your journey',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.bodyTextSecondary,
                      height: 1.6)),
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
                    const SizedBox(height: 20),
                    const FieldLabel(label: 'Password'),
                    const SizedBox(height: 8),
                    AuthPasswordField(
                      controller: _passCtrl,
                      obscure: _obscure,
                      onToggle: () => setState(() => _obscure = !_obscure),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required';
                        if (v.length < 6) return 'At least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ForgotPasswordView())),
                        child: Text('Forgot password?',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    AuthPrimaryButton(
                      label: 'Sign In',
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 24),
                    const AuthDivider(label: 'or continue with'),
                    const SizedBox(height: 16),
                    AuthSocialButton(
                      brand: SocialBrand.google,
                      label: 'Continue with Google',
                      onPressed: () {},
                    ),
                    const SizedBox(height: 12),
                    AuthSocialButton(
                      brand: SocialBrand.apple,
                      label: 'Continue with Apple',
                      onPressed: () {},
                    ),
                    const SizedBox(height: 40),
                    AuthFooter(
                      question: "Don't have an account?",
                      action: 'Sign up',
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignupView())),
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
