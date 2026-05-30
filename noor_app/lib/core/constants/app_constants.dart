// lib/core/constants/app_constants.dart
// Central constants for the Noor application

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Noor';
  static const String appNameAr = 'نور';
  static const String appVersion = '1.0.0';

  // Hive Box Names
  static const String settingsBox = 'settings_box';
  static const String prayerBox = 'prayer_box';
  static const String quranBox = 'quran_box';
  static const String azkarBox = 'azkar_box';

  // Settings Keys
  static const String keyCalculationMethod = 'calculation_method';
  static const String keyMadhab = 'madhab';
  static const String keyAthanSound = 'athan_sound';
  static const String keyLanguage = 'language';
  static const String keyThemeMode = 'theme_mode';
  static const String keyFontSize = 'font_size';
  static const String keyBackground = 'background';
  static const String keyIsSilentMode = 'is_silent_mode';
  static const String keyLastLat = 'last_lat';
  static const String keyLastLng = 'last_lng';
  static const String keyLastCity = 'last_city';
  static const String keyLastQuranSurah = 'last_quran_surah';
  static const String keyLastQuranAyah = 'last_quran_ayah';
  static const String keyShowTranslation = 'show_translation';
  static const String keyAthanVolume = 'athan_volume';

  // Prayer Names
  static const List<String> prayerNamesEn = [
    'Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'
  ];
  static const List<String> prayerNamesAr = [
    'الفجر', 'الشروق', 'الظهر', 'العصر', 'المغرب', 'العشاء'
  ];

  // Athan Sounds
  static const List<String> athanSounds = [
    'mecca', 'madinah', 'egypt', 'turkey', 'local'
  ];
  static const List<String> athanSoundsAr = [
    'مكة المكرمة', 'المدينة المنورة', 'مصر', 'تركيا', 'محلي'
  ];

  // Quran API
  static const String quranApiBase = 'https://api.alquran.cloud/v1';
  static const String quranAudioBase = 'https://cdn.islamic.network/quran/audio';

  // Islamic backgrounds
  static const List<String> backgroundOptions = [
    'kaaba', 'madinah', 'pattern1', 'pattern2', 'geometric', 'stars'
  ];

  // TV Safe Area
  static const double tvSafeZone = 0.05; // 5% from edges
  static const double tvFontScaleFactor = 1.4;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Prayer countdown refresh
  static const Duration clockRefresh = Duration(seconds: 1);

  // Dashboard verse rotation
  static const Duration verseRotationInterval = Duration(seconds: 15);

  // Athan duration (approximate max)
  static const Duration athanMaxDuration = Duration(minutes: 5);
}
