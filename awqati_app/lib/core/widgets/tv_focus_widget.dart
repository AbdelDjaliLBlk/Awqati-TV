// lib/core/widgets/tv_focus_widget.dart
// Wrapper widget that adds TV remote focus support to any widget

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Wraps a widget with TV focus highlight and keyboard navigation support
class TVFocusable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSelect;
  final bool autofocus;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final Color? focusColor;

  const TVFocusable({
    super.key,
    required this.child,
    this.onSelect,
    this.autofocus = false,
    this.borderRadius,
    this.padding,
    this.focusColor,
  });

  @override
  State<TVFocusable> createState() => _TVFocusableState();
}

class _TVFocusableState extends State<TVFocusable>
    with SingleTickerProviderStateMixin {
  bool _hasFocus = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() => _hasFocus = hasFocus);
    if (hasFocus) {
      _scaleController.forward();
    } else {
      _scaleController.reverse();
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.select ||
            event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space)) {
      widget.onSelect?.call();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final focusColor = widget.focusColor ?? AppColors.tvFocus;

    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: _handleFocusChange,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: widget.onSelect,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: widget.padding,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              border: _hasFocus
                  ? Border.all(color: focusColor, width: 2.5)
                  : Border.all(color: Colors.transparent, width: 2.5),
              boxShadow: _hasFocus
                  ? [
                      BoxShadow(
                        color: focusColor.withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// A focusable card widget for TV lists
class TVFocusableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsets padding;
  final bool autofocus;

  const TVFocusableCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.padding = const EdgeInsets.all(16),
    this.autofocus = false,
  });

  @override
  State<TVFocusableCard> createState() => _TVFocusableCardState();
}

class _TVFocusableCardState extends State<TVFocusableCard> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseBg = widget.backgroundColor ??
        (isDark ? AppColors.surface : Colors.white);

    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (f) => setState(() => _hasFocus = f),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onTap?.call();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _hasFocus
                ? AppColors.gold.withOpacity(0.1)
                : baseBg,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            border: Border.all(
              color: _hasFocus
                  ? AppColors.gold
                  : AppColors.gold.withOpacity(0.15),
              width: _hasFocus ? 2 : 1,
            ),
            boxShadow: _hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.25),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
