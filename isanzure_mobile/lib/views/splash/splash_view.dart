import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isanzure_mobile/core/constants/app_theme.dart';
import 'package:isanzure_mobile/viewmodels/auth_viewmodel.dart';
import 'package:isanzure_mobile/views/auth/login_view.dart';
import 'package:isanzure_mobile/views/main_shell.dart';
import 'package:provider/provider.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _taglineFade;
  late Animation<double> _poweredFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _taglineFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
    );

    _poweredFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;
      final vm = context.read<AuthViewModel>();
      await vm.checkAuthStatus();
      if (!mounted) return;
      final destination = vm.status == AuthStatus.authenticated
          ? const MainShell()
          : const LoginView();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => destination,
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SlideTransition(
                  position: _slideAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.directions_bus_rounded,
                            size: 52,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Isanzure',
                          style: GoogleFonts.sora(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeTransition(
                          opacity: _taglineFade,
                          child: Text(
                            'Your journey, simplified.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.white.withValues(alpha: 0.75),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: _poweredFade,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Text(
                  'Powered by BigOne',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.white.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
