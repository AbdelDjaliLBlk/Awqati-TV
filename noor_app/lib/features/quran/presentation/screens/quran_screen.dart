// lib/features/quran/presentation/screens/quran_screen.dart
// Quran main screen with surah list

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/islamic_background.dart';
import '../../../../core/widgets/tv_focus_widget.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/quran_provider.dart';
import '../../data/models/quran_models.dart';

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quranState = ref.watch(quranProvider);
    final settings = ref.watch(settingsProvider);
    final isArabic = settings.isArabic;
    final isTV = Breakpoints.isTV(context);
    final lastSurah = settings.lastQuranSurah;

    final filteredSurahs = _searchQuery.isEmpty
        ? quranState.surahs
        : quranState.surahs.where((s) {
            final q = _searchQuery.toLowerCase();
            return s.nameEn.toLowerCase().contains(q) ||
                s.nameAr.contains(q) ||
                s.number.toString() == q;
          }).toList();

    return IslamicBackground(
      animate: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTV ? MediaQuery.of(context).size.width * 0.04 : 0,
              vertical: isTV ? MediaQuery.of(context).size.height * 0.04 : 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, isArabic, lastSurah, settings),
                const SizedBox(height: 16),
                _buildSearchBar(context, isArabic),
                const SizedBox(height: 16),
                if (quranState.isLoadingSurahs)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    ),
                  )
                else
                  Expanded(
                    child: _buildSurahList(context, filteredSurahs, isArabic, isTV),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, bool isArabic, int lastSurah, AppSettings settings) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'القرآن الكريم' : 'The Holy Quran',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.gold,
                          fontFamily: isArabic ? 'Amiri' : null,
                          fontSize: isArabic ? 28 : null,
                        ),
                  ),
                  Text(
                    isArabic ? '١١٤ سورة' : '114 Surahs',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontFamily: isArabic ? 'Amiri' : null,
                        ),
                  ),
                ],
              ),
            ),
            // Resume button
            if (lastSurah > 0)
              TextButton.icon(
                onPressed: () => context.push('/quran/surah/$lastSurah'),
                icon: const Icon(Icons.bookmark, size: 16),
                label: Text(
                  isArabic ? 'استكمال' : 'Resume',
                  style: TextStyle(fontFamily: isArabic ? 'Amiri' : null),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.gold,
                  backgroundColor: AppColors.gold.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: isArabic ? 'ابحث عن سورة...' : 'Search surah...',
          hintStyle: TextStyle(
            color: AppColors.textMuted,
            fontFamily: isArabic ? 'Amiri' : null,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.gold.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.gold.withOpacity(0.15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.gold.withOpacity(0.5)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSurahList(
    BuildContext context,
    List<Surah> surahs,
    bool isArabic,
    bool isTV,
  ) {
    if (isTV) {
      return GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 2.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: surahs.length,
        itemBuilder: (context, i) {
          return TVFocusableCard(
            onTap: () => _openSurah(context, surahs[i].number),
            child: _SurahListItem(surah: surahs[i], isArabic: isArabic, isCompact: true),
          ).animate(delay: (i * 20).ms).fadeIn(duration: 200.ms);
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: surahs.length,
      itemBuilder: (context, i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => _openSurah(context, surahs[i].number),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.gold.withOpacity(0.1),
                ),
              ),
              child: _SurahListItem(surah: surahs[i], isArabic: isArabic, isCompact: false),
            ),
          ).animate(delay: (i * 15).ms).fadeIn(duration: 200.ms),
        );
      },
    );
  }

  void _openSurah(BuildContext context, int surahNumber) {
    ref.read(settingsProvider.notifier).setLastQuranPosition(surahNumber, 1);
    context.push('/quran/surah/$surahNumber');
  }
}

class _SurahListItem extends StatelessWidget {
  final Surah surah;
  final bool isArabic;
  final bool isCompact;

  const _SurahListItem({
    required this.surah,
    required this.isArabic,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Row(
          children: [
            // Surah number badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                color: AppColors.gold.withOpacity(0.07),
              ),
              child: Center(
                child: Text(
                  surah.number.toString(),
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isArabic ? surah.nameAr : surah.nameEn,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isArabic ? 16 : 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: isArabic ? 'Amiri' : null,
                    ),
                  ),
                  if (!isCompact) ...[
                    Text(
                      '${surah.revelationType} • ${surah.totalAyahs} Ayahs',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              isArabic ? surah.nameEn : surah.nameAr,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: isArabic ? 13 : 18,
                fontFamily: isArabic ? null : 'ScheherazadeNew',
              ),
              textDirection: isArabic ? TextDirection.ltr : TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}
