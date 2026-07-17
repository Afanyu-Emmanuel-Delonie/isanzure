import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isanzure_mobile/views/auth/widgets/app_toast.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
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

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      AppToast.error(context, 'Please enter a valid email');
      return;
    }
    final vm = context.read<AuthViewModel>();
    final success = await vm.forgotPassword(_emailCtrl.text.trim());
    if (!mounted) return;
    if (success) {
      AppToast.success(context, 'Reset code sent to your email');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationView(
            email: _emailCtrl.text.trim(),
            mode: OtpMode.forgotPassword,
          ),
        ),
      );
    } else {
      AppToast.error(context, vm.errorMessage ?? 'Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Consumer<AuthViewModel>(
          builder: (context, vm, _) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel(label: 'Email address'),
                      const SizedBox(height: 8),
                      AuthTextField(
                        controller: _emailCtrl,
                        hint: 'you@example.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 32),
                      AuthPrimaryButton(
                        label: 'Send Reset Code',
                        loading: vm.isLoading,
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
      ),
    );
  }
}
