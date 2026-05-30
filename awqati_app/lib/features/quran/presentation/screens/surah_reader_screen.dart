// lib/features/quran/presentation/screens/surah_reader_screen.dart
// Full Quran reader with Arabic text display and audio

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/islamic_background.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/quran_provider.dart';
import '../../data/models/quran_models.dart';

class SurahReaderScreen extends ConsumerStatefulWidget {
  final int surahNumber;
  final int startAyah;

  const SurahReaderScreen({
    super.key,
    required this.surahNumber,
    this.startAyah = 1,
  });

  @override
  ConsumerState<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends ConsumerState<SurahReaderScreen> {
  final _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _playingAyah;
  bool _isLoadingAudio = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    ref.read(quranProvider.notifier).loadSurah(
      widget.surahNumber,
      withTranslation: settings.showTranslation,
    );

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (mounted) setState(() => _playingAyah = null);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quranState = ref.watch(quranProvider);
    final settings = ref.watch(settingsProvider);
    final isArabic = settings.isArabic;
    final isTV = Breakpoints.isTV(context);
    final fontSize = settings.fontSize;

    return IslamicBackground(
      animate: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(context, quranState, isArabic, settings),
        body: quranState.isLoadingContent
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              )
            : quranState.contentError != null
                ? _buildError(context, quranState.contentError!, isArabic)
                : quranState.currentSurahContent == null
                    ? const SizedBox()
                    : _buildReader(
                        context,
                        quranState.currentSurahContent!,
                        isArabic,
                        isTV,
                        fontSize,
                        settings.showTranslation,
                      ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    QuranState state,
    bool isArabic,
    AppSettings settings,
  ) {
    final surah = state.currentSurahContent?.surah;
    return AppBar(
      backgroundColor: AppColors.midnight.withOpacity(0.95),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: surah != null
          ? Column(
              children: [
                Text(
                  isArabic ? surah.nameAr : surah.nameEn,
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: isArabic ? 20 : 16,
                    fontFamily: isArabic ? 'Amiri' : null,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${surah.totalAyahs} ${isArabic ? "آية" : "Ayahs"} • ${surah.revelationType}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            )
          : null,
      actions: [
        // Toggle translation
        IconButton(
          icon: Icon(
            settings.showTranslation ? Icons.translate : Icons.translate_outlined,
            color: settings.showTranslation ? AppColors.gold : AppColors.textMuted,
            size: 20,
          ),
          onPressed: () {
            ref.read(settingsProvider.notifier).setShowTranslation(
                  !settings.showTranslation,
                );
            if (state.currentSurahContent != null) {
              ref.read(quranProvider.notifier).loadSurah(
                    widget.surahNumber,
                    withTranslation: !settings.showTranslation,
                  );
            }
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildError(BuildContext context, String error, bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 64, color: AppColors.gold.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'تعذر تحميل السورة' : 'Failed to load surah',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontFamily: isArabic ? 'Amiri' : null,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic ? 'يرجى التحقق من الاتصال بالإنترنت' : 'Check your internet connection',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.read(quranProvider.notifier).loadSurah(widget.surahNumber),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildReader(
    BuildContext context,
    SurahContent content,
    bool isArabic,
    bool isTV,
    double fontScale,
    bool showTranslation,
  ) {
    final quranFontSize = (isTV ? 32.0 : 24.0) * fontScale;
    final transSize = (isTV ? 16.0 : 13.0) * fontScale;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Bismillah header
        if (content.surah.number != 9)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    style: ArabicTextStyles.quranText(
                      fontSize: quranFontSize * 0.9,
                      color: AppColors.gold,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 8),
                  const IslamicDividerSimple(),
                ],
              ),
            ),
          ),

        // Ayahs
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            isTV ? 80 : 20,
            8,
            isTV ? 80 : 20,
            120,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final ayah = content.ayahs[i];
                final isPlaying = _playingAyah == ayah.numberInSurah;
                return _AyahItem(
                  ayah: ayah,
                  isPlaying: isPlaying,
                  showTranslation: showTranslation && ayah.translation != null,
                  quranFontSize: quranFontSize,
                  transSize: transSize,
                  isArabic: isArabic,
                  onPlayTap: () => _toggleAyahAudio(ayah),
                ).animate(delay: (i * 30).ms).fadeIn(duration: 250.ms);
              },
              childCount: content.ayahs.length,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleAyahAudio(Ayah ayah) async {
    if (_playingAyah == ayah.numberInSurah) {
      await _audioPlayer.stop();
      setState(() => _playingAyah = null);
      return;
    }

    setState(() {
      _playingAyah = ayah.numberInSurah;
      _isLoadingAudio = true;
    });

    try {
      // alafasy recitation
      final url = '${AppConstants.quranAudioBase}/128/ar.alafasy/${ayah.number}.mp3';
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      setState(() => _playingAyah = null);
    } finally {
      if (mounted) setState(() => _isLoadingAudio = false);
    }
  }
}

class _AyahItem extends StatelessWidget {
  final Ayah ayah;
  final bool isPlaying;
  final bool showTranslation;
  final double quranFontSize;
  final double transSize;
  final bool isArabic;
  final VoidCallback onPlayTap;

  const _AyahItem({
    required this.ayah,
    required this.isPlaying,
    required this.showTranslation,
    required this.quranFontSize,
    required this.transSize,
    required this.isArabic,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isPlaying
            ? AppColors.gold.withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isPlaying
            ? Border.all(color: AppColors.gold.withOpacity(0.3))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ayah header - number + play button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Play button
                GestureDetector(
                  onTap: onPlayTap,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPlaying
                          ? AppColors.gold.withOpacity(0.2)
                          : AppColors.surfaceLighter,
                      border: Border.all(
                        color: isPlaying
                            ? AppColors.gold.withOpacity(0.5)
                            : Colors.transparent,
                      ),
                    ),
                    child: Icon(
                      isPlaying ? Icons.stop : Icons.play_arrow,
                      color: isPlaying ? AppColors.gold : AppColors.textMuted,
                      size: 18,
                    ),
                  ),
                ),

                // Ayah number badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.gold.withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      ayah.numberInSurah.toString(),
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Arabic text
            Text(
              ayah.text,
              style: ArabicTextStyles.quranText(
                fontSize: quranFontSize,
                color: isPlaying ? AppColors.gold : AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),

            // Translation
            if (showTranslation && ayah.translation != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLighter.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gold.withOpacity(0.1)),
                ),
                child: Text(
                  ayah.translation!,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: transSize,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ),
            ],

            const SizedBox(height: 8),
            Divider(color: AppColors.gold.withOpacity(0.08), height: 1),
          ],
        ),
      ),
    );
  }
}

class IslamicDividerSimple extends StatelessWidget {
  const IslamicDividerSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, AppColors.gold.withOpacity(0.3)],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(Icons.star, size: 8, color: AppColors.gold.withOpacity(0.5)),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gold.withOpacity(0.3), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Need to import AppConstants for Quran audio base
class AppConstants {
  static const String quranAudioBase = 'https://cdn.islamic.network/quran/audio';
}
