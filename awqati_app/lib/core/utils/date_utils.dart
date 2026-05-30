// lib/core/utils/date_utils.dart
// Utilities for Gregorian and Hijri date formatting

import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';

class IslamicDateUtils {
  IslamicDateUtils._();

  static final List<String> _hijriMonthsAr = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني',
    'جمادى الأولى', 'جمادى الثانية', 'رجب', 'شعبان',
    'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
  ];

  static final List<String> _hijriMonthsEn = [
    'Muharram', 'Safar', 'Rabi\' al-Awwal', 'Rabi\' al-Thani',
    'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Sha\'ban',
    'Ramadan', 'Shawwal', 'Dhu al-Qi\'dah', 'Dhu al-Hijjah',
  ];

  static final List<String> _weekdaysAr = [
    'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء',
    'الخميس', 'الجمعة', 'السبت',
  ];

  /// Get formatted Hijri date
  static String getHijriDate(DateTime gregorian, {bool arabic = true}) {
    final hijri = HijriCalendar.fromDate(gregorian);
    final day = hijri.hDay;
    final month = hijri.hMonth;
    final year = hijri.hYear;

    if (arabic) {
      return '$day ${_hijriMonthsAr[month - 1]} $year هـ';
    } else {
      return '$day ${_hijriMonthsEn[month - 1]} $year AH';
    }
  }

  /// Get formatted Gregorian date
  static String getGregorianDate(DateTime date, {bool arabic = false}) {
    if (arabic) {
      final weekday = _weekdaysAr[date.weekday % 7];
      final day = date.day;
      final monthNames = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
      ];
      final month = monthNames[date.month - 1];
      final year = date.year;
      return '$weekday، $day $month $year';
    } else {
      return DateFormat('EEEE, MMMM d, yyyy').format(date);
    }
  }

  /// Format time as HH:MM
  static String formatTime(DateTime time, {bool use24h = true}) {
    if (use24h) {
      return DateFormat('HH:mm').format(time);
    } else {
      return DateFormat('h:mm a').format(time);
    }
  }

  /// Format time with seconds
  static String formatTimeWithSeconds(DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }

  /// Format countdown duration
  static String formatCountdown(Duration duration) {
    if (duration.isNegative) return '00:00:00';
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Get Arabic numerals
  static String toArabicNumerals(String latin) {
    const latinDigits = '0123456789';
    const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
    var result = latin;
    for (int i = 0; i < latinDigits.length; i++) {
      result = result.replaceAll(latinDigits[i], arabicDigits[i]);
    }
    return result;
  }
}
