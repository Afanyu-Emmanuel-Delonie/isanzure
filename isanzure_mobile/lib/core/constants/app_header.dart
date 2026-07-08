import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_theme.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.bottomPadding = 24,
    this.child,
    this.parallax = 0,
    this.contentOpacity = 1,
  });

  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final double bottomPadding;
  final Widget? child;

  /// 0..1 — shifts the map-bg upward as user scrolls (parallax effect)
  final double parallax;

  /// 0..1 — fades header text content as user scrolls
  final double contentOpacity;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      color: AppColors.primary,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // ── Map pattern with parallax shift ─────────────────────────────
          Positioned(
            top: -parallax * 40, // shifts up by up to 40px as user scrolls
            left: 0,
            right: 0,
            bottom: 0,
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

          // ── Content with scroll-driven fade ─────────────────────────────
          Opacity(
            opacity: contentOpacity.clamp(0.0, 1.0),
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(20, top + 20, 20, bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (leading != null || actions.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        leading ?? const SizedBox.shrink(),
                        if (actions.isNotEmpty)
                          Row(
                            children: actions
                                .map((a) => Padding(
                                      padding:
                                          const EdgeInsets.only(left: 8),
                                      child: a,
                                    ))
                                .toList(),
                          ),
                      ],
                    ),

                  if ((leading != null || actions.isNotEmpty) &&
                      (title != null || child != null))
                    const SizedBox(height: 20),

                  if (title != null)
                    Text(
                      title!,
                      style: GoogleFonts.sora(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  if (title != null && subtitle != null)
                    const SizedBox(height: 4),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                  if (child != null) ...[
                    if (title != null || subtitle != null)
                      const SizedBox(height: 16),
                    child!,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Standard icon button for use inside AppHeader
class AppHeaderIconButton extends StatelessWidget {
  const AppHeaderIconButton({
    super.key,
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );
}
