import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_theme.dart';

/// Path assumption: lib/widgets/app_toast.dart
/// Adjust the relative import above if you place this file elsewhere.

enum ToastType { error, success, warning, info }

/// A top-anchored, non-blocking notification. Replaces
/// ScaffoldMessenger's default bottom SnackBar for auth flows, where
/// the field the user just interacted with is usually near the top
/// of a scrollable form — a bottom toast is easy to miss or requires
/// scrolling to see.
class AppToast {
  static OverlayEntry? _current;

  static void show(
      BuildContext context, {
        required String message,
        ToastType type = ToastType.error,
        Duration duration = const Duration(seconds: 3),
      }) {
    _current?.remove();
    _current = null;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastCard(
        message: message,
        type: type,
        duration: duration,
        onDismissed: () {
          entry.remove();
          if (_current == entry) _current = null;
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }

  static void error(BuildContext context, String message) =>
      show(context, message: message, type: ToastType.error);

  static void success(BuildContext context, String message) =>
      show(context, message: message, type: ToastType.success);

  static void warning(BuildContext context, String message) =>
      show(context, message: message, type: ToastType.warning);

  static void info(BuildContext context, String message) =>
      show(context, message: message, type: ToastType.info);
}

class _ToastStyle {
  const _ToastStyle(this.accent, this.accentSoft, this.bg, this.icon, this.label);
  final Color accent;
  final Color accentSoft;
  final Color bg;
  final IconData icon;
  final String label;
}

const _styles = {
  ToastType.error: _ToastStyle(
    Color(0xFFDC2626),
    Color(0xFFFCA5A5),
    Color(0xFFFEF2F2),
    Icons.error_rounded,
    'Error',
  ),
  ToastType.success: _ToastStyle(
    Color(0xFF16A34A),
    Color(0xFF86EFAC),
    Color(0xFFF0FDF4),
    Icons.check_circle_rounded,
    'Success',
  ),
  ToastType.warning: _ToastStyle(
    Color(0xFFD97706),
    Color(0xFFFCD34D),
    Color(0xFFFFFBEB),
    Icons.warning_rounded,
    'Heads up',
  ),
  ToastType.info: _ToastStyle(
    AppColors.primary,
    Color(0xFF93C5FD),
    Color(0xFFEFF6FF),
    Icons.info_rounded,
    'Info',
  ),
};

/// A single, modular icon for the toast — just the glyph, animated in.
/// No circle backing, no extra shadow layer: the color-coded icon
/// against the toast's own background is enough to read the type.
class _ToastIcon extends StatelessWidget {
  const _ToastIcon({
    required this.icon,
    required this.color,
    required this.scale,
  });

  final IconData icon;
  final Color color;
  final Animation<double> scale;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: Icon(icon, size: 22, color: color),
    );
  }
}

class _ToastCard extends StatefulWidget {
  const _ToastCard({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard>
    with TickerProviderStateMixin {
  // Entrance/exit: slide + fade, with a slight overshoot for some bounce.
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
    reverseDuration: const Duration(milliseconds: 220),
  );
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, -1.4),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _entrance,
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInCubic,
  ));
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0, 0.4, curve: Curves.easeOut),
    reverseCurve: Curves.easeIn,
  );

  // Icon pops in with a little extra spring, slightly after the card starts.
  late final Animation<double> _iconScale = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0.25, 1.0, curve: Curves.elasticOut),
  );

  // Countdown bar drains over the toast's lifetime — doubles as a subtle
  // progress cue and makes the auto-dismiss feel intentional, not abrupt.
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _entrance.forward();
    _progress.forward();
    _progress.addStatusListener((status) {
      if (status == AnimationStatus.completed) _dismiss();
    });
  }

  Future<void> _dismiss() async {
    if (_dismissing || !mounted) return;
    _dismissing = true;
    _progress.stop();
    await _entrance.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = _styles[widget.type]!;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: SlideTransition(
          position: _offset,
          child: FadeTransition(
            opacity: _opacity,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: _dismiss,
                onVerticalDragEnd: (d) {
                  if ((d.primaryVelocity ?? 0) < 0) _dismiss();
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  decoration: BoxDecoration(
                    color: style.bg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: style.accent.withOpacity(0.28)),
                    boxShadow: [
                      BoxShadow(
                        color: style.accent.withOpacity(0.22),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ToastIcon(
                              icon: style.icon,
                              color: style.accent,
                              scale: _iconScale,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    style.label,
                                    style: GoogleFonts.sora(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                      color: style.accent,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.message,
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.bodyText,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _dismiss,
                              child: Icon(Icons.close_rounded,
                                  size: 16, color: AppColors.bodyTextSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}