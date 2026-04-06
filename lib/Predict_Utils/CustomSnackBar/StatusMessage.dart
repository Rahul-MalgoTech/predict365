// lib/Predict_Utils/utils.dart
//
// Custom beautiful toast notifications using Flutter overlays.
// Matches Predict365 gold theme — no external toast package needed for styling.
// Still uses fluttertoast as fallback if needed, but primary method is overlay.

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ── Toast Type ─────────────────────────────────────────────────────
enum _ToastType { success, error, warning, info }

class Utils {
  // ── Average Rating ─────────────────────────────────────────────
  static double averageRating(List<int> rating) {
    var avgRating = 0;
    for (int i = 0; i < rating.length; i++) {
      avgRating = avgRating + rating[i];
    }
    return double.parse((avgRating / rating.length).toStringAsFixed(1));
  }

  // ── Field Focus Change ─────────────────────────────────────────
  static void fieldFocusChange(
      BuildContext context,
      FocusNode current,
      FocusNode nextFocus,
      ) {
    current.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  // ────────────────────────────────────────────────────────────────
  // PRIMARY TOAST METHODS  (overlay-based, beautiful)
  // ────────────────────────────────────────────────────────────────

  /// ✅ Green success toast
  static void snackBar(String message, [BuildContext? context]) {
    if (context != null) {
      _showOverlayToast(context, message, _ToastType.success);
    } else {
      // fallback
      Fluttertoast.showToast(
        msg: message,
        backgroundColor: const Color(0xFF2CB67D),
        textColor: Colors.white,
      );
    }
  }

  /// ❌ Red error toast
  static void snackBarErrorMessage(String message, [BuildContext? context]) {
    if (context != null) {
      _showOverlayToast(context, message, _ToastType.error);
    } else {
      Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  /// ⚠️ Warning toast
  static void snackBarWarning(String message, BuildContext context) {
    _showOverlayToast(context, message, _ToastType.warning);
  }

  /// ℹ️ Info / gold toast
  static void snackBarInfo(String message, BuildContext context) {
    _showOverlayToast(context, message, _ToastType.info);
  }

  // ── Scaffold snackbars (kept for backward compat) ───────────────
  static snackBar1(String message, BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2CB67D),
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  static snackBarErrorMessage1(String message, BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // OVERLAY TOAST ENGINE
  // ────────────────────────────────────────────────────────────────

  static OverlayEntry? _activeEntry;

  static void _showOverlayToast(
      BuildContext context,
      String message,
      _ToastType type,
      ) {
    // Remove existing toast if showing
    _activeEntry?.remove();
    _activeEntry = null;

    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        type: type,
        onDismiss: () {
          entry.remove();
          if (_activeEntry == entry) _activeEntry = null;
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }
}

// ── Toast Widget ───────────────────────────────────────────────────
class _ToastWidget extends StatefulWidget {
  final String message;
  final _ToastType type;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slideY;
  late final Animation<double> _fade;

  // ── Theme per type ────────────────────────────────────────────
  static const _configs = {
    _ToastType.success: _ToastConfig(
      icon: Icons.check_circle_rounded,
      iconColor: Color(0xFF2CB67D),
      bgColor: Color(0xFF0E1F1A),
      borderColor: Color(0xFF2CB67D),
      glowColor: Color(0x332CB67D),
      label: 'Success',
      labelColor: Color(0xFF2CB67D),
    ),
    _ToastType.error: _ToastConfig(
      icon: Icons.cancel_rounded,
      iconColor: Color(0xFFFF4D4D),
      bgColor: Color(0xFF1F0E0E),
      borderColor: Color(0xFFFF4D4D),
      glowColor: Color(0x33FF4D4D),
      label: 'Error',
      labelColor: Color(0xFFFF4D4D),
    ),
    _ToastType.warning: _ToastConfig(
      icon: Icons.warning_rounded,
      iconColor: Color(0xFFF5A623),
      bgColor: Color(0xFF1F1A0E),
      borderColor: Color(0xFFF5A623),
      glowColor: Color(0x33F5A623),
      label: 'Warning',
      labelColor: Color(0xFFF5A623),
    ),
    _ToastType.info: _ToastConfig(
      icon: Icons.info_rounded,
      iconColor: Color(0xFF977032),
      bgColor: Color(0xFF1A170E),
      borderColor: Color(0xFF977032),
      glowColor: Color(0x33977032),
      label: 'Info',
      labelColor: Color(0xFFF5A623),
    ),
  };

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _slideY = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    _ctrl.forward();

    // Auto dismiss after 3s
    Future.delayed(const Duration(milliseconds: 3000), _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _configs[widget.type]!;
    final sw = MediaQuery.of(context).size.width;

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 24,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _ctrl,
                curve: Curves.easeOutBack,
              )),
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  constraints: BoxConstraints(maxWidth: sw - 32),
                  decoration: BoxDecoration(
                    color: config.bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: config.borderColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: config.glowColor,
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // ── Animated icon container ──
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: config.iconColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: config.iconColor.withOpacity(0.3),
                              width: 1),
                        ),
                        child: Icon(config.icon,
                            color: config.iconColor, size: 22),
                      ),

                      const SizedBox(width: 12),

                      // ── Text ──
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              config.label,
                              style: TextStyle(
                                color: config.labelColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // ── Dismiss X ──
                      GestureDetector(
                        onTap: _dismiss,
                        child: Icon(Icons.close_rounded,
                            color: Colors.white.withOpacity(0.4), size: 18),
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

// ── Config data class ──────────────────────────────────────────────
class _ToastConfig {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final Color glowColor;
  final String label;
  final Color labelColor;

  const _ToastConfig({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.glowColor,
    required this.label,
    required this.labelColor,
  });
}