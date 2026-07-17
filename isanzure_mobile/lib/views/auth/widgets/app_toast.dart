import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_theme.dart';

/// Path assumption: lib/widgets/app_toast.dart
/// Adjust the relative import above if you place this file elsewhere.

enum ToastType { error, success, info }

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
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  late final Animation<double> _opacity =
  CurvedAnimation(parent: _controller, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future.delayed(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  (Color accent, Color bg, IconData icon) get _style {
    switch (widget.type) {
      case ToastType.error:
        return (const Color(0xFFDC2626), const Color(0xFFFEF2F2),
        Icons.error_outline_rounded);
      case ToastType.success:
        return (const Color(0xFF16A34A), const Color(0xFFF0FDF4),
        Icons.check_circle_outline_rounded);
      case ToastType.info:
        return (AppColors.primary, AppColors.primary.withOpacity(0.08),
        Icons.info_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (accent, bg, icon) = _style;

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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accent.withOpacity(0.18)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration:
                        BoxDecoration(color: bg, shape: BoxShape.circle),
                        child: Icon(icon, size: 17, color: accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.bodyText,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.close_rounded,
                          size: 15, color: AppColors.bodyTextSecondary),
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