// lib/features/prayer/data/models/prayer_models.dart
// Prayer time data models


enum PrayerIndex {
  fajr(0),
  sunrise(1),
  dhuhr(2),
  asr(3),
  maghrib(4),
  isha(5);

  final int value;
  const PrayerIndex(this.value);
}

class PrayerTimeEntry {
  final String nameEn;
  final String nameAr;
  final DateTime time;
  final PrayerIndex index;
  final bool isActive;
  final bool isNext;

  const PrayerTimeEntry({
    required this.nameEn,
    required this.nameAr,
    required this.time,
    required this.index,
    this.isActive = false,
    this.isNext = false,
  });

  PrayerTimeEntry copyWith({bool? isActive, bool? isNext}) {
    return PrayerTimeEntry(
      nameEn: nameEn,
      nameAr: nameAr,
      time: time,
      index: index,
      isActive: isActive ?? this.isActive,
      isNext: isNext ?? this.isNext,
    );
  }
}

class PrayerTimesState {
  final List<PrayerTimeEntry> prayers;
  final int currentPrayerIndex;
  final int nextPrayerIndex;
  final Duration timeToNextPrayer;
  final bool isLoading;
  final String? error;
  final double latitude;
  final double longitude;
  final String cityName;

  const PrayerTimesState({
    this.prayers = const [],
    this.currentPrayerIndex = -1,
    this.nextPrayerIndex = 0,
    this.timeToNextPrayer = Duration.zero,
    this.isLoading = true,
    this.error,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.cityName = '',
  });

  PrayerTimesState copyWith({
    List<PrayerTimeEntry>? prayers,
    int? currentPrayerIndex,
    int? nextPrayerIndex,
    Duration? timeToNextPrayer,
    bool? isLoading,
    String? error,
    double? latitude,
    double? longitude,
    String? cityName,
  }) {
    return PrayerTimesState(
      prayers: prayers ?? this.prayers,
      currentPrayerIndex: currentPrayerIndex ?? this.currentPrayerIndex,
      nextPrayerIndex: nextPrayerIndex ?? this.nextPrayerIndex,
      timeToNextPrayer: timeToNextPrayer ?? this.timeToNextPrayer,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityName: cityName ?? this.cityName,
    );
  }

  String get nextPrayerNameEn =>
      nextPrayerIndex < prayers.length ? prayers[nextPrayerIndex].nameEn : '';

  String get nextPrayerNameAr =>
      nextPrayerIndex < prayers.length ? prayers[nextPrayerIndex].nameAr : '';
}
