// lib/features/prayer/presentation/screens/prayer_screen.dart
// Prayer times screen with elegant card layout

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/islamic_background.dart';
import '../../../../core/widgets/tv_focus_widget.dart';
import '../providers/prayer_provider.dart';
import '../../data/models/prayer_models.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerState = ref.watch(prayerProvider);
    final settings = ref.watch(settingsProvider);
    final isArabic = settings.isArabic;
    final isTV = Breakpoints.isTV(context);

    return IslamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: isTV ? null : _buildAppBar(context, prayerState, isArabic),
        body: SafeArea(
          child: prayerState.isLoading
              ? _buildLoading()
              : prayerState.error != null && prayerState.prayers.isEmpty
                  ? _buildError(context, ref, prayerState.error!, isArabic)
                  : _buildContent(context, ref, prayerState, settings, isTV),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, PrayerTimesState state, bool isArabic) {
    return AppBar(
      title: Column(
        crossAxisAlignment:
            isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'مواقيت الصلاة' : 'Prayer Times',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.gold,
                  fontFamily: isArabic ? 'Amiri' : null,
                ),
          ),
          if (state.cityName.isNotEmpty)
            Text(
              state.cityName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: AppColors.gold,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Calculating Prayer Times...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildError(
      BuildContext context, WidgetRef ref, String error, bool isArabic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: AppColors.gold.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'تعذر تحديد الموقع' : 'Location unavailable',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontFamily: isArabic ? 'Amiri' : null,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'يرجى السماح بالوصول إلى الموقع'
                  : 'Please allow location access for accurate prayer times',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(prayerProvider.notifier).refreshLocation(),
              icon: const Icon(Icons.refresh),
              label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    PrayerTimesState state,
    AppSettings settings,
    bool isTV,
  ) {
    if (isTV) {
      return _TVPrayerLayout(state: state, settings: settings);
    }
    return _PhonePrayerLayout(state: state, settings: settings, ref: ref);
  }
}

/// Phone layout
class _PhonePrayerLayout extends StatelessWidget {
  final PrayerTimesState state;
  final AppSettings settings;
  final WidgetRef ref;

  const _PhonePrayerLayout({
    required this.state,
    required this.settings,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = settings.isArabic;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Countdown card
          _NextPrayerCard(state: state, isArabic: isArabic)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.1, end: 0),
          const SizedBox(height: 20),
          // Prayer cards
          ...state.prayers.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PrayerCard(
                prayer: entry.value,
                isArabic: isArabic,
                use24h: settings.use24hClock,
              )
                  .animate(delay: (entry.key * 60).ms)
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: isArabic ? 0.05 : -0.05, end: 0),
            );
          }),
          const SizedBox(height: 12),
          // Refresh button
          TextButton.icon(
            onPressed: () => ref.read(prayerProvider.notifier).refreshLocation(),
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(
              isArabic ? 'تحديث الموقع' : 'Refresh Location',
              style: TextStyle(fontFamily: isArabic ? 'Amiri' : null),
            ),
            style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// TV layout - grid based
class _TVPrayerLayout extends StatelessWidget {
  final PrayerTimesState state;
  final AppSettings settings;

  const _TVPrayerLayout({required this.state, required this.settings});

  @override
  Widget build(BuildContext context) {
    final isArabic = settings.isArabic;
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.06,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title + city
          Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Row(
              children: [
                Text(
                  isArabic ? 'مواقيت الصلاة' : 'Prayer Times',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.gold,
                        fontFamily: isArabic ? 'Amiri' : null,
                        fontSize: 36,
                      ),
                ),
                const SizedBox(width: 16),
                if (state.cityName.isNotEmpty)
                  Text(
                    '— ${state.cityName}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Countdown
          _NextPrayerCard(state: state, isArabic: isArabic),
          const SizedBox(height: 24),
          // Prayer grid - 3 per row on TV
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: state.prayers.length,
              itemBuilder: (context, i) {
                return TVFocusableCard(
                  onTap: () {},
                  child: _PrayerCardContent(
                    prayer: state.prayers[i],
                    isArabic: isArabic,
                    use24h: settings.use24hClock,
                    isCompact: false,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Next prayer countdown card
class _NextPrayerCard extends ConsumerWidget {
  final PrayerTimesState state;
  final bool isArabic;

  const _NextPrayerCard({required this.state, required this.isArabic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdown = IslamicDateUtils.formatCountdown(state.timeToNextPrayer);
    final prayerName = isArabic
        ? state.nextPrayerNameAr
        : state.nextPrayerNameEn;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withOpacity(0.15),
            AppColors.gold.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
      ),
      child: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Row(
          children: [
            Icon(Icons.access_time, color: AppColors.gold, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'الصلاة القادمة' : 'Next Prayer',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  Text(
                    prayerName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.gold,
                          fontFamily: isArabic ? 'Amiri' : null,
                          fontSize: isArabic ? 22 : 18,
                        ),
                  ),
                ],
              ),
            ),
            // Countdown timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              ),
              child: Text(
                countdown,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.gold,
                      fontSize: 28,
                      letterSpacing: 3,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual prayer card
class _PrayerCard extends StatelessWidget {
  final PrayerTimeEntry prayer;
  final bool isArabic;
  final bool use24h;

  const _PrayerCard({
    required this.prayer,
    required this.isArabic,
    required this.use24h,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: prayer.isActive
            ? AppColors.gold.withOpacity(0.12)
            : prayer.isNext
                ? AppColors.emerald.withOpacity(0.08)
                : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: prayer.isActive
              ? AppColors.gold.withOpacity(0.5)
              : prayer.isNext
                  ? AppColors.emerald.withOpacity(0.4)
                  : AppColors.gold.withOpacity(0.1),
          width: prayer.isActive || prayer.isNext ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: _PrayerCardContent(
          prayer: prayer,
          isArabic: isArabic,
          use24h: use24h,
          isCompact: true,
        ),
      ),
    );
  }
}

class _PrayerCardContent extends StatelessWidget {
  final PrayerTimeEntry prayer;
  final bool isArabic;
  final bool use24h;
  final bool isCompact;

  const _PrayerCardContent({
    required this.prayer,
    required this.isArabic,
    required this.use24h,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = IslamicDateUtils.formatTime(prayer.time, use24h: use24h);
    final nameColor = prayer.isActive
        ? AppColors.gold
        : prayer.isNext
            ? AppColors.emerald
            : AppColors.textPrimary;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Row(
        children: [
          // Prayer icon / status indicator
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: prayer.isActive
                  ? AppColors.gold.withOpacity(0.15)
                  : prayer.isNext
                      ? AppColors.emerald.withOpacity(0.12)
                      : AppColors.surfaceLighter,
              border: Border.all(
                color: prayer.isActive
                    ? AppColors.gold.withOpacity(0.4)
                    : prayer.isNext
                        ? AppColors.emerald.withOpacity(0.35)
                        : Colors.transparent,
              ),
            ),
            child: Icon(
              _getPrayerIcon(prayer.index),
              color: nameColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isArabic ? prayer.nameAr : prayer.nameEn,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: nameColor,
                        fontFamily: isArabic ? 'Amiri' : null,
                        fontSize: isArabic ? 18 : null,
                      ),
                ),
                if (prayer.isActive)
                  Text(
                    isArabic ? 'الآن' : 'Now',
                    style: TextStyle(
                      color: AppColors.gold.withOpacity(0.7),
                      fontSize: 11,
                      fontFamily: isArabic ? 'Amiri' : null,
                    ),
                  )
                else if (prayer.isNext)
                  Text(
                    isArabic ? 'التالية' : 'Next',
                    style: TextStyle(
                      color: AppColors.emerald.withOpacity(0.7),
                      fontSize: 11,
                      fontFamily: isArabic ? 'Amiri' : null,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            timeStr,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: nameColor,
                  fontSize: 22,
                  letterSpacing: 2,
                ),
          ),
        ],
      ),
    );
  }

  IconData _getPrayerIcon(PrayerIndex index) {
    switch (index) {
      case PrayerIndex.fajr:
        return Icons.wb_twilight;
      case PrayerIndex.sunrise:
        return Icons.wb_sunny_outlined;
      case PrayerIndex.dhuhr:
        return Icons.light_mode;
      case PrayerIndex.asr:
        return Icons.wb_cloudy_outlined;
      case PrayerIndex.maghrib:
        return Icons.nights_stay;
      case PrayerIndex.isha:
        return Icons.nightlight_round;
    }
  }
}
