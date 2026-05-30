// lib/features/settings/presentation/providers/settings_provider.dart
// Global settings state management with Riverpod + Hive persistence

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';

/// Immutable settings model
class AppSettings {
  final String language; // 'en' or 'ar'
  final String themeMode; // 'dark', 'light', 'system'
  final String calculationMethod; // 'MuslimWorldLeague', 'UmmAlQura', 'Egyptian', 'ISNA'
  final String madhab; // 'Shafi', 'Hanafi'
  final String athanSound; // 'mecca', 'madinah', 'egypt', etc.
  final double athanVolume; // 0.0 - 1.0
  final bool isSilentMode;
  final double fontSize; // 1.0 = default
  final String background; // 'geometric', 'stars', 'mosque'
  final double lastLat;
  final double lastLng;
  final String lastCity;
  final bool showTranslation;
  final int lastQuranSurah;
  final int lastQuranAyah;
  final bool use24hClock;

  const AppSettings({
    this.language = 'en',
    this.themeMode = 'dark',
    this.calculationMethod = 'MuslimWorldLeague',
    this.madhab = 'Shafi',
    this.athanSound = 'mecca',
    this.athanVolume = 0.8,
    this.isSilentMode = false,
    this.fontSize = 1.0,
    this.background = 'geometric',
    this.lastLat = 0.0,
    this.lastLng = 0.0,
    this.lastCity = '',
    this.showTranslation = false,
    this.lastQuranSurah = 1,
    this.lastQuranAyah = 1,
    this.use24hClock = true,
  });

  AppSettings copyWith({
    String? language,
    String? themeMode,
    String? calculationMethod,
    String? madhab,
    String? athanSound,
    double? athanVolume,
    bool? isSilentMode,
    double? fontSize,
    String? background,
    double? lastLat,
    double? lastLng,
    String? lastCity,
    bool? showTranslation,
    int? lastQuranSurah,
    int? lastQuranAyah,
    bool? use24hClock,
  }) {
    return AppSettings(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      athanSound: athanSound ?? this.athanSound,
      athanVolume: athanVolume ?? this.athanVolume,
      isSilentMode: isSilentMode ?? this.isSilentMode,
      fontSize: fontSize ?? this.fontSize,
      background: background ?? this.background,
      lastLat: lastLat ?? this.lastLat,
      lastLng: lastLng ?? this.lastLng,
      lastCity: lastCity ?? this.lastCity,
      showTranslation: showTranslation ?? this.showTranslation,
      lastQuranSurah: lastQuranSurah ?? this.lastQuranSurah,
      lastQuranAyah: lastQuranAyah ?? this.lastQuranAyah,
      use24hClock: use24hClock ?? this.use24hClock,
    );
  }

  bool get isArabic => language == 'ar';
  bool get isDark => themeMode == 'dark';
}

/// Settings notifier with Hive persistence
class SettingsNotifier extends StateNotifier<AppSettings> {
  late Box _box;

  SettingsNotifier() : super(const AppSettings()) {
    _loadFromHive();
  }

  Future<void> _loadFromHive() async {
    _box = await Hive.openBox(AppConstants.settingsBox);
    state = AppSettings(
      language: _box.get(AppConstants.keyLanguage, defaultValue: 'en'),
      themeMode: _box.get(AppConstants.keyThemeMode, defaultValue: 'dark'),
      calculationMethod: _box.get(AppConstants.keyCalculationMethod, defaultValue: 'MuslimWorldLeague'),
      madhab: _box.get(AppConstants.keyMadhab, defaultValue: 'Shafi'),
      athanSound: _box.get(AppConstants.keyAthanSound, defaultValue: 'mecca'),
      athanVolume: _box.get(AppConstants.keyAthanVolume, defaultValue: 0.8),
      isSilentMode: _box.get(AppConstants.keyIsSilentMode, defaultValue: false),
      fontSize: _box.get(AppConstants.keyFontSize, defaultValue: 1.0),
      background: _box.get(AppConstants.keyBackground, defaultValue: 'geometric'),
      lastLat: _box.get(AppConstants.keyLastLat, defaultValue: 0.0),
      lastLng: _box.get(AppConstants.keyLastLng, defaultValue: 0.0),
      lastCity: _box.get(AppConstants.keyLastCity, defaultValue: ''),
      showTranslation: _box.get(AppConstants.keyShowTranslation, defaultValue: false),
      lastQuranSurah: _box.get(AppConstants.keyLastQuranSurah, defaultValue: 1),
      lastQuranAyah: _box.get(AppConstants.keyLastQuranAyah, defaultValue: 1),
      use24hClock: _box.get('use24hClock', defaultValue: true),
    );
  }

  Future<void> _save(AppSettings settings) async {
    await _box.put(AppConstants.keyLanguage, settings.language);
    await _box.put(AppConstants.keyThemeMode, settings.themeMode);
    await _box.put(AppConstants.keyCalculationMethod, settings.calculationMethod);
    await _box.put(AppConstants.keyMadhab, settings.madhab);
    await _box.put(AppConstants.keyAthanSound, settings.athanSound);
    await _box.put(AppConstants.keyAthanVolume, settings.athanVolume);
    await _box.put(AppConstants.keyIsSilentMode, settings.isSilentMode);
    await _box.put(AppConstants.keyFontSize, settings.fontSize);
    await _box.put(AppConstants.keyBackground, settings.background);
    await _box.put(AppConstants.keyLastLat, settings.lastLat);
    await _box.put(AppConstants.keyLastLng, settings.lastLng);
    await _box.put(AppConstants.keyLastCity, settings.lastCity);
    await _box.put(AppConstants.keyShowTranslation, settings.showTranslation);
    await _box.put(AppConstants.keyLastQuranSurah, settings.lastQuranSurah);
    await _box.put(AppConstants.keyLastQuranAyah, settings.lastQuranAyah);
    await _box.put('use24hClock', settings.use24hClock);
  }

  void setLanguage(String lang) {
    final newState = state.copyWith(language: lang);
    state = newState;
    _save(newState);
  }

  void setThemeMode(String mode) {
    final newState = state.copyWith(themeMode: mode);
    state = newState;
    _save(newState);
  }

  void setCalculationMethod(String method) {
    final newState = state.copyWith(calculationMethod: method);
    state = newState;
    _save(newState);
  }

  void setMadhab(String madhab) {
    final newState = state.copyWith(madhab: madhab);
    state = newState;
    _save(newState);
  }

  void setAthanSound(String sound) {
    final newState = state.copyWith(athanSound: sound);
    state = newState;
    _save(newState);
  }

  void setAthanVolume(double volume) {
    final newState = state.copyWith(athanVolume: volume);
    state = newState;
    _save(newState);
  }

  void setSilentMode(bool silent) {
    final newState = state.copyWith(isSilentMode: silent);
    state = newState;
    _save(newState);
  }

  void setFontSize(double size) {
    final newState = state.copyWith(fontSize: size);
    state = newState;
    _save(newState);
  }

  void setBackground(String bg) {
    final newState = state.copyWith(background: bg);
    state = newState;
    _save(newState);
  }

  void setLocation(double lat, double lng, String city) {
    final newState = state.copyWith(lastLat: lat, lastLng: lng, lastCity: city);
    state = newState;
    _save(newState);
  }

  void setShowTranslation(bool show) {
    final newState = state.copyWith(showTranslation: show);
    state = newState;
    _save(newState);
  }

  void setLastQuranPosition(int surah, int ayah) {
    final newState = state.copyWith(lastQuranSurah: surah, lastQuranAyah: ayah);
    state = newState;
    _save(newState);
  }

  void setUse24hClock(bool use24h) {
    final newState = state.copyWith(use24hClock: use24h);
    state = newState;
    _save(newState);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);
