import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_theme.dart';
import '../../../core/constants/app_header.dart';
import '../../../viewmodels/auth_viewmodel.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.parallax = 0,
    this.contentOpacity = 1,
  });

  /// 0..1 — drives the map background upward as user scrolls
  final double parallax;

  /// 0..1 — fades the text content as user scrolls into the card
  final double contentOpacity;

  /// Helper to get time-based greeting
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    if (hour < 21) return 'Good evening,';
    return 'Good night,';
  }

  /// Helper to format the user's name
  String _formatName(String fullName) {
    final name = fullName.trim();
    if (name.isEmpty) return 'Guest';
    
    // The previous name "Afanyu Emmanuel" is 15 characters long.
    // If the full name fits within that length, use it completely.
    // Otherwise, truncate it with an ellipsis.
    if (name.length > 16) {
      return '${name.substring(0, 16)}...';
    }
    
    return name;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Fetch the user's name from our AuthViewModel
    final user = context.watch<AuthViewModel>().currentUser;
    final fullName = user?.name ?? 'Guest';

    // 2. Compute dynamic strings
    final greeting = _getGreeting();
    final displayName = _formatName(fullName);

    return AppHeader(
      bottomPadding: 140,
      parallax: parallax,
      contentOpacity: contentOpacity,
      leading: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_outline,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  greeting,
                  style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              Text('$displayName 👋',
                  style: GoogleFonts.sora(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
      actions: [
        AppHeaderIconButton(icon: Icons.notifications_none),
      ],
    );
  }
}
