// lib/features/quran/data/models/quran_models.dart
// Quran data models

class Surah {
  final int number;
  final String nameAr;
  final String nameEn;
  final String nameTransliteration;
  final int totalAyahs;
  final String revelationType; // 'Meccan' or 'Medinan'
  final int juzStart;

  const Surah({
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.nameTransliteration,
    required this.totalAyahs,
    required this.revelationType,
    required this.juzStart,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      nameAr: json['name'] as String,
      nameEn: json['englishName'] as String,
      nameTransliteration: json['englishNameTranslation'] as String? ?? '',
      totalAyahs: json['numberOfAyahs'] as int,
      revelationType: json['revelationType'] as String? ?? '',
      juzStart: json['juzStart'] as int? ?? 1,
    );
  }
}

class Ayah {
  final int number; // Global ayah number
  final int numberInSurah;
  final String text; // Arabic text
  final String? translation; // Optional translation
  final int surahNumber;
  final int juz;
  final int page;
  final bool isSajda;

  const Ayah({
    required this.number,
    required this.numberInSurah,
    required this.text,
    this.translation,
    required this.surahNumber,
    required this.juz,
    required this.page,
    this.isSajda = false,
  });

  factory Ayah.fromJson(Map<String, dynamic> json, {String? translationText}) {
    return Ayah(
      number: json['number'] as int,
      numberInSurah: json['numberInSurah'] as int,
      text: json['text'] as String,
      translation: translationText,
      surahNumber: (json['surah'] as Map<String, dynamic>?)?['number'] as int? ?? 0,
      juz: json['juz'] as int? ?? 0,
      page: json['page'] as int? ?? 0,
      isSajda: json['sajda'] is bool ? json['sajda'] as bool : false,
    );
  }
}

class SurahContent {
  final Surah surah;
  final List<Ayah> ayahs;
  final bool hasTranslation;

  const SurahContent({
    required this.surah,
    required this.ayahs,
    this.hasTranslation = false,
  });
}

class QuranState {
  final List<Surah> surahs;
  final bool isLoadingSurahs;
  final String? surahsError;
  final SurahContent? currentSurahContent;
  final bool isLoadingContent;
  final String? contentError;
  final int? playingAyahNumber;
  final bool isPlayingAudio;

  const QuranState({
    this.surahs = const [],
    this.isLoadingSurahs = true,
    this.surahsError,
    this.currentSurahContent,
    this.isLoadingContent = false,
    this.contentError,
    this.playingAyahNumber,
    this.isPlayingAudio = false,
  });

  QuranState copyWith({
    List<Surah>? surahs,
    bool? isLoadingSurahs,
    String? surahsError,
    SurahContent? currentSurahContent,
    bool? isLoadingContent,
    String? contentError,
    int? playingAyahNumber,
    bool? isPlayingAudio,
  }) {
    return QuranState(
      surahs: surahs ?? this.surahs,
      isLoadingSurahs: isLoadingSurahs ?? this.isLoadingSurahs,
      surahsError: surahsError,
      currentSurahContent: currentSurahContent ?? this.currentSurahContent,
      isLoadingContent: isLoadingContent ?? this.isLoadingContent,
      contentError: contentError,
      playingAyahNumber: playingAyahNumber ?? this.playingAyahNumber,
      isPlayingAudio: isPlayingAudio ?? this.isPlayingAudio,
    );
  }
}

/// Embedded Surah list (first 10 for demo, full list in production)
class QuranData {
  static const List<Map<String, dynamic>> surahs = [
    {'number': 1, 'name': 'الفَاتِحَة', 'englishName': 'Al-Fatihah', 'englishNameTranslation': 'The Opening', 'numberOfAyahs': 7, 'revelationType': 'Meccan'},
    {'number': 2, 'name': 'البَقَرَة', 'englishName': 'Al-Baqarah', 'englishNameTranslation': 'The Cow', 'numberOfAyahs': 286, 'revelationType': 'Medinan'},
    {'number': 3, 'name': 'آل عِمرَان', 'englishName': 'Ali Imran', 'englishNameTranslation': 'Family of Imran', 'numberOfAyahs': 200, 'revelationType': 'Medinan'},
    {'number': 4, 'name': 'النِّسَاء', 'englishName': 'An-Nisa', 'englishNameTranslation': 'The Women', 'numberOfAyahs': 176, 'revelationType': 'Medinan'},
    {'number': 5, 'name': 'المَائِدَة', 'englishName': 'Al-Maidah', 'englishNameTranslation': 'The Table Spread', 'numberOfAyahs': 120, 'revelationType': 'Medinan'},
    {'number': 6, 'name': 'الأَنعَام', 'englishName': 'Al-Anam', 'englishNameTranslation': 'The Cattle', 'numberOfAyahs': 165, 'revelationType': 'Meccan'},
    {'number': 7, 'name': 'الأَعرَاف', 'englishName': 'Al-Araf', 'englishNameTranslation': 'The Heights', 'numberOfAyahs': 206, 'revelationType': 'Meccan'},
    {'number': 8, 'name': 'الأَنفَال', 'englishName': 'Al-Anfal', 'englishNameTranslation': 'The Spoils of War', 'numberOfAyahs': 75, 'revelationType': 'Medinan'},
    {'number': 9, 'name': 'التَّوبَة', 'englishName': 'At-Tawbah', 'englishNameTranslation': 'The Repentance', 'numberOfAyahs': 129, 'revelationType': 'Medinan'},
    {'number': 10, 'name': 'يُونُس', 'englishName': 'Yunus', 'englishNameTranslation': 'Jonah', 'numberOfAyahs': 109, 'revelationType': 'Meccan'},
    {'number': 11, 'name': 'هُود', 'englishName': 'Hud', 'englishNameTranslation': 'Hud', 'numberOfAyahs': 123, 'revelationType': 'Meccan'},
    {'number': 12, 'name': 'يُوسُف', 'englishName': 'Yusuf', 'englishNameTranslation': 'Joseph', 'numberOfAyahs': 111, 'revelationType': 'Meccan'},
    {'number': 13, 'name': 'الرَّعد', 'englishName': 'Ar-Rad', 'englishNameTranslation': 'The Thunder', 'numberOfAyahs': 43, 'revelationType': 'Medinan'},
    {'number': 14, 'name': 'إِبرَاهِيم', 'englishName': 'Ibrahim', 'englishNameTranslation': 'Abraham', 'numberOfAyahs': 52, 'revelationType': 'Meccan'},
    {'number': 15, 'name': 'الحِجر', 'englishName': 'Al-Hijr', 'englishNameTranslation': 'The Rocky Tract', 'numberOfAyahs': 99, 'revelationType': 'Meccan'},
    {'number': 36, 'name': 'يس', 'englishName': 'Ya-Sin', 'englishNameTranslation': 'Ya Sin', 'numberOfAyahs': 83, 'revelationType': 'Meccan'},
    {'number': 55, 'name': 'الرَّحمَن', 'englishName': 'Ar-Rahman', 'englishNameTranslation': 'The Beneficent', 'numberOfAyahs': 78, 'revelationType': 'Medinan'},
    {'number': 56, 'name': 'الوَاقِعَة', 'englishName': 'Al-Waqiah', 'englishNameTranslation': 'The Event', 'numberOfAyahs': 96, 'revelationType': 'Meccan'},
    {'number': 67, 'name': 'المُلك', 'englishName': 'Al-Mulk', 'englishNameTranslation': 'The Sovereignty', 'numberOfAyahs': 30, 'revelationType': 'Meccan'},
    {'number': 112, 'name': 'الإِخلَاص', 'englishName': 'Al-Ikhlas', 'englishNameTranslation': 'Sincerity', 'numberOfAyahs': 4, 'revelationType': 'Meccan'},
    {'number': 113, 'name': 'الفَلَق', 'englishName': 'Al-Falaq', 'englishNameTranslation': 'The Daybreak', 'numberOfAyahs': 5, 'revelationType': 'Meccan'},
    {'number': 114, 'name': 'النَّاس', 'englishName': 'An-Nas', 'englishNameTranslation': 'Mankind', 'numberOfAyahs': 6, 'revelationType': 'Meccan'},
  ];

  /// Al-Fatiha ayahs for offline use
  static const List<Map<String, dynamic>> fatihaAyahs = [
    {'number': 1, 'numberInSurah': 1, 'text': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', 'translation': 'In the name of Allah, the Entirely Merciful, the Especially Merciful.'},
    {'number': 2, 'numberInSurah': 2, 'text': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ', 'translation': '[All] praise is [due] to Allah, Lord of the worlds —'},
    {'number': 3, 'numberInSurah': 3, 'text': 'الرَّحْمَٰنِ الرَّحِيمِ', 'translation': 'The Entirely Merciful, the Especially Merciful,'},
    {'number': 4, 'numberInSurah': 4, 'text': 'مَالِكِ يَوْمِ الدِّينِ', 'translation': 'Sovereign of the Day of Recompense.'},
    {'number': 5, 'numberInSurah': 5, 'text': 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ', 'translation': 'It is You we worship and You we ask for help.'},
    {'number': 6, 'numberInSurah': 6, 'text': 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ', 'translation': 'Guide us to the straight path —'},
    {'number': 7, 'numberInSurah': 7, 'text': 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ', 'translation': 'The path of those upon whom You have bestowed favor, not of those who have earned [Your] anger or of those who are astray.'},
  ];
}
