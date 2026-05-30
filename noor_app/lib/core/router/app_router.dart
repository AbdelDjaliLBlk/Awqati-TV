// lib/core/router/app_router.dart
// GoRouter navigation configuration for Noor

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/prayer/presentation/screens/prayer_screen.dart';
import '../../features/quran/presentation/screens/quran_screen.dart';
import '../../features/quran/presentation/screens/surah_reader_screen.dart';
import '../../features/azkar/presentation/screens/azkar_screen.dart';
import '../../features/azkar/presentation/screens/azkar_detail_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/athan/presentation/screens/athan_screen.dart';
import '../widgets/main_shell.dart';

// Route paths
class AppRoutes {
  static const String dashboard = '/';
  static const String prayer = '/prayer';
  static const String quran = '/quran';
  static const String surahReader = '/quran/surah/:surahNumber';
  static const String azkar = '/azkar';
  static const String azkarDetail = '/azkar/:category';
  static const String settings = '/settings';
  static const String athan = '/athan'; // Fullscreen athan overlay
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: false,
    routes: [
      // Main shell with bottom nav / TV side nav
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.prayer,
            name: 'prayer',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PrayerScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.quran,
            name: 'quran',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QuranScreen(),
            ),
            routes: [
              GoRoute(
                path: 'surah/:surahNumber',
                name: 'surahReader',
                pageBuilder: (context, state) {
                  final surahNumber = int.tryParse(
                    state.pathParameters['surahNumber'] ?? '1',
                  ) ?? 1;
                  final startAyah = int.tryParse(
                    state.uri.queryParameters['ayah'] ?? '1',
                  ) ?? 1;
                  return CustomTransitionPage(
                    child: SurahReaderScreen(
                      surahNumber: surahNumber,
                      startAyah: startAyah,
                    ),
                    transitionsBuilder: (context, animation, secondary, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.azkar,
            name: 'azkar',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AzkarScreen(),
            ),
            routes: [
              GoRoute(
                path: ':category',
                name: 'azkarDetail',
                pageBuilder: (context, state) {
                  final category = state.pathParameters['category'] ?? 'morning';
                  return CustomTransitionPage(
                    child: AzkarDetailScreen(category: category),
                    transitionsBuilder: (context, animation, secondary, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
      // Fullscreen Athan - no shell
      GoRoute(
        path: AppRoutes.athan,
        name: 'athan',
        pageBuilder: (context, state) {
          final prayerName = state.uri.queryParameters['prayer'] ?? '';
          return CustomTransitionPage(
            fullscreenDialog: true,
            child: AthanScreen(prayerName: prayerName),
            transitionsBuilder: (context, animation, secondary, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
});
