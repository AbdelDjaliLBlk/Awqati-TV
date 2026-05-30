// lib/core/widgets/islamic_background.dart
// Beautiful Islamic ambient background with geometric patterns

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BackgroundStyle {
  deepNight,
  geometric,
  stars,
  mosque,
  gradient,
}

class IslamicBackground extends StatefulWidget {
  final Widget child;
  final BackgroundStyle style;
  final bool animate;

  const IslamicBackground({
    super.key,
    required this.child,
    this.style = BackgroundStyle.deepNight,
    this.animate = true,
  });

  @override
  State<IslamicBackground> createState() => _IslamicBackgroundState();
}

class _IslamicBackgroundState extends State<IslamicBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF070B14),
                Color(0xFF0A0E1A),
                Color(0xFF0C1220),
              ],
            ),
          ),
        ),
        // Geometric pattern overlay
        if (widget.style == BackgroundStyle.geometric ||
            widget.style == BackgroundStyle.deepNight)
          Opacity(
            opacity: 0.04,
            child: CustomPaint(
              painter: IslamicGeometricPainter(),
              size: Size.infinite,
            ),
          ),
        // Stars for night mode
        if (widget.style == BackgroundStyle.stars ||
            widget.style == BackgroundStyle.deepNight)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: StarsPainter(animation: _controller.value),
                size: Size.infinite,
              );
            },
          ),
        // Ambient glow at top
        Positioned(
          top: -100,
          left: 0,
          right: 0,
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.gold.withOpacity(0.05),
                  Colors.transparent,
                ],
                radius: 0.8,
              ),
            ),
          ),
        ),
        // Content
        widget.child,
      ],
    );
  }
}

/// Geometric Islamic pattern painter
class IslamicGeometricPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const cellSize = 80.0;
    final cols = (size.width / cellSize).ceil() + 2;
    final rows = (size.height / cellSize).ceil() + 2;

    for (int row = -1; row < rows; row++) {
      for (int col = -1; col < cols; col++) {
        final cx = col * cellSize + (row.isOdd ? cellSize / 2 : 0);
        final cy = row * cellSize;
        _drawIslamicStar(canvas, paint, Offset(cx, cy), cellSize * 0.4);
      }
    }
  }

  void _drawIslamicStar(Canvas canvas, Paint paint, Offset center, double radius) {
    const points = 8;
    const innerRatio = 0.4;
    final path = Path();

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final r = i.isEven ? radius : radius * innerRatio;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Twinkling stars painter
class StarsPainter extends CustomPainter {
  final double animation;
  static final List<_Star> _stars = [];
  static bool _initialized = false;

  StarsPainter({required this.animation}) {
    if (!_initialized) {
      final random = math.Random(42);
      for (int i = 0; i < 120; i++) {
        _stars.add(_Star(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 2.0 + 0.3,
          opacity: random.nextDouble() * 0.5 + 0.1,
          twinkleOffset: random.nextDouble() * math.pi * 2,
          twinkleSpeed: random.nextDouble() * 2 + 0.5,
        ));
      }
      _initialized = true;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in _stars) {
      final twinkle = (math.sin(animation * math.pi * 2 * star.twinkleSpeed + star.twinkleOffset) + 1) / 2;
      final opacity = star.opacity * (0.4 + twinkle * 0.6);
      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, star.size * 0.5);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StarsPainter oldDelegate) =>
      oldDelegate.animation != animation;
}

class _Star {
  final double x, y, size, opacity, twinkleOffset, twinkleSpeed;
  const _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.twinkleOffset,
    required this.twinkleSpeed,
  });
}

/// Gold divider with Islamic ornament
class IslamicDivider extends StatelessWidget {
  final double height;

  const IslamicDivider({super.key, this.height = 1});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, AppColors.gold.withOpacity(0.4)],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(Icons.star, size: 10, color: AppColors.gold.withOpacity(0.6)),
        ),
        Expanded(
          child: Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gold.withOpacity(0.4), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
