// lib/features/settings/presentation/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/islamic_background.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final isArabic = settings.isArabic;

    return IslamicBackground(
      animate: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            isArabic ? 'الإعدادات' : 'Settings',
            style: TextStyle(
              color: AppColors.gold,
              fontFamily: isArabic ? 'Amiri' : null,
              fontSize: isArabic ? 22 : 18,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          children: [
            _SectionTitle(title: isArabic ? 'المظهر' : 'Appearance', isArabic: isArabic),

            _SettingTile(
              title: isArabic ? 'اللغة' : 'Language',
              subtitle: settings.language == 'ar' ? 'العربية' : 'English',
              icon: Icons.language,
              onTap: () => _showPicker(
                context,
                title: isArabic ? 'اللغة' : 'Language',
                options: const ['en', 'ar'],
                labels: const ['English', 'العربية'],
                selected: settings.language,
                onSelect: notifier.setLanguage,
              ),
            ),

            _SettingTile(
              title: isArabic ? 'المظهر' : 'Theme',
              subtitle: _themeLabel(settings.themeMode, isArabic),
              icon: Icons.palette_outlined,
              onTap: () => _showPicker(
                context,
                title: isArabic ? 'المظهر' : 'Theme',
                options: const ['dark', 'light', 'system'],
                labels: isArabic
                    ? const ['داكن', 'فاتح', 'النظام']
                    : const ['Dark', 'Light', 'System'],
                selected: settings.themeMode,
                onSelect: notifier.setThemeMode,
              ),
            ),

            _SettingTile(
              title: isArabic ? 'حجم الخط' : 'Font Size',
              subtitle: _fontSizeLabel(settings.fontSize, isArabic),
              icon: Icons.text_fields,
              onTap: () => _showSliderDialog(
                context,
                title: isArabic ? 'حجم الخط' : 'Font Size',
                value: settings.fontSize,
                min: 0.8,
                max: 1.4,
                onChanged: notifier.setFontSize,
              ),
            ),

            _SectionTitle(title: isArabic ? 'أوقات الصلاة' : 'Prayer Times', isArabic: isArabic),

            _SettingTile(
              title: isArabic ? 'طريقة الحساب' : 'Calculation Method',
              subtitle: _methodLabel(settings.calculationMethod),
              icon: Icons.calculate_outlined,
              onTap: () => _showPicker(
                context,
                title: isArabic ? 'طريقة الحساب' : 'Calculation Method',
                options: const ['MuslimWorldLeague', 'UmmAlQura', 'Egyptian', 'ISNA', 'Karachi'],
                labels: const ['Muslim World League', 'Umm Al-Qura', 'Egyptian', 'ISNA (North America)', 'Karachi'],
                selected: settings.calculationMethod,
                onSelect: notifier.setCalculationMethod,
              ),
            ),

            _SettingTile(
              title: isArabic ? 'المذهب الفقهي' : 'Madhab (Asr)',
              subtitle: settings.madhab,
              icon: Icons.school_outlined,
              onTap: () => _showPicker(
                context,
                title: isArabic ? 'المذهب' : 'Madhab',
                options: const ['Shafi', 'Hanafi'],
                labels: isArabic
                    ? const ['شافعي / مالكي / حنبلي', 'حنفي']
                    : const ['Shafi / Maliki / Hanbali', 'Hanafi'],
                selected: settings.madhab,
                onSelect: notifier.setMadhab,
              ),
            ),

            _SettingTile(
              title: isArabic ? 'صيغة الوقت' : 'Time Format',
              subtitle: settings.use24hClock
                  ? (isArabic ? '٢٤ ساعة' : '24-hour')
                  : (isArabic ? '١٢ ساعة' : '12-hour'),
              icon: Icons.access_time_outlined,
              onTap: () => notifier.setUse24hClock(!settings.use24hClock),
            ),

            _SectionTitle(title: isArabic ? 'الأذان' : 'Athan', isArabic: isArabic),

            _SettingTile(
              title: isArabic ? 'صوت الأذان' : 'Athan Sound',
              subtitle: _athanLabel(settings.athanSound, isArabic),
              icon: Icons.music_note_outlined,
              onTap: () => _showPicker(
                context,
                title: isArabic ? 'صوت الأذان' : 'Athan Sound',
                options: const ['mecca', 'madinah', 'egypt', 'turkey'],
                labels: const ['Mecca', 'Madinah', 'Egypt', 'Turkey'],
                selected: settings.athanSound,
                onSelect: notifier.setAthanSound,
              ),
            ),

            _SettingTile(
              title: isArabic ? 'مستوى الصوت' : 'Volume',
              subtitle: '${(settings.athanVolume * 100).round()}%',
              icon: Icons.volume_up_outlined,
              onTap: () => _showSliderDialog(
                context,
                title: isArabic ? 'مستوى الصوت' : 'Volume',
                value: settings.athanVolume,
                min: 0.0,
                max: 1.0,
                onChanged: notifier.setAthanVolume,
              ),
            ),

            _SettingTileSwitch(
              title: isArabic ? 'الوضع الصامت' : 'Silent Mode',
              subtitle: isArabic ? 'إيقاف صوت الأذان' : 'Mute all athan sounds',
              icon: Icons.volume_off_outlined,
              value: settings.isSilentMode,
              onChanged: notifier.setSilentMode,
            ),

            _SectionTitle(title: isArabic ? 'القرآن' : 'Quran', isArabic: isArabic),

            _SettingTileSwitch(
              title: isArabic ? 'عرض الترجمة' : 'Show Translation',
              subtitle: isArabic ? 'ترجمة إنجليزية' : 'English translation (Sahih International)',
              icon: Icons.translate_outlined,
              value: settings.showTranslation,
              onChanged: notifier.setShowTranslation,
            ),

            const SizedBox(height: 20),

            // App version
            Center(
              child: Text(
                'Noor v1.0.0\nBuilt with ♥ for the Muslim Ummah',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _themeLabel(String mode, bool ar) {
    if (ar) return mode == 'dark' ? 'داكن' : mode == 'light' ? 'فاتح' : 'النظام';
    return mode == 'dark' ? 'Dark' : mode == 'light' ? 'Light' : 'System';
  }

  String _fontSizeLabel(double size, bool ar) {
    if (size <= 0.85) return ar ? 'صغير' : 'Small';
    if (size <= 1.05) return ar ? 'متوسط' : 'Medium';
    if (size <= 1.2) return ar ? 'كبير' : 'Large';
    return ar ? 'كبير جداً' : 'Extra Large';
  }

  String _methodLabel(String m) {
    const map = {
      'MuslimWorldLeague': 'Muslim World League',
      'UmmAlQura': 'Umm Al-Qura',
      'Egyptian': 'Egyptian',
      'ISNA': 'ISNA',
      'Karachi': 'Karachi',
    };
    return map[m] ?? m;
  }

  String _athanLabel(String s, bool ar) {
    const map = {'mecca': 'Mecca', 'madinah': 'Madinah', 'egypt': 'Egypt', 'turkey': 'Turkey'};
    return map[s] ?? s;
  }

  void _showPicker(
    BuildContext context, {
    required String title,
    required List<String> options,
    required List<String> labels,
    required String selected,
    required Function(String) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navyDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(title,
                style: const TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          ...options.asMap().entries.map((e) => ListTile(
                title: Text(labels[e.key],
                    style: TextStyle(
                        color: selected == e.value ? AppColors.gold : AppColors.textPrimary)),
                trailing: selected == e.value
                    ? const Icon(Icons.check, color: AppColors.gold, size: 18)
                    : null,
                onTap: () {
                  onSelect(e.value);
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showSliderDialog(
    BuildContext context, {
    required String title,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
    showDialog(
      context: context,
      builder: (_) => _SliderDialog(
        title: title,
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }
}

class _SliderDialog extends StatefulWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final Function(double) onChanged;

  const _SliderDialog({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<_SliderDialog> createState() => _SliderDialogState();
}

class _SliderDialogState extends State<_SliderDialog> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.navyDeep,
      title: Text(widget.title, style: const TextStyle(color: AppColors.gold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${(_value * 100).round()}%',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 24)),
          Slider(
            value: _value,
            min: widget.min,
            max: widget.max,
            activeColor: AppColors.gold,
            inactiveColor: AppColors.surfaceLighter,
            onChanged: (v) {
              setState(() => _value = v);
              widget.onChanged(v);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done', style: TextStyle(color: AppColors.gold)),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isArabic;
  const _SectionTitle({required this.title, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.gold,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          fontFamily: isArabic ? 'Amiri' : null,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.gold, size: 22),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _SettingTileSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final Function(bool) onChanged;

  const _SettingTileSwitch({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.gold, size: 22),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.gold,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
