// lib/features/azkar/data/models/azkar_models.dart
// Azkar data models and embedded content

class ZikrEntry {
  final String textAr;
  final String? textEn;
  final String? transliteration;
  final int count; // How many times to repeat
  final String? virtue; // Virtue/reward text
  int currentCount;

  ZikrEntry({
    required this.textAr,
    this.textEn,
    this.transliteration,
    required this.count,
    this.virtue,
    int? currentCount,
  }) : currentCount = currentCount ?? count;

  void reset() => currentCount = count;
  void decrement() {
    if (currentCount > 0) currentCount--;
  }

  bool get isDone => currentCount == 0;

  ZikrEntry copyWith({int? currentCount}) => ZikrEntry(
        textAr: textAr,
        textEn: textEn,
        transliteration: transliteration,
        count: count,
        virtue: virtue,
        currentCount: currentCount ?? this.currentCount,
      );
}

class AzkarCategory {
  final String id;
  final String nameAr;
  final String nameEn;
  final String icon;
  final List<ZikrEntry> azkar;

  const AzkarCategory({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.icon,
    required this.azkar,
  });
}

class AzkarData {
  static final List<AzkarCategory> categories = [
    AzkarCategory(
      id: 'morning',
      nameAr: 'أذكار الصباح',
      nameEn: 'Morning Azkar',
      icon: '🌅',
      azkar: _morningAzkar,
    ),
    AzkarCategory(
      id: 'evening',
      nameAr: 'أذكار المساء',
      nameEn: 'Evening Azkar',
      icon: '🌙',
      azkar: _eveningAzkar,
    ),
    AzkarCategory(
      id: 'sleep',
      nameAr: 'أذكار النوم',
      nameEn: 'Sleep Azkar',
      icon: '😴',
      azkar: _sleepAzkar,
    ),
    AzkarCategory(
      id: 'after_prayer',
      nameAr: 'أذكار بعد الصلاة',
      nameEn: 'After Prayer',
      icon: '🤲',
      azkar: _afterPrayerAzkar,
    ),
  ];

  static final List<ZikrEntry> _morningAzkar = [
    ZikrEntry(
      textAr: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
      textEn: 'We have reached the morning and at this very time unto Allah belongs all sovereignty, and all praise is for Allah.',
      count: 1,
      virtue: 'يقال عند الصباح',
    ),
    ZikrEntry(
      textAr: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
      textEn: 'O Allah, by Your leave we have reached the morning and by Your leave we have reached the evening.',
      count: 1,
    ),
    ZikrEntry(
      textAr: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      textEn: 'Glory is to Allah and praise is to Him.',
      transliteration: 'Subhana Allahi wa bihamdihi',
      count: 100,
      virtue: 'مَنْ قَالَهَا مِئَةَ مَرَّةٍ حُطَّتْ خَطَايَاهُ',
    ),
    ZikrEntry(
      textAr: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      textEn: 'None has the right to be worshipped except Allah, alone, without partner.',
      count: 10,
      virtue: 'قراءتها 10 مرات صباحاً تعدل عتق 4 أنفس من ولد إسماعيل',
    ),
    ZikrEntry(
      textAr: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ',
      textEn: 'O Allah, You are my Lord, none has the right to be worshipped except You.',
      count: 1,
      virtue: 'سيد الاستغفار',
    ),
    ZikrEntry(
      textAr: 'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي',
      textEn: 'O Allah, grant my body health. O Allah, grant my hearing health. O Allah, grant my sight health.',
      count: 3,
    ),
  ];

  static final List<ZikrEntry> _eveningAzkar = [
    ZikrEntry(
      textAr: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
      textEn: 'We have reached the evening and at this very time unto Allah belongs all sovereignty.',
      count: 1,
    ),
    ZikrEntry(
      textAr: 'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
      textEn: 'O Allah, by Your leave we have reached the evening and by Your leave we have reached the morning.',
      count: 1,
    ),
    ZikrEntry(
      textAr: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      textEn: 'I take refuge in the perfect words of Allah from the evil of what He has created.',
      count: 3,
      virtue: 'لَمْ يَضُرَّهُ حُمَةٌ حَتَّى يُصْبِحَ',
    ),
    ZikrEntry(
      textAr: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      textEn: 'Glory is to Allah and praise is to Him.',
      count: 100,
    ),
  ];

  static final List<ZikrEntry> _sleepAzkar = [
    ZikrEntry(
      textAr: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      textEn: 'In Your name O Allah, I die and I live.',
      count: 1,
    ),
    ZikrEntry(
      textAr: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
      textEn: 'O Allah, protect me from Your punishment on the day Your servants are resurrected.',
      count: 3,
    ),
    ZikrEntry(
      textAr: 'سُبْحَانَ اللَّهِ',
      textEn: 'Glory is to Allah.',
      count: 33,
    ),
    ZikrEntry(
      textAr: 'الْحَمْدُ لِلَّهِ',
      textEn: 'All praise is to Allah.',
      count: 33,
    ),
    ZikrEntry(
      textAr: 'اللَّهُ أَكْبَرُ',
      textEn: 'Allah is the greatest.',
      count: 34,
      virtue: 'خيرٌ لك من خادم',
    ),
  ];

  static final List<ZikrEntry> _afterPrayerAzkar = [
    ZikrEntry(
      textAr: 'أَسْتَغْفِرُ اللَّهَ',
      textEn: 'I seek the forgiveness of Allah.',
      count: 3,
    ),
    ZikrEntry(
      textAr: 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
      textEn: 'O Allah, You are Peace and from You comes peace. Blessed are You, O Owner of majesty and honor.',
      count: 1,
    ),
    ZikrEntry(
      textAr: 'سُبْحَانَ اللَّهِ',
      textEn: 'Glory is to Allah.',
      count: 33,
    ),
    ZikrEntry(
      textAr: 'الْحَمْدُ لِلَّهِ',
      textEn: 'All praise is to Allah.',
      count: 33,
    ),
    ZikrEntry(
      textAr: 'اللَّهُ أَكْبَرُ',
      textEn: 'Allah is the greatest.',
      count: 33,
    ),
    ZikrEntry(
      textAr: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      textEn: 'None has the right to be worshipped except Allah, alone, without partner. To Him belongs all sovereignty and praise and He is over all things omnipotent.',
      count: 1,
      virtue: 'غُفِرَتْ لَهُ خَطَايَاهُ وَإِنْ كَانَتْ مِثْلَ زَبَدِ الْبَحْرِ',
    ),
  ];

  static const List<Map<String, String>> dailyHadiths = [
    {
      'text': 'إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى',
      'narrator': 'رواه البخاري ومسلم',
      'textEn': 'Actions are judged by intentions, and every person will get the reward according to what they intended.',
      'narratorEn': 'Reported by Al-Bukhari and Muslim',
    },
    {
      'text': 'الطهور شطر الإيمان، والحمد لله تملأ الميزان',
      'narrator': 'رواه مسلم',
      'textEn': 'Cleanliness is half of faith and Alhamdulillah fills the scale.',
      'narratorEn': 'Reported by Muslim',
    },
    {
      'text': 'خير الناس أنفعهم للناس',
      'narrator': 'رواه الطبراني',
      'textEn': 'The best of people are those who are most beneficial to people.',
      'narratorEn': 'Reported by Al-Tabarani',
    },
  ];
}
