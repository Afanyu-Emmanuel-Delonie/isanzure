import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isanzure_mobile/views/auth/widgets/app_toast.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../bookings/widgets/booking_text_field.dart';
import 'login_view.dart';
import 'widgets/auth_widgets.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key, required this.email, this.resetToken});
  final String email;
  final String? resetToken;

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _done = false;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  int get _strength {
    final p = _passCtrl.text;
    if (p.isEmpty) return 0;
    int score = 0;
    if (p.length >= 8) score++;
    if (p.contains(RegExp(r'[A-Z]'))) score++;
    if (p.contains(RegExp(r'[0-9]'))) score++;
    if (p.contains(RegExp(r'[!@#\$%^&*]'))) score++;
    return score;
  }

  String? _passValidator(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'At least 8 characters';
    return null;
  }

  String? _confirmValidator(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != _passCtrl.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      AppToast.error(context, 'Please fix the highlighted fields');
      return;
    }
    final vm = context.read<AuthViewModel>();
    final token = widget.resetToken ?? '';
    final success = await vm.resetPassword(token, _passCtrl.text.trim());
    if (!mounted) return;
    if (success) {
      setState(() => _done = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, __, ___) => const LoginView(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
          (route) => false,
        );
      });
    } else {
      AppToast.error(context, vm.errorMessage ?? 'Could not reset password');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 24),
                Text(
                  'Password updated!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  'You can now sign in with your new password',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.bodyTextSecondary,
                      height: 1.6),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Consumer<AuthViewModel>(
          builder: (context, vm, _) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back button ──────────────────────────────────────────
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
                      child: const Icon(
                        Icons.lock_open_rounded,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'New password',
                      style: GoogleFonts.sora(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a strong password for your account',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.bodyTextSecondary,
                          height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ── Form ──────────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel(label: 'New password'),
                    const SizedBox(height: 8),
                    AuthPasswordField(
                      controller: _passCtrl,
                      obscure: _obscurePass,
                      hint: 'Min. 8 characters',
                      onToggle: () =>
                          setState(() => _obscurePass = !_obscurePass),
                      validator: _passValidator,
                      externalTrigger: _confirmCtrl,
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder(
                      valueListenable: _passCtrl,
                      builder: (_, __, ___) =>
                          _StrengthBar(strength: _strength),
                    ),
                    const SizedBox(height: 20),
                    const FieldLabel(label: 'Confirm password'),
                    const SizedBox(height: 8),
                    AuthPasswordField(
                      controller: _confirmCtrl,
                      obscure: _obscureConfirm,
                      hint: 'Re-enter your password',
                      onToggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: _confirmValidator,
                      externalTrigger: _passCtrl,
                    ),
                    const SizedBox(height: 32),
                    AuthPrimaryButton(
                      label: 'Update Password',
                      loading: vm.isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}



class _StrengthBar extends StatelessWidget {
  const _StrengthBar({required this.strength});
  final int strength;

  static const _labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
  static const _colors = [
    Color(0xFFE5E7F0),
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
    Color(0xFF3B82F6),
    Color(0xFF16A34A),
  ];

  @override
  Widget build(BuildContext context) {
    if (strength == 0) return const SizedBox.shrink();
    final color = _colors[strength];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: i < strength ? color : const Color(0xFFE5E7F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(_labels[strength],
            style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}