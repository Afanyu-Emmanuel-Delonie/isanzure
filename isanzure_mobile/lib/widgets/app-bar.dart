import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_header.dart';


class NavHeader extends StatelessWidget {
  const NavHeader({
    super.key,
    required this.title,
    this.titleStyle,
    this.showBackButton = false,
    this.onBackTap,
    this.onNotificationTap,
    this.notificationCount,
    this.parallax = 0,
    this.contentOpacity = 1,
    this.bottomPadding = 140,
  });

  /// Centered title text.
  final String title;
  final TextStyle? titleStyle;


  final bool showBackButton;
  final VoidCallback? onBackTap;

  final VoidCallback? onNotificationTap;


  final int? notificationCount;


  final double parallax;


  final double contentOpacity;

  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      bottomPadding: bottomPadding,
      parallax: parallax,
      contentOpacity: contentOpacity,
      leading: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            if (showBackButton)
              _HeaderIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
              ),
            _NotificationButton(
              count: notificationCount,
              onTap: onNotificationTap,
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: titleStyle ??
                      GoogleFonts.sora(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Balances the left-side icon width(s) so the title
            // stays visually centered rather than centered only
            // between the icons and the right edge.
            SizedBox(width: showBackButton ? 76 : 38),
          ],
        ),
      ),
      actions: const [],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({this.count, this.onTap});

  final int? count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final showBadge = (count ?? 0) > 0;
    final label = (count ?? 0) > 9 ? '9+' : '${count ?? 0}';

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 38,
        height: 38,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.notifications_none,
                  color: Colors.white, size: 20),
            ),
            if (showBadge)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  height: 16,
                  constraints: const BoxConstraints(minWidth: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4D4D),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      height: 1,
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

/// --- Usage ---
///
/// NavHeader(
///   title: 'Trip Details',
///   showBackButton: true,
///   notificationCount: 3,
///   onNotificationTap: () {},
/// )
///
/// // On a root/tab screen with no back button:
/// NavHeader(
///   title: 'Home',
///   notificationCount: 0, // no badge shown
/// )