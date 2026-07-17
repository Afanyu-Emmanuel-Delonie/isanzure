import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isanzure_mobile/views/auth/widgets/app_toast.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'login_view.dart';
import 'reset_password_view.dart';
import 'widgets/auth_widgets.dart';

enum OtpMode { signup, forgotPassword }

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({
    super.key,
    required this.email,
    this.mode = OtpMode.signup,
    // Required for signup mode
    this.name,
    this.phone,
    this.password,
    this.role,
  });

  final String email;
  final OtpMode mode;
  final String? name;
  final String? phone;
  final String? password;
  final String? role;

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  static const _length = 6;
  final _controllers = List.generate(_length, (_) => TextEditingController());
  final _focusNodes = List.generate(_length, (_) => FocusNode());

  bool _invalid = false;
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
    if (_invalid) setState(() => _invalid = false);

    // Handle pasting a full code
    if (value.length > 1) {
      final chars = value.split('');
      int i = 0;
      for (; i < chars.length && i < _length; i++) {
        _controllers[i].text = chars[i];
      }
      
      final nextIndex = i < _length ? i : _length - 1;
      _focusNodes[nextIndex].requestFocus();
      
      if (_otp.length == _length) _verify();
      return;
    }

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
      AppToast.error(context, 'Enter the 6-digit code');
      return;
    }

    if (widget.mode == OtpMode.forgotPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => ResetPasswordView(email: widget.email, resetToken: _otp)),
      );
      return;
    }

    // Signup mode — call backend
    final vm = context.read<AuthViewModel>();
    final success = await vm.verifyOtp(
      email: widget.email,
      otp: _otp,
      name: widget.name!,
      phone: widget.phone!,
      password: widget.password!,
      role: widget.role!,
    );

    if (!mounted) return;

    if (success) {
      AppToast.success(context, 'Account created! Please sign in.');
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const LoginView(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
        (route) => false,
      );
    } else {
      setState(() {
        _invalid = true;
        for (final c in _controllers) {
          c.clear();
        }
      });
      if (_focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
      AppToast.error(context, vm.errorMessage ?? 'Invalid code');
    }
  }

  Future<void> _resend() async {
    if (widget.mode == OtpMode.signup) {
      final vm = context.read<AuthViewModel>();
      await vm.initiateSignup(
        name: widget.name!,
        email: widget.email,
        phone: widget.phone!,
        password: widget.password!,
        role: widget.role!,
      );
    }
    if (!mounted) return;
    _startTimer();
    AppToast.success(context, 'A new code was sent');
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_length, (i) {
                    return _OtpBox(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      invalid: _invalid,
                      onChanged: (v) => _onChanged(i, v),
                      onKeyEvent: (e) => _onKeyDown(i, e),
                    );
                  }),
                ),
                const SizedBox(height: 40),
                AuthPrimaryButton(
                  label: 'Verify Code',
                  loading: vm.isLoading,
                  onPressed: _verify,
                ),
                const SizedBox(height: 32),
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
                                    color: AppColors.primary
                                ),
                              ),
                            ],
                          ),
                        )
                      : GestureDetector(
                          onTap: _resend,
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
    this.invalid = false,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<RawKeyEvent> onKeyEvent;
  final bool invalid;

  @override
  Widget build(BuildContext context) {
    final borderColor = invalid ? Colors.redAccent : const Color(0xFF5E5F61);
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
            LengthLimitingTextInputFormatter(6),
          ],
          onChanged: onChanged,
          style: GoogleFonts.sora(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: invalid ? Colors.redAccent : AppColors.primary),
          decoration: InputDecoration(
            filled: false,
            hintText: '0',
            hintStyle: GoogleFonts.sora(
              color: AppColors.bodyTextSecondary,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: invalid ? Colors.redAccent : AppColors.primary,
                  width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
