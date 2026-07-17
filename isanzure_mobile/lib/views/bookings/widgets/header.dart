import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../models/schedule_model.dart';

class DetailsHeader extends StatelessWidget {
  const DetailsHeader({
    super.key,
    required this.schedule,
    required this.parallax,
    required this.contentOpacity,
  });

  final ScheduleModel schedule;
  final double parallax;
  final double contentOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Transform.translate(
                offset: Offset(0, parallax * -50),
                child: Image.asset(
                  'assets/img/map-bg.png',
                  fit: BoxFit.cover,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      Text('Booking Details',
                          style: GoogleFonts.sora(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      const SizedBox(width: 48), // balance back button
                    ],
                  ),
                  const SizedBox(height: 24),
                  Opacity(
                    opacity: contentOpacity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _CityBlock(
                            city: schedule.origin, label: 'FROM'),
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                        height: 1.5, color: Colors.white24),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.secondary
                                                .withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 16),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                        height: 1.5, color: Colors.white24),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(schedule.departureTime.split('T').length > 1 ? schedule.departureTime.split('T')[1].substring(0, 5) : '',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                        _CityBlock(
                            city: schedule.destination.trim(),
                            label: 'TO',
                            alignEnd: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Opacity(
                    opacity: contentOpacity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Chip(
                            icon: Icons.calendar_today_rounded,
                            label: schedule.departureTime.split('T').first),
                        const SizedBox(width: 10),
                        _Chip(
                            icon: Icons.directions_bus_rounded,
                            label: schedule.agencyName),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CityBlock extends StatelessWidget {
  const _CityBlock({required this.city, required this.label, this.alignEnd = false});
  final String city;
  final String label;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(city, style: GoogleFonts.sora(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}