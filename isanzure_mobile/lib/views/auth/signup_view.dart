import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../views/main_shell.dart';
import '../bookings/widgets/booking_text_field.dart';
import 'widgets/auth_widgets.dart';
import 'login_view.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreed = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please accept the terms to continue', style: GoogleFonts.inter(fontSize: 13)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.signup(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      role: 'passenger',
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Signup failed'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Consumer<AuthViewModel>(
          builder: (context, vm, _) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 120, 24, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Create Account',
                        style: GoogleFonts.sora(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                    const SizedBox(height: 10),
                    Text(
                      'Create a new account to continue',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.bodyTextSecondary,
                          height: 1.6),
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FieldLabel(label: 'Full name'),
                          const SizedBox(height: 8),
                          BookingTextField(
                            controller: _nameCtrl,
                            hint: 'Jean Pierre Habimana',
                            icon: Icons.person_outline_rounded,
                            textCapitalization: TextCapitalization.words,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Name is required';
                              if (v.trim().length < 3) return 'Enter your full name';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
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
                          const FieldLabel(label: 'Phone number'),
                          const SizedBox(height: 8),
                          BookingTextField(
                            controller: _phoneCtrl,
                            hint: '+250 7XX XXX XXX',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Phone is required';
                              if (v.trim().length < 9) return 'Enter a valid phone number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          const FieldLabel(label: 'Password'),
                          const SizedBox(height: 8),
                          AuthPasswordField(
                            controller: _passCtrl,
                            obscure: _obscurePass,
                            onToggle: () =>
                                setState(() => _obscurePass = !_obscurePass),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password is required';
                              if (v.length < 6) return 'At least 6 characters';
                              return null;
                            },
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
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Please confirm your password';
                              if (v != _passCtrl.text) return 'Passwords do not match';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _TermsRow(
                            agreed: _agreed,
                            onChanged: (v) => setState(() => _agreed = v ?? false),
                          ),
                          const SizedBox(height: 32),
                          AuthPrimaryButton(
                            label: 'Create Account',
                            loading: vm.isLoading,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: 32),
                          const AuthDivider(label: 'or sign up with'),
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
                            question: 'Already have an account?',
                            action: 'Sign in',
                            onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginView())),
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

class _TermsRow extends StatelessWidget {
  const _TermsRow({required this.agreed, required this.onChanged});
  final bool agreed;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: agreed,
            onChanged: onChanged,
            activeColor: AppColors.secondary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.bodyTextSecondary),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
