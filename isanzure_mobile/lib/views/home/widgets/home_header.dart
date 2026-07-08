import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/app_header.dart';

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

  @override
  Widget build(BuildContext context) {
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
              Text('Good morning,',
                  style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              Text('Afanyu Emmanuel 👋',
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
