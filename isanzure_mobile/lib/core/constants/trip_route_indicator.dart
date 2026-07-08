import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';

class DashedLine extends StatelessWidget {
  const DashedLine({super.key, this.color = const Color(0xFFCDD0DC)});
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedLinePainter(color),
    child: const SizedBox(height: 1),
  );
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}

// ── Bus icon with dashed lines on either side ────────────────────────────────
class RouteBusIndicator extends StatelessWidget {
  const RouteBusIndicator({
    super.key,
    this.iconColor = AppColors.primary,
    this.lineColor = const Color(0xFFCDD0DC),
    this.size = 14,
  });

  final Color iconColor;
  final Color lineColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: DashedLine(color: lineColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.directions_bus_rounded,
                size: size, color: iconColor),
          ),
        ),
        Expanded(child: DashedLine(color: lineColor)),
      ],
    );
  }
}