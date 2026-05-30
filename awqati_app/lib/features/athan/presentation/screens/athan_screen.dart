// lib/features/athan/presentation/screens/athan_screen.dart
// Beautiful fullscreen Athan display screen

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/services/athan_service.dart';

class AthanScreen extends ConsumerStatefulWidget {
  final String prayerName;

  const AthanScreen({super.key, required this.prayerName});

  @override
  ConsumerState<AthanScreen> createState() => _AthanScreenState();
}

class _AthanScreenState extends ConsumerState<AthanScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _ringController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _ringAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );

    // Auto dismiss after athan completes
    ref.listenManual(athanProvider, (previous, next) {
      if (previous?.isAthanTime == true && !next.isAthanTime) {
        if (mounted) context.pop();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final athanState = ref.watch(athanProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Deep atmospheric background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color(0xFF1A0A00),
                  Color(0xFF0A0520),
                  Color(0xFF000510),
                  Colors.black,
                ],
                stops: [0.0, 0.4, 0.7, 1.0],
                center: Alignment.center,
                radius: 1.4,
              ),
            ),
          ),

          // Geometric pattern overlay
          Opacity(
            opacity: 0.03,
            child: CustomPaint(
              painter: _AthanPatternPainter(),
              size: size,
            ),
          ),

          // Radiating rings
          Center(
            child: AnimatedBuilder(
              animation: _ringAnimation,
              builder: (context, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(4, (i) {
                    final progress = (_ringAnimation.value + i * 0.25) % 1.0;
                    return Opacity(
                      opacity: (1 - progress) * 0.3,
                      child: Container(
                        width: 100 + progress * size.shortestSide * 0.9,
                        height: 100 + progress * size.shortestSide * 0.9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.gold,
                            width: 1.5 * (1 - progress),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mosque silhouette / crescent icon
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withOpacity(0.1),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mosque,
                      color: AppColors.gold,
                      size: 48,
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.5, 0.5)),

                const SizedBox(height: 40),

                // وقت الأذان
                Text(
                  'وقت الأذان',
                  style: ArabicTextStyles.arabicUI(
                    fontSize: 42,
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                  textDirection: TextDirection.rtl,
                ).animate(delay: 200.ms).fadeIn(duration: 600.ms).slideY(begin: 0.2),

                const SizedBox(height: 16),

                // Prayer name in Arabic
                Text(
                  athanState.currentPrayerAr.isNotEmpty
                      ? athanState.currentPrayerAr
                      : _getAthanPrayerName(widget.prayerName),
                  style: ArabicTextStyles.arabicUI(
                    fontSize: 28,
                    color: AppColors.textSecondary,
                  ),
                  textDirection: TextDirection.rtl,
                ).animate(delay: 300.ms).fadeIn(duration: 600.ms),

                const SizedBox(height: 60),

                // Arabic Athan text
                Text(
                  'اللَّهُ أَكْبَر',
                  style: ArabicTextStyles.quranText(
                    fontSize: 36,
                    color: AppColors.textPrimary.withOpacity(0.9),
                  ),
                  textDirection: TextDirection.rtl,
                ).animate(delay: 500.ms).fadeIn(duration: 800.ms),

                const SizedBox(height: 60),

                // Sound wave indicator
                if (athanState.isPlaying)
                  _SoundWaveIndicator()
                      .animate(delay: 600.ms)
                      .fadeIn(duration: 400.ms),

                const SizedBox(height: 40),

                // Dismiss button
                TextButton(
                  onPressed: () {
                    ref.read(athanProvider.notifier).stopAthan();
                    context.pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Dismiss'),
                ).animate(delay: 800.ms).fadeIn(duration: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAthanPrayerName(String en) {
    const map = {
      'Fajr': 'الفجر',
      'Dhuhr': 'الظهر',
      'Asr': 'العصر',
      'Maghrib': 'المغرب',
      'Isha': 'العشاء',
    };
    return map[en] ?? en;
  }
}

class _SoundWaveIndicator extends StatefulWidget {
  @override
  State<_SoundWaveIndicator> createState() => _SoundWaveIndicatorState();
}

class _SoundWaveIndicatorState extends State<_SoundWaveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(7, (i) {
            final phase = (_controller.value + i * 0.12) % 1.0;
            final height = 8 + math.sin(phase * math.pi * 2).abs() * 28;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 4,
              height: height,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.6 + math.sin(phase * math.pi).abs() * 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

class _AthanPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const spacing = 120.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        _drawOctagram(canvas, paint, Offset(x, y), 40);
      }
    }
  }

  void _drawOctagram(Canvas canvas, Paint paint, Offset center, double r) {
    final path = Path();
    const n = 8;
    for (int i = 0; i < n * 2; i++) {
      final angle = i * math.pi / n - math.pi / 2;
      final radius = i.isEven ? r : r * 0.38;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
