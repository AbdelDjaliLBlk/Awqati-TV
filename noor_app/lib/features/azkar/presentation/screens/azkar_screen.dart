// lib/features/azkar/presentation/screens/azkar_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/islamic_background.dart';
import '../../../../core/widgets/tv_focus_widget.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/models/azkar_models.dart';

class AzkarScreen extends ConsumerWidget {
  const AzkarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isArabic = settings.isArabic;
    final isTV = Breakpoints.isTV(context);

    return IslamicBackground(
      animate: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTV ? MediaQuery.of(context).size.width * 0.05 : 20,
              vertical: isTV ? MediaQuery.of(context).size.height * 0.05 : 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Directionality(
                  textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                  child: Text(
                    isArabic ? 'الأذكار والأدعية' : 'Azkar & Duas',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.gold,
                          fontFamily: isArabic ? 'Amiri' : null,
                          fontSize: isArabic ? 28 : null,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Directionality(
                  textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                  child: Text(
                    isArabic
                        ? 'حصن المسلم - أذكار وأدعية يومية'
                        : 'Daily remembrance and supplications',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 24),

                // Daily Hadith card
                _DailyHadithCard(isArabic: isArabic)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.05),

                const SizedBox(height: 20),

                // Category grid
                Expanded(
                  child: isTV
                      ? _TVCategoryGrid(isArabic: isArabic)
                      : _PhoneCategoryGrid(isArabic: isArabic),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyHadithCard extends StatelessWidget {
  final bool isArabic;
  const _DailyHadithCard({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final hadith = AzkarData.dailyHadiths[
        DateTime.now().day % AzkarData.dailyHadiths.length];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withOpacity(0.12),
            AppColors.gold.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote, color: AppColors.gold, size: 18),
              const SizedBox(width: 8),
              Text(
                isArabic ? 'حديث اليوم' : "Today's Hadith",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.gold,
                      fontFamily: isArabic ? 'Amiri' : null,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isArabic ? hadith['text']! : hadith['textEn']!,
            style: isArabic
                ? ArabicTextStyles.arabicUI(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  )
                : TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
          ),
          const SizedBox(height: 8),
          Text(
            isArabic ? hadith['narrator']! : hadith['narratorEn']!,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontFamily: isArabic ? 'Amiri' : null,
            ),
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
          ),
        ],
      ),
    );
  }
}

class _PhoneCategoryGrid extends StatelessWidget {
  final bool isArabic;
  const _PhoneCategoryGrid({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: AzkarData.categories.length,
      itemBuilder: (context, i) {
        final category = AzkarData.categories[i];
        return _CategoryCard(
          category: category,
          isArabic: isArabic,
          onTap: () => context.push('/azkar/${category.id}'),
        ).animate(delay: (i * 80).ms).fadeIn(duration: 300.ms).scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1, 1),
            );
      },
    );
  }
}

class _TVCategoryGrid extends StatelessWidget {
  final bool isArabic;
  const _TVCategoryGrid({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: AzkarData.categories.length,
      itemBuilder: (context, i) {
        final category = AzkarData.categories[i];
        return TVFocusableCard(
          onTap: () => context.push('/azkar/${category.id}'),
          child: _CategoryCardContent(category: category, isArabic: isArabic),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final AzkarCategory category;
  final bool isArabic;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withOpacity(0.15)),
        ),
        child: _CategoryCardContent(category: category, isArabic: isArabic),
      ),
    );
  }
}

class _CategoryCardContent extends StatelessWidget {
  final AzkarCategory category;
  final bool isArabic;
  const _CategoryCardContent({required this.category, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(category.icon, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          Text(
            isArabic ? category.nameAr : category.nameEn,
            style: TextStyle(
              color: AppColors.gold,
              fontSize: isArabic ? 15 : 13,
              fontWeight: FontWeight.w600,
              fontFamily: isArabic ? 'Amiri' : null,
            ),
            textAlign: TextAlign.center,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          ),
          const SizedBox(height: 4),
          Text(
            '${category.azkar.length} ${isArabic ? "ذكر" : "adhkar"}',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
