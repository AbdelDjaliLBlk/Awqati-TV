// lib/features/quran/presentation/providers/quran_provider.dart
// Quran data fetching and state management

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../data/models/quran_models.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class QuranNotifier extends StateNotifier<QuranState> {
  final Ref _ref;

  QuranNotifier(this._ref) : super(const QuranState()) {
    _loadSurahs();
  }

  void _loadSurahs() {
    // Load from embedded data first (works offline)
    final surahs = QuranData.surahs.map((json) {
      return Surah(
        number: json['number'] as int,
        nameAr: json['name'] as String,
        nameEn: json['englishName'] as String,
        nameTransliteration: json['englishNameTranslation'] as String? ?? '',
        totalAyahs: json['numberOfAyahs'] as int,
        revelationType: json['revelationType'] as String? ?? '',
        juzStart: 1,
      );
    }).toList();

    state = state.copyWith(surahs: surahs, isLoadingSurahs: false);

    // Then try to load full list from API
    _loadSurahsFromApi();
  }

  Future<void> _loadSurahsFromApi() async {
    try {
      final response = await http
          .get(Uri.parse('${AppConstants.quranApiBase}/surah'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final surahsList = (data['data'] as List).map((json) {
          return Surah(
            number: json['number'] as int,
            nameAr: json['name'] as String,
            nameEn: json['englishName'] as String,
            nameTransliteration: json['englishNameTranslation'] as String? ?? '',
            totalAyahs: json['numberOfAyahs'] as int,
            revelationType: json['revelationType'] as String? ?? '',
            juzStart: 1,
          );
        }).toList();

        state = state.copyWith(surahs: surahsList, isLoadingSurahs: false);
      }
    } catch (_) {
      // Keep embedded surahs, network failed silently
    }
  }

  Future<void> loadSurah(int surahNumber, {bool withTranslation = false}) async {
    state = state.copyWith(isLoadingContent: true, contentError: null);

    // Use embedded Fatiha for offline
    if (surahNumber == 1) {
      final surah = state.surahs.firstWhere(
        (s) => s.number == 1,
        orElse: () => const Surah(
          number: 1,
          nameAr: 'الفَاتِحَة',
          nameEn: 'Al-Fatihah',
          nameTransliteration: 'The Opening',
          totalAyahs: 7,
          revelationType: 'Meccan',
          juzStart: 1,
        ),
      );

      final ayahs = QuranData.fatihaAyahs.map((json) {
        return Ayah(
          number: json['number'] as int,
          numberInSurah: json['numberInSurah'] as int,
          text: json['text'] as String,
          translation: json['translation'] as String?,
          surahNumber: 1,
          juz: 1,
          page: 1,
        );
      }).toList();

      state = state.copyWith(
        currentSurahContent: SurahContent(
          surah: surah,
          ayahs: ayahs,
          hasTranslation: true,
        ),
        isLoadingContent: false,
      );
      return;
    }

    try {
      // Fetch Arabic text
      final arabicResponse = await http
          .get(Uri.parse('${AppConstants.quranApiBase}/surah/$surahNumber'))
          .timeout(const Duration(seconds: 15));

      if (arabicResponse.statusCode != 200) throw Exception('Failed to load surah');

      final arabicData = json.decode(arabicResponse.body) as Map<String, dynamic>;
      final surahData = arabicData['data'] as Map<String, dynamic>;

      final surah = Surah(
        number: surahData['number'] as int,
        nameAr: surahData['name'] as String,
        nameEn: surahData['englishName'] as String,
        nameTransliteration: surahData['englishNameTranslation'] as String? ?? '',
        totalAyahs: surahData['numberOfAyahs'] as int,
        revelationType: surahData['revelationType'] as String? ?? '',
        juzStart: 1,
      );

      List<String>? translations;
      if (withTranslation) {
        try {
          final transResponse = await http
              .get(Uri.parse(
                  '${AppConstants.quranApiBase}/surah/$surahNumber/en.sahih'))
              .timeout(const Duration(seconds: 15));

          if (transResponse.statusCode == 200) {
            final transData = json.decode(transResponse.body) as Map<String, dynamic>;
            final transAyahs = (transData['data']['ayahs'] as List);
            translations = transAyahs
                .map((a) => a['text'] as String)
                .toList();
          }
        } catch (_) {}
      }

      final ayahsData = surahData['ayahs'] as List;
      final ayahs = ayahsData.asMap().entries.map((entry) {
        final json = entry.value as Map<String, dynamic>;
        return Ayah(
          number: json['number'] as int,
          numberInSurah: json['numberInSurah'] as int,
          text: json['text'] as String,
          translation: translations?[entry.key],
          surahNumber: surahNumber,
          juz: json['juz'] as int? ?? 0,
          page: json['page'] as int? ?? 0,
          isSajda: json['sajda'] is bool ? json['sajda'] as bool : false,
        );
      }).toList();

      state = state.copyWith(
        currentSurahContent: SurahContent(
          surah: surah,
          ayahs: ayahs,
          hasTranslation: translations != null,
        ),
        isLoadingContent: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingContent: false,
        contentError: e.toString(),
      );
    }
  }

  void setPlayingAyah(int? ayahNumber) {
    state = state.copyWith(
      playingAyahNumber: ayahNumber,
      isPlayingAudio: ayahNumber != null,
    );
  }
}

final quranProvider = StateNotifierProvider<QuranNotifier, QuranState>(
  (ref) => QuranNotifier(ref),
);
