import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_theme.dart';
import '../bookings/widgets/booking_text_field.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'Jean Pierre Habimana');
  final _emailCtrl = TextEditingController(text: 'user@email.com');
  final _phoneCtrl = TextEditingController(text: '+250 7XX XXX XXX');
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required';
    if (v.trim().length < 3) return 'Enter your full name';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w.]+@[\w]+\.[a-z]{2,}$').hasMatch(v.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'Phone is required';
    if (digits.length < 9 || digits.length > 12) return 'Enter a valid phone number';
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile updated', style: GoogleFonts.inter(fontSize: 13)),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Container(
            color: AppColors.primary,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.08,
                    child: Image.asset(
                      'assets/img/map-bg.png',
                      fit: BoxFit.cover,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, top + 16, 20, 24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Edit Profile',
                              style: GoogleFonts.sora(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          Text('Update your personal details',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Form ─────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 88, height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondary,
                              border: Border.all(
                                  color: AppColors.primary.withOpacity(0.15),
                                  width: 3),
                            ),
                            child: const Icon(Icons.person_rounded,
                                size: 48, color: Colors.white),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_outlined,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    const FieldLabel(label: 'Full Name'),
                    const SizedBox(height: 8),
                    BookingTextField(
                      controller: _nameCtrl,
                      hint: 'Jean Pierre Habimana',
                      icon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      validator: _validateName,
                    ),

                    const SizedBox(height: 20),

                    const FieldLabel(label: 'Email Address'),
                    const SizedBox(height: 8),
                    BookingTextField(
                      controller: _emailCtrl,
                      hint: 'user@email.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),

                    const SizedBox(height: 20),

                    const FieldLabel(label: 'Phone Number'),
                    const SizedBox(height: 8),
                    BookingTextField(
                      controller: _phoneCtrl,
                      hint: '+250 7XX XXX XXX',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                    ),

                    const SizedBox(height: 36),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                              AppColors.primary.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text('Save Changes',
                                style: GoogleFonts.sora(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
