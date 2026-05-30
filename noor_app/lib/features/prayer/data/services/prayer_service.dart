// lib/features/prayer/data/services/prayer_service.dart
// Prayer time calculation using the adhan package

import 'package:adhan/adhan.dart';
import '../models/prayer_models.dart';

class PrayerService {
  /// Get prayer times for a given date and location
  static PrayerTimes getPrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    required String calculationMethod,
    required String madhab,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final dateComponents = DateComponents.from(date);
    final params = _getCalculationParameters(calculationMethod, madhab);

    return PrayerTimes.today(coordinates, params);
  }

  /// Convert adhan PrayerTimes to our model list
  static List<PrayerTimeEntry> toPrayerEntries(PrayerTimes times) {
    return [
      PrayerTimeEntry(
        nameEn: 'Fajr',
        nameAr: 'الفجر',
        time: times.fajr,
        index: PrayerIndex.fajr,
      ),
      PrayerTimeEntry(
        nameEn: 'Sunrise',
        nameAr: 'الشروق',
        time: times.sunrise,
        index: PrayerIndex.sunrise,
      ),
      PrayerTimeEntry(
        nameEn: 'Dhuhr',
        nameAr: 'الظهر',
        time: times.dhuhr,
        index: PrayerIndex.dhuhr,
      ),
      PrayerTimeEntry(
        nameEn: 'Asr',
        nameAr: 'العصر',
        time: times.asr,
        index: PrayerIndex.asr,
      ),
      PrayerTimeEntry(
        nameEn: 'Maghrib',
        nameAr: 'المغرب',
        time: times.maghrib,
        index: PrayerIndex.maghrib,
      ),
      PrayerTimeEntry(
        nameEn: 'Isha',
        nameAr: 'العشاء',
        time: times.isha,
        index: PrayerIndex.isha,
      ),
    ];
  }

  /// Determine current and next prayer from the list
  static ({int currentIndex, int nextIndex}) getCurrentAndNextPrayer(
    List<PrayerTimeEntry> entries,
    DateTime now,
  ) {
    int currentIndex = -1;
    int nextIndex = 0;

    // Find which prayer window we're in
    for (int i = 0; i < entries.length; i++) {
      if (now.isAfter(entries[i].time)) {
        // Skip sunrise (index 1) — it's not a prayer time for athan
        if (entries[i].index != PrayerIndex.sunrise) {
          currentIndex = i;
        }
      }
    }

    // Next prayer
    if (currentIndex == entries.length - 1) {
      // After Isha, next is Fajr tomorrow
      nextIndex = 0;
    } else {
      nextIndex = currentIndex + 1;
      // Skip sunrise for "next prayer" countdown
      if (nextIndex == 1) nextIndex = 2;
    }

    return (currentIndex: currentIndex, nextIndex: nextIndex);
  }

  /// Get duration until next prayer
  static Duration getTimeToNextPrayer(
    List<PrayerTimeEntry> entries,
    int nextIndex,
    DateTime now,
  ) {
    if (entries.isEmpty) return Duration.zero;

    DateTime nextPrayerTime;
    if (nextIndex < entries.length && entries[nextIndex].time.isAfter(now)) {
      nextPrayerTime = entries[nextIndex].time;
    } else {
      // Next is tomorrow's Fajr - approximate
      nextPrayerTime = entries[0].time.add(const Duration(days: 1));
    }

    final diff = nextPrayerTime.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  static CalculationParameters _getCalculationParameters(
    String method,
    String madhab,
  ) {
    CalculationParameters params;

    switch (method) {
      case 'UmmAlQura':
        params = CalculationMethod.umm_al_qura.getParameters();
        break;
      case 'Egyptian':
        params = CalculationMethod.egyptian.getParameters();
        break;
      case 'ISNA':
        params = CalculationMethod.north_america.getParameters();
        break;
      case 'Karachi':
        params = CalculationMethod.karachi.getParameters();
        break;
      case 'MuslimWorldLeague':
      default:
        params = CalculationMethod.muslim_world_league.getParameters();
        break;
    }

    // Set madhab for Asr calculation
    params.madhab = madhab == 'Hanafi' ? Madhab.hanafi : Madhab.shafi;

    return params;
  }
}
