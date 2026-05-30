// lib/features/prayer/presentation/providers/prayer_provider.dart
// Prayer times state management with real-time updates

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../data/models/prayer_models.dart';
import '../../data/services/prayer_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class PrayerTimesNotifier extends StateNotifier<PrayerTimesState> {
  final Ref ref;
  Timer? _countdownTimer;
  Timer? _athanCheckTimer;

  // Callback when prayer time is reached (for Athan trigger)
  Function(String prayerNameEn, String prayerNameAr)? onPrayerTime;

  PrayerTimesNotifier(this.ref) : super(const PrayerTimesState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadLocation();
    _startCountdownTimer();
    _startAthanChecker();
  }

  Future<void> _loadLocation() async {
    state = state.copyWith(isLoading: true);
    final settings = ref.read(settingsProvider);

    // Try GPS first
    try {
      final permission = await Geolocator.checkPermission();
      LocationPermission finalPermission = permission;

      if (permission == LocationPermission.denied) {
        finalPermission = await Geolocator.requestPermission();
      }

      if (finalPermission == LocationPermission.whileInUse ||
          finalPermission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        );

        String cityName = '';
        try {
          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            cityName = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? '';
          }
        } catch (_) {}

        // Save location to settings
        ref.read(settingsProvider.notifier).setLocation(
          position.latitude,
          position.longitude,
          cityName,
        );

        _calculatePrayers(position.latitude, position.longitude, cityName);
        return;
      }
    } catch (e) {
      // Fall through to cached location
    }

    // Use cached location from settings
    if (settings.lastLat != 0.0 && settings.lastLng != 0.0) {
      _calculatePrayers(settings.lastLat, settings.lastLng, settings.lastCity);
    } else {
      // Default to Mecca if no location available
      _calculatePrayers(21.3891, 39.8579, 'Mecca');
    }
  }

  void _calculatePrayers(double lat, double lng, String cityName) {
    final settings = ref.read(settingsProvider);
    try {
      final prayerTimes = PrayerService.getPrayerTimes(
        latitude: lat,
        longitude: lng,
        date: DateTime.now(),
        calculationMethod: settings.calculationMethod,
        madhab: settings.madhab,
      );

      final entries = PrayerService.toPrayerEntries(prayerTimes);
      final now = DateTime.now();
      final result = PrayerService.getCurrentAndNextPrayer(entries, now);
      final timeToNext = PrayerService.getTimeToNextPrayer(
        entries, result.nextIndex, now,
      );

      // Mark current and next
      final markedEntries = entries.asMap().map((i, entry) {
        return MapEntry(
          i,
          entry.copyWith(
            isActive: i == result.currentIndex,
            isNext: i == result.nextIndex,
          ),
        );
      }).values.toList();

      state = PrayerTimesState(
        prayers: markedEntries,
        currentPrayerIndex: result.currentIndex,
        nextPrayerIndex: result.nextIndex,
        timeToNextPrayer: timeToNext,
        isLoading: false,
        latitude: lat,
        longitude: lng,
        cityName: cityName,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.prayers.isEmpty) return;

      final now = DateTime.now();
      final result = PrayerService.getCurrentAndNextPrayer(state.prayers, now);
      final timeToNext = PrayerService.getTimeToNextPrayer(
        state.prayers, result.nextIndex, now,
      );

      // Refresh prayers at midnight
      if (now.hour == 0 && now.minute == 0 && now.second == 0) {
        _calculatePrayers(state.latitude, state.longitude, state.cityName);
        return;
      }

      // Update state if prayer changed
      if (result.currentIndex != state.currentPrayerIndex ||
          result.nextIndex != state.nextPrayerIndex) {
        final markedEntries = state.prayers.asMap().map((i, entry) {
          return MapEntry(
            i,
            entry.copyWith(
              isActive: i == result.currentIndex,
              isNext: i == result.nextIndex,
            ),
          );
        }).values.toList();

        state = state.copyWith(
          prayers: markedEntries,
          currentPrayerIndex: result.currentIndex,
          nextPrayerIndex: result.nextIndex,
          timeToNextPrayer: timeToNext,
        );
      } else {
        state = state.copyWith(timeToNextPrayer: timeToNext);
      }
    });
  }

  void _startAthanChecker() {
    _athanCheckTimer?.cancel();
    // Check every 30 seconds if any prayer time was just hit
    _athanCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (state.prayers.isEmpty) return;
      final now = DateTime.now();

      for (final prayer in state.prayers) {
        // Skip sunrise
        if (prayer.index == PrayerIndex.sunrise) continue;

        final diff = now.difference(prayer.time).inSeconds.abs();
        if (diff < 30 && now.isAfter(prayer.time)) {
          onPrayerTime?.call(prayer.nameEn, prayer.nameAr);
          break;
        }
      }
    });
  }

  /// Force location refresh
  Future<void> refreshLocation() async {
    await _loadLocation();
  }

  /// Recalculate with new settings
  void recalculate() {
    if (state.latitude != 0.0) {
      _calculatePrayers(state.latitude, state.longitude, state.cityName);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _athanCheckTimer?.cancel();
    super.dispose();
  }
}

final prayerProvider = StateNotifierProvider<PrayerTimesNotifier, PrayerTimesState>(
  (ref) => PrayerTimesNotifier(ref),
);
