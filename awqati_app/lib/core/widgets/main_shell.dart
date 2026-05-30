// lib/core/widgets/main_shell.dart
// Adaptive shell: bottom nav for phones, side rail for TV

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../utils/platform_utils.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(
      path: '/',
      label: 'Dashboard',
      labelAr: 'الرئيسية',
      icon: Icons.mosque_outlined,
      selectedIcon: Icons.mosque,
    ),
    _NavItem(
      path: '/prayer',
      label: 'Prayer',
      labelAr: 'الصلاة',
      icon: Icons.access_time_outlined,
      selectedIcon: Icons.access_time,
    ),
    _NavItem(
      path: '/quran',
      label: 'Quran',
      labelAr: 'القرآن',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
    ),
    _NavItem(
      path: '/azkar',
      label: 'Azkar',
      labelAr: 'الأذكار',
      icon: Icons.spa_outlined,
      selectedIcon: Icons.spa,
    ),
    _NavItem(
      path: '/settings',
      label: 'Settings',
      labelAr: 'الإعدادات',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    context.go(_navItems[index].path);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.toString();
    final idx = _navItems.indexWhere((item) => item.path == location || location.startsWith(item.path) && item.path != '/');
    if (idx != -1 && idx != _selectedIndex) {
      setState(() => _selectedIndex = idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isArabic = settings.language == 'ar';
    final isTV = Breakpoints.isTV(context);

    if (isTV) {
      return _TVLayout(
        navItems: _navItems,
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        isArabic: isArabic,
        child: widget.child,
      );
    }

    return _PhoneLayout(
      navItems: _navItems,
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      isArabic: isArabic,
      child: widget.child,
    );
  }
}

/// TV Layout with side navigation rail
class _TVLayout extends StatelessWidget {
  final List<_NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final bool isArabic;
  final Widget child;

  const _TVLayout({
    required this.navItems,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.isArabic,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Row(
        children: [
          // Side navigation rail
          Container(
            width: 80,
            color: AppColors.midnight,
            child: Column(
              children: [
                const SizedBox(height: 32),
                // App logo/icon
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    Icons.star,
                    color: AppColors.gold,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                ...navItems.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final isSelected = selectedIndex == i;
                  return _TVNavItem(
                    item: item,
                    isSelected: isSelected,
                    isArabic: isArabic,
                    onTap: () => onItemTapped(i),
                  );
                }),
                const Spacer(),
                const SizedBox(height: 32),
              ],
            ),
          ),
          // Content
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _TVNavItem extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final bool isArabic;
  final VoidCallback onTap;

  const _TVNavItem({
    required this.item,
    required this.isSelected,
    required this.isArabic,
    required this.onTap,
  });

  @override
  State<_TVNavItem> createState() => _TVNavItemState();
}

class _TVNavItemState extends State<_TVNavItem> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected || _hasFocus
        ? AppColors.gold
        : AppColors.textMuted;

    return Focus(
      onFocusChange: (hasFocus) => setState(() => _hasFocus = hasFocus),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.isSelected
                ? AppColors.gold.withOpacity(0.15)
                : _hasFocus
                    ? AppColors.surfaceLighter
                    : Colors.transparent,
            border: _hasFocus
                ? Border.all(color: AppColors.gold, width: 2)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isSelected ? widget.item.selectedIcon : widget.item.icon,
                color: color,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Phone Layout with bottom navigation bar
class _PhoneLayout extends StatelessWidget {
  final List<_NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final bool isArabic;
  final Widget child;

  const _PhoneLayout({
    required this.navItems,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.isArabic,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        extendBody: true,
        body: child,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.midnight : Colors.white,
            border: Border(
              top: BorderSide(
                color: AppColors.gold.withOpacity(0.2),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 62,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: navItems.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final isSelected = selectedIndex == i;
                  return _PhoneNavItem(
                    item: item,
                    isSelected: isSelected,
                    isArabic: isArabic,
                    onTap: () => onItemTapped(i),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneNavItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final bool isArabic;
  final VoidCallback onTap;

  const _PhoneNavItem({
    required this.item,
    required this.isSelected,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.gold : AppColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? item.selectedIcon : item.icon,
                key: ValueKey(isSelected),
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isArabic ? item.labelAr : item.label,
              style: TextStyle(
                fontFamily: isArabic ? 'Amiri' : null,
                fontSize: isArabic ? 10 : 10,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String path;
  final String label;
  final String labelAr;
  final IconData icon;
  final IconData selectedIcon;

  const _NavItem({
    required this.path,
    required this.label,
    required this.labelAr,
    required this.icon,
    required this.selectedIcon,
  });
}
