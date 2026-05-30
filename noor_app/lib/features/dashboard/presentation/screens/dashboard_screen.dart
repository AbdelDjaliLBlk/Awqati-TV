// lib/features/dashboard/presentation/screens/dashboard_screen.dart
// Main dashboard - fullscreen TV display + phone home

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/islamic_background.dart';
import '../../../../core/widgets/tv_focus_widget.dart';
import '../../../prayer/presentation/providers/prayer_provider.dart';
import '../../../prayer/data/models/prayer_models.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../quran/data/models/quran_models.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late Timer _clockTimer;
  DateTime _now = DateTime.now();
  int _currentVerseIndex = 0;
  late Timer _verseTimer;

  // Featured Quran verses for rotation
  static const List<Map<String, String>> _featuredVerses = [
    {'ar': 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا', 'ref': 'الطلاق: ٢', 'en': 'And whoever fears Allah — He will make for him a way out.', 'refEn': 'At-Talaq 65:2'},
    {'ar': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا', 'ref': 'الشرح: ٦', 'en': 'Indeed, with hardship will be ease.', 'refEn': 'Ash-Sharh 94:6'},
    {'ar': 'وَلَا تَيْأَسُوا مِن رَّوْحِ اللَّهِ', 'ref': 'يوسف: ٨٧', 'en': 'And despair not of relief from Allah.', 'refEn': 'Yusuf 12:87'},
    {'ar': 'إِنَّ اللَّهَ مَعَ الصَّابِرِينَ', 'ref': 'البقرة: ١٥٣', 'en': 'Indeed, Allah is with the patient.', 'refEn': 'Al-Baqarah 2:153'},
    {'ar': 'فَاذْكُرُونِي أَذْكُرْكُمْ', 'ref': 'البقرة: ١٥٢', 'en': 'So remember Me; I will remember you.', 'refEn': 'Al-Baqarah 2:152'},
  ];

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _verseTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        setState(() {
          _currentVerseIndex = (_currentVerseIndex + 1) % _featuredVerses.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _verseTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final prayerState = ref.watch(prayerProvider);
    final isArabic = settings.isArabic;
    final isTV = Breakpoints.isTV(context);

    if (isTV) {
      return _TVDashboard(
        now: _now,
        settings: settings,
        prayerState: prayerState,
        verseIndex: _currentVerseIndex,
        verses: _featuredVerses,
      );
    }

    return _PhoneDashboard(
      now: _now,
      settings: settings,
      prayerState: prayerState,
      verseIndex: _currentVerseIndex,
      verses: _featuredVerses,
    );
  }
}

// ─────────────────────── TV DASHBOARD ───────────────────────

class _TVDashboard extends StatelessWidget {
  final DateTime now;
  final AppSettings settings;
  final PrayerTimesState prayerState;
  final int verseIndex;
  final List<Map<String, String>> verses;

  const _TVDashboard({
    required this.now,
    required this.settings,
    required this.prayerState,
    required this.verseIndex,
    required this.verses,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isArabic = settings.isArabic;
    final hPad = size.width * 0.05;
    final vPad = size.height * 0.06;

    return IslamicBackground(
      animate: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          child: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Column(
              children: [
                // TOP ROW: Clock + Date
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Big Clock
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Time
                          Text(
                            IslamicDateUtils.formatTimeWithSeconds(now),
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: size.width * 0.08,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 6,
                                  fontWeight: FontWeight.w300,
                                ),
                          ),
                          const SizedBox(height: 8),
                          // Gregorian date
                          Text(
                            IslamicDateUtils.getGregorianDate(now, arabic: isArabic),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontFamily: isArabic ? 'Amiri' : null,
                                ),
                          ),
                          // Hijri date
                          Text(
                            IslamicDateUtils.getHijriDate(now, arabic: true),
                            style: TextStyle(
                              color: AppColors.gold.withOpacity(0.8),
                              fontSize: 16,
                              fontFamily: 'Amiri',
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),

                    // Next prayer countdown
                    if (!prayerState.isLoading)
                      Expanded(
                        flex: 2,
                        child: _TVCountdownWidget(
                          prayerState: prayerState,
                          isArabic: isArabic,
                        ),
                      ),

                    // City name
                    if (prayerState.cityName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, color: AppColors.gold, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              prayerState.cityName,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 20),
                IslamicDivider(),
                const SizedBox(height: 20),

                // MIDDLE: Prayer times row
                if (!prayerState.isLoading && prayerState.prayers.isNotEmpty)
                  _TVPrayerRow(prayers: prayerState.prayers, isArabic: isArabic, settings: settings),

                const Spacer(),

                // BOTTOM: Rotating Quran verse
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: _TVVerseWidget(
                    key: ValueKey(verseIndex),
                    verse: verses[verseIndex],
                    isArabic: isArabic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TVCountdownWidget extends StatelessWidget {
  final PrayerTimesState prayerState;
  final bool isArabic;

  const _TVCountdownWidget({required this.prayerState, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final countdown = IslamicDateUtils.formatCountdown(prayerState.timeToNextPrayer);
    final name = isArabic ? prayerState.nextPrayerNameAr : prayerState.nextPrayerNameEn;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            isArabic ? 'باقي على $name' : 'Until $name',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontFamily: isArabic ? 'Amiri' : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            countdown,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.gold,
                  fontSize: 32,
                  letterSpacing: 4,
                ),
          ),
        ],
      ),
    );
  }
}

class _TVPrayerRow extends StatelessWidget {
  final List<PrayerTimeEntry> prayers;
  final bool isArabic;
  final AppSettings settings;

  const _TVPrayerRow({
    required this.prayers,
    required this.isArabic,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: prayers.map((prayer) {
        final timeStr = IslamicDateUtils.formatTime(prayer.time, use24h: settings.use24hClock);
        final isActive = prayer.isActive;
        final isNext = prayer.isNext;

        return Expanded(
          child: TVFocusableCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            backgroundColor: isActive
                ? AppColors.gold.withOpacity(0.12)
                : AppColors.surface.withOpacity(0.7),
            child: Column(
              children: [
                Text(
                  isArabic ? prayer.nameAr : prayer.nameEn,
                  style: TextStyle(
                    color: isActive ? AppColors.gold : isNext ? AppColors.emerald : AppColors.textSecondary,
                    fontSize: isArabic ? 17 : 13,
                    fontFamily: isArabic ? 'Amiri' : null,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  ),
                  textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                ),
                const SizedBox(height: 6),
                Text(
                  timeStr,
                  style: TextStyle(
                    color: isActive ? AppColors.gold : AppColors.textPrimary,
                    fontSize: 20,
                    letterSpacing: 2,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w300,
                  ),
                ),
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TVVerseWidget extends StatelessWidget {
  final Map<String, String> verse;
  final bool isArabic;

  const _TVVerseWidget({super.key, required this.verse, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            verse['ar']!,
            style: ArabicTextStyles.quranText(fontSize: 28, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Text(
            isArabic ? verse['ref']! : verse['refEn']!,
            style: TextStyle(
              color: AppColors.gold.withOpacity(0.6),
              fontSize: 13,
              fontFamily: isArabic ? 'Amiri' : null,
            ),
          ),
          if (!isArabic && verse['en'] != null) ...[
            const SizedBox(height: 6),
            Text(
              verse['en']!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────── PHONE DASHBOARD ───────────────────────

class _PhoneDashboard extends StatelessWidget {
  final DateTime now;
  final AppSettings settings;
  final PrayerTimesState prayerState;
  final int verseIndex;
  final List<Map<String, String>> verses;

  const _PhoneDashboard({
    required this.now,
    required this.settings,
    required this.prayerState,
    required this.verseIndex,
    required this.verses,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = settings.isArabic;

    return IslamicBackground(
      animate: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Directionality(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Greeting
                  Text(
                    _getGreeting(isArabic),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontFamily: isArabic ? 'Amiri' : null,
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 4),

                  // Big time
                  Text(
                    IslamicDateUtils.formatTimeWithSeconds(now),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 56,
                          color: AppColors.textPrimary,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w200,
                        ),
                  ).animate().fadeIn(duration: 500.ms),

                  // Gregorian date
                  Text(
                    IslamicDateUtils.getGregorianDate(now, arabic: isArabic),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontFamily: isArabic ? 'Amiri' : null,
                    ),
                  ),

                  // Hijri date
                  Text(
                    IslamicDateUtils.getHijriDate(now, arabic: true),
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 14,
                      fontFamily: 'Amiri',
                    ),
                    textDirection: TextDirection.rtl,
                  ),

                  const SizedBox(height: 28),
                  IslamicDivider(),
                  const SizedBox(height: 24),

                  // Next prayer countdown
                  if (!prayerState.isLoading) ...[
                    _PhoneCountdown(state: prayerState, isArabic: isArabic, settings: settings)
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: 0.05),
                    const SizedBox(height: 20),
                  ],

                  // Top 3 prayers quick view
                  if (prayerState.prayers.isNotEmpty) ...[
                    _PhoneQuickPrayers(prayers: prayerState.prayers, isArabic: isArabic, settings: settings)
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 400.ms),
                    const SizedBox(height: 24),
                  ],

                  // Verse of the day
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    child: _PhoneVerseCard(
                      key: ValueKey(verseIndex),
                      verse: verses[verseIndex],
                      isArabic: isArabic,
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting(bool isArabic) {
    final hour = DateTime.now().hour;
    if (isArabic) {
      if (hour < 12) return 'صباح الخير';
      if (hour < 17) return 'مساء الخير';
      return 'مساء النور';
    } else {
      if (hour < 12) return 'Good Morning';
      if (hour < 17) return 'Good Afternoon';
      return 'Good Evening';
    }
  }
}

class _PhoneCountdown extends StatelessWidget {
  final PrayerTimesState state;
  final bool isArabic;
  final AppSettings settings;

  const _PhoneCountdown({required this.state, required this.isArabic, required this.settings});

  @override
  Widget build(BuildContext context) {
    final countdown = IslamicDateUtils.formatCountdown(state.timeToNextPrayer);
    final name = isArabic ? state.nextPrayerNameAr : state.nextPrayerNameEn;
    final nextPrayer = state.nextPrayerIndex < state.prayers.length
        ? state.prayers[state.nextPrayerIndex]
        : null;
    final timeStr = nextPrayer != null
        ? IslamicDateUtils.formatTime(nextPrayer.time, use24h: settings.use24hClock)
        : '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gold.withOpacity(0.12), AppColors.gold.withOpacity(0.04)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_rounded, color: AppColors.gold, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'الصلاة القادمة: $name' : 'Next: $name',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontFamily: isArabic ? 'Amiri' : null,
                  ),
                ),
                Text(
                  timeStr,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            countdown,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.gold,
                  fontSize: 26,
                  letterSpacing: 3,
                ),
          ),
        ],
      ),
    );
  }
}

class _PhoneQuickPrayers extends StatelessWidget {
  final List<PrayerTimeEntry> prayers;
  final bool isArabic;
  final AppSettings settings;

  const _PhoneQuickPrayers({required this.prayers, required this.isArabic, required this.settings});

  @override
  Widget build(BuildContext context) {
    final relevant = prayers.where((p) => p.index != PrayerIndex.sunrise).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isArabic ? 'مواقيت الصلاة' : 'Prayer Times',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 10),
        Row(
          children: relevant.take(5).map((p) {
            final time = IslamicDateUtils.formatTime(p.time, use24h: settings.use24hClock);
            final isActive = p.isActive;
            final isNext = p.isNext;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.gold.withOpacity(0.12)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? AppColors.gold.withOpacity(0.4)
                        : isNext
                            ? AppColors.emerald.withOpacity(0.3)
                            : Colors.transparent,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      isArabic ? p.nameAr : p.nameEn,
                      style: TextStyle(
                        color: isActive ? AppColors.gold : AppColors.textMuted,
                        fontSize: isArabic ? 11 : 10,
                        fontFamily: isArabic ? 'Amiri' : null,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: TextStyle(
                        color: isActive ? AppColors.gold : AppColors.textPrimary,
                        fontSize: 12,
                        letterSpacing: 1,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PhoneVerseCard extends StatelessWidget {
  final Map<String, String> verse;
  final bool isArabic;

  const _PhoneVerseCard({super.key, required this.verse, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_outlined, color: AppColors.gold, size: 16),
              const SizedBox(width: 8),
              Text(
                isArabic ? 'آية اليوم' : 'Verse of the Day',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.gold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            verse['ar']!,
            style: ArabicTextStyles.arabicUI(fontSize: 20, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          if (!isArabic)
            Text(
              verse['en']!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 6),
          Text(
            isArabic ? verse['ref']! : verse['refEn']!,
            style: TextStyle(
              color: AppColors.gold.withOpacity(0.6),
              fontSize: 11,
              fontFamily: isArabic ? 'Amiri' : null,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
