// lib/features/azkar/presentation/screens/azkar_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/islamic_background.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/models/azkar_models.dart';

class AzkarDetailScreen extends ConsumerStatefulWidget {
  final String category;
  const AzkarDetailScreen({super.key, required this.category});

  @override
  ConsumerState<AzkarDetailScreen> createState() => _AzkarDetailScreenState();
}

class _AzkarDetailScreenState extends ConsumerState<AzkarDetailScreen> {
  late List<ZikrEntry> _azkar;
  late AzkarCategory _category;
  int _currentIndex = 0;
  late List<int> _counts;

  @override
  void initState() {
    super.initState();
    _category = AzkarData.categories.firstWhere(
      (c) => c.id == widget.category,
      orElse: () => AzkarData.categories.first,
    );
    _azkar = List.from(_category.azkar);
    _counts = _azkar.map((z) => z.count).toList();
  }

  void _decrement() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_counts[_currentIndex] > 0) {
        _counts[_currentIndex]--;
      }
      if (_counts[_currentIndex] == 0 && _currentIndex < _azkar.length - 1) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) setState(() => _currentIndex++);
        });
      }
    });
  }

  void _resetCurrent() {
    setState(() => _counts[_currentIndex] = _azkar[_currentIndex].count);
  }

  void _resetAll() {
    setState(() {
      _currentIndex = 0;
      _counts = _azkar.map((z) => z.count).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isArabic = settings.isArabic;
    final current = _azkar[_currentIndex];
    final remaining = _counts[_currentIndex];
    final isDone = remaining == 0;
    final allDone = _counts.every((c) => c == 0);
    final progress = (_currentIndex + (1 - remaining / current.count)) / _azkar.length;

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.midnight.withOpacity(0.9),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            isArabic ? _category.nameAr : _category.nameEn,
            style: TextStyle(
              color: AppColors.gold,
              fontFamily: isArabic ? 'Amiri' : null,
              fontSize: isArabic ? 20 : 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _resetAll,
              child: Text(
                isArabic ? 'إعادة' : 'Reset',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.surfaceLighter,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
              minHeight: 3,
            ),

            // Zikr counter row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentIndex + 1} / ${_azkar.length}',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  TextButton(
                    onPressed: _currentIndex < _azkar.length - 1
                        ? () => setState(() => _currentIndex++)
                        : null,
                    child: Text(
                      isArabic ? 'التالي ›' : 'Next ›',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: allDone
                  ? _AllDoneView(isArabic: isArabic, onReset: _resetAll)
                  : _ZikrView(
                      zikr: current,
                      remaining: remaining,
                      isArabic: isArabic,
                      isDone: isDone,
                      onTap: _decrement,
                      onReset: _resetCurrent,
                      fontSize: settings.fontSize,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZikrView extends StatelessWidget {
  final ZikrEntry zikr;
  final int remaining;
  final bool isArabic;
  final bool isDone;
  final VoidCallback onTap;
  final VoidCallback onReset;
  final double fontSize;

  const _ZikrView({
    required this.zikr,
    required this.remaining,
    required this.isArabic,
    required this.isDone,
    required this.onTap,
    required this.onReset,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          // Arabic text
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.emerald.withOpacity(0.06)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDone
                    ? AppColors.emerald.withOpacity(0.3)
                    : AppColors.gold.withOpacity(0.15),
              ),
            ),
            child: Column(
              children: [
                Text(
                  zikr.textAr,
                  style: ArabicTextStyles.arabicUI(
                    fontSize: 22 * fontSize,
                    color: isDone
                        ? AppColors.emerald
                        : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                if (!isArabic && zikr.textEn != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    zikr.textEn!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13 * fontSize,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (zikr.virtue != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                    ),
                    child: Text(
                      zikr.virtue!,
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 11,
                        fontFamily: 'Amiri',
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Counter display
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              key: ValueKey(remaining),
              remaining.toString(),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: isDone ? AppColors.emerald : AppColors.gold,
                    fontSize: 80,
                    letterSpacing: 4,
                  ),
            ),
          ),
          Text(
            isArabic ? 'مرة متبقية' : 'remaining',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),

          const SizedBox(height: 36),

          // Tap button
          GestureDetector(
            onTap: isDone ? null : onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDone
                      ? [AppColors.emerald.withOpacity(0.3), AppColors.emerald.withOpacity(0.1)]
                      : [AppColors.gold.withOpacity(0.3), AppColors.gold.withOpacity(0.1)],
                ),
                border: Border.all(
                  color: isDone ? AppColors.emerald : AppColors.gold,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDone ? AppColors.emerald : AppColors.gold).withOpacity(0.25),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                isDone ? Icons.check : Icons.touch_app,
                color: isDone ? AppColors.emerald : AppColors.gold,
                size: 42,
              ),
            ),
          ),

          if (isDone) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onReset,
              child: Text(
                isArabic ? 'إعادة هذا الذكر' : 'Repeat this dhikr',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AllDoneView extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onReset;

  const _AllDoneView({required this.isArabic, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('✨', style: const TextStyle(fontSize: 64))
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            isArabic ? 'تم الانتهاء من الأذكار' : 'Azkar Complete',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.gold,
                  fontFamily: isArabic ? 'Amiri' : null,
                ),
          ).animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 8),
          Text(
            isArabic ? 'بارك الله فيك' : 'May Allah bless you',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontFamily: isArabic ? 'Amiri' : null,
            ),
          ).animate(delay: 400.ms).fadeIn(),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh),
            label: Text(isArabic ? 'إعادة من البداية' : 'Start Again'),
          ).animate(delay: 600.ms).fadeIn(),
        ],
      ),
    );
  }
}
