import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_header.dart';
import '../../core/constants/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../auth/login_view.dart';
import 'edit_profile_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _scrollCtrl = ScrollController();
  double _parallax = 0;
  double _opacity = 1;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final o = _scrollCtrl.offset;
    final p = (o / 180).clamp(0.0, 1.0);
    final op = (1.0 - o / 120).clamp(0.0, 1.0);
    if (p != _parallax || op != _opacity) {
      setState(() {
        _parallax = p;
        _opacity = op;
      });
    }
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        final user = vm.currentUser;
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SingleChildScrollView(
            controller: _scrollCtrl,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            child: Column(
              children:
              [
            // ── Header with avatar ──────────────────────────────────────
            AppHeader(
              parallax: _parallax,
              contentOpacity: _opacity,
              bottomPadding: 56,
              actions: [
                AppHeaderIconButton(
                  icon: Icons.edit_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileView()),
                  ),
                ),
              ],
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: const Icon(Icons.person_rounded,
                        size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? '...',
                          style: GoogleFonts.sora(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      const SizedBox(height: 3),
                      Text(user?.email ?? '',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),

            // ── Stats card (overlapping header) ────────────────────────
            Transform.translate(
              offset: const Offset(0, -36),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 18, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _StatCell(value: '12', label: 'Trips'),
                      _Divider(),
                      _StatCell(value: '2', label: 'Upcoming'),
                      _Divider(),
                      _StatCell(value: 'RWF 34K', label: 'Spent'),
                    ],
                  ),
                ),
              ),
            ),

            // ── Sections ───────────────────────────────────────────────
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel('Account'),
                    const SizedBox(height: 8),
                    _MenuCard(items: [
                      _MenuItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Personal Information',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfileView()),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.phone_outlined,
                        label: 'Phone Number',
                        trailing: Text(user?.phone ?? '',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.bodyTextSecondary)),
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.lock_outline_rounded,
                        label: 'Change Password',
                        onTap: () {},
                      ),
                    ]),

                    const SizedBox(height: 20),
                    _SectionLabel('Preferences'),
                    const SizedBox(height: 8),
                    _MenuCard(items: [
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        trailing: _Toggle(),
                        onTap: null,
                      ),
                      _MenuItem(
                        icon: Icons.language_outlined,
                        label: 'Language',
                        trailing: Text('English',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.bodyTextSecondary)),
                        onTap: () {},
                      ),
                    ]),

                    const SizedBox(height: 20),
                    _SectionLabel('Support'),
                    const SizedBox(height: 8),
                    _MenuCard(items: [
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & FAQ',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Contact Support',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.star_outline_rounded,
                        label: 'Rate the App',
                        onTap: () {},
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // ── Logout ──────────────────────────────────────────
                    GestureDetector(
                      onTap: () async {
                        await vm.logout();
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginView()),
                          (_) => false,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout_rounded,
                                size: 18, color: Color(0xFFE11D48)),
                            const SizedBox(width: 8),
                            Text('Log Out',
                                style: GoogleFonts.sora(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFE11D48))),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        );
      },
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.sora(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
            const SizedBox(height: 3),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.bodyTextSecondary)),
          ],
        ),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 32,
        color: const Color(0xFFE5E7F0),
      );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.sora(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.bodyTextSecondary),
      );
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.items});
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.vertical(
                  top: i == 0 ? const Radius.circular(14) : Radius.zero,
                  bottom: isLast ? const Radius.circular(14) : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon,
                            size: 17, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(item.label,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.bodyText)),
                      ),
                      if (item.trailing != null) ...[
                        item.trailing!,
                        const SizedBox(width: 6),
                      ],
                      if (item.onTap != null)
                        const Icon(Icons.chevron_right_rounded,
                            size: 18, color: AppColors.bodyTextSecondary),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                const Divider(
                    height: 1, indent: 62, color: Color(0xFFF0F0F5)),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
}

class _Toggle extends StatefulWidget {
  @override
  State<_Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<_Toggle> {
  bool _on = true;

  @override
  Widget build(BuildContext context) => Switch(
        value: _on,
        onChanged: (v) => setState(() => _on = v),
        activeColor: AppColors.primary,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
}
