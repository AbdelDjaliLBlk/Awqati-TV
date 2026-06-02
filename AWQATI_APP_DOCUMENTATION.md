# Awqati-TV — Islamic Smart Display App
## Complete Architecture & Developer Documentation

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [App Architecture](#2-app-architecture)
3. [Folder Structure](#3-folder-structure)
4. [Core Layer](#4-core-layer)
5. [Features](#5-features)
6. [State Management](#6-state-management)
7. [Navigation](#7-navigation)
8. [Theme System](#8-theme-system)
9. [TV vs Phone Adaptation](#9-tv-vs-phone-adaptation)
10. [Prayer Times Engine](#10-prayer-times-engine)
11. [Athan System](#11-athan-system)
12. [Quran Module](#12-quran-module)
13. [Azkar Module](#13-azkar-module)
14. [Dashboard](#14-dashboard)
15. [Settings System](#15-settings-system)
16. [Local Storage](#16-local-storage)
17. [Build Instructions](#17-build-instructions)
18. [Dependencies](#18-dependencies)

---

## 1. Project Overview

**Noor** (Arabic: نور — meaning "Light") is a production-grade Flutter Islamic application inspired by Mawaqit TV. It runs on a **single codebase** across:

| Platform       | Status      | Notes                          |
|----------------|-------------|--------------------------------|
| Android Phone  | ✅ Full     | Portrait + landscape           |
| Android TV     | ✅ Full     | D-pad, remote, fullscreen UI   |
| Web            | ⚡ Optional | Same codebase, minor tweaks    |
| iOS            | 🔄 Ready    | Minor permission manifest work |

### Core Features

| Feature              | Description                                            |
|----------------------|--------------------------------------------------------|
| Live Clock           | Large digital clock with Gregorian + Hijri dates       |
| Prayer Times         | GPS-based with 5 calculation methods + offline caching |
| Athan System         | Auto-play with fullscreen overlay + multiple voices    |
| Quran Module         | Full Arabic text, translations, audio per-ayah         |
| Azkar Module         | Morning/Evening/Sleep/After-Prayer + tasbih counter    |
| TV Dashboard         | Fullscreen ambient display with verse rotation         |
| Settings             | Language, theme, athan, calculation method, font size  |

---

## 2. App Architecture

The app follows **Clean Architecture** with a **Feature-First folder structure**:

```
Presentation Layer   →   Riverpod StateNotifiers / Providers
Domain Layer         →   Entities, Use Cases (embedded in providers)
Data Layer           →   Services, Models, Repositories
```

### Design Patterns Used

- **StateNotifier + Provider** (Riverpod) for reactive state
- **GoRouter** for declarative, type-safe navigation
- **Repository Pattern** for data access (services abstract API/local)
- **Feature Modules** — each feature is fully self-contained
- **Adaptive Widgets** — single widget trees adapt to TV vs phone

---

## 3. Folder Structure

```
awqati_app/
├── lib/
│   ├── main.dart                       # Entry point
│   ├── core/                           # Shared infrastructure
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   ├── router/
│   │   │   └── app_router.dart         # GoRouter configuration
│   │   ├── theme/
│   │   │   └── app_theme.dart          # Light/Dark themes
│   │   ├── utils/
│   │   │   ├── date_utils.dart
│   │   │   └── platform_utils.dart     # TV vs Phone detection
│   │   └── widgets/
│   │       ├── islamic_background.dart
│   │       ├── main_shell.dart         # BottomNav/SideNav shell
│   │       └── tv_focus_widget.dart
│   └── features/                       # Feature-based modules
│       ├── athan/
│       │   ├── data/services/athan_service.dart
│       │   └── presentation/screens/athan_screen.dart
│       ├── azkar/
│       │   ├── data/models/azkar_models.dart
│       │   └── presentation/screens/
│       │       ├── azkar_screen.dart
│       │       └── azkar_detail_screen.dart
│       ├── dashboard/
│       │   └── presentation/screens/dashboard_screen.dart
│       ├── prayer/
│       │   ├── data/
│       │   │   ├── models/prayer_models.dart
│       │   │   └── services/prayer_service.dart
│       │   └── presentation/
│       │       ├── providers/prayer_provider.dart
│       │       └── screens/prayer_screen.dart
│       ├── quran/
│       │   ├── data/models/quran_models.dart
│       │   └── presentation/
│       │       ├── providers/quran_provider.dart
│       │       └── screens/
│       │           ├── quran_screen.dart
│       │           └── surah_reader_screen.dart
│       └── settings/
│           └── presentation/
│               ├── providers/settings_provider.dart
│               └── screens/settings_screen.dart
├── assets/                             # Images, Fonts, Audio, Quran data
├── pubspec.yaml                        # Dependencies & App Config
└── analysis_options.yaml               # Linting rules
---

## 4. Core Layer

### `app_constants.dart`
Central registry of all string keys, durations, and config values.  
Prevents magic strings throughout codebase.  
Key groups: Hive box names, settings keys, prayer names, API URLs, animation durations.

### `app_theme.dart`
Full Material 3 theming with Islamic aesthetic:

| Color Token     | Hex       | Usage                          |
|-----------------|-----------|--------------------------------|
| `gold`          | `#D4A843` | Primary accent, prayer active  |
| `emerald`       | `#2ECC71` | Next prayer indicator          |
| `deepNight`     | `#0A0E1A` | Background (dark)              |
| `surface`       | `#1A2035` | Card background                |
| `textPrimary`   | `#F5F0E8` | Main text (warm white)         |

**Font Families:**
- `Cinzel Decorative` — clock display
- `Cormorant Garamond` — section headlines
- `Josefin Sans` — UI labels, nav
- `Amiri` — Arabic UI text
- `Scheherazade New` — Quran Arabic text

### `platform_utils.dart`
Detects Android TV via `MethodChannel` with screen-size fallback.  
`Breakpoints` class provides `isPhone()`, `isTablet()`, `isTV()` helpers.

### `date_utils.dart`
Wraps `intl` and `hijri` packages:
- `getHijriDate()` — returns formatted Hijri date in Arabic or English
- `getGregorianDate()` — localized date string
- `formatCountdown()` — HH:MM:SS countdown display
- `toArabicNumerals()` — converts latin digits to Arabic-Indic

---

## 5. Features

### Feature Module Structure

Each feature follows this pattern:
```
feature_name/
├── data/
│   ├── models/      # Pure Dart data classes (no Flutter deps)
│   ├── services/    # API calls, local DB, platform services
│   └── repositories/ # (optional) abstraction layer
├── domain/
│   └── (embedded in providers for this scale)
└── presentation/
    ├── providers/   # Riverpod StateNotifiers
    ├── screens/     # Full page widgets
    └── widgets/     # Feature-specific reusable widgets
```

---

## 6. State Management

**Riverpod 2.x** with `StateNotifier` pattern.

### Key Providers

| Provider              | Type                          | Scope   |
|-----------------------|-------------------------------|---------|
| `settingsProvider`    | `StateNotifierProvider`       | Global  |
| `prayerProvider`      | `StateNotifierProvider`       | Global  |
| `athanProvider`       | `StateNotifierProvider`       | Global  |
| `quranProvider`       | `StateNotifierProvider`       | Global  |
| `goRouterProvider`    | `Provider<GoRouter>`          | Global  |

### Settings Flow
```
User changes setting
    ↓
settingsProvider.notifier.setSomething()
    ↓
State updated (immutable copyWith)
    ↓
Hive.put() persisted
    ↓
All watching widgets rebuild
```

### Prayer Time Flow
```
App start
    ↓
PrayerTimesNotifier._initialize()
    ↓
GPS permission request → Geolocator.getCurrentPosition()
    ↓  (fallback: last cached coords → fallback: Mecca)
PrayerService.getPrayerTimes(lat, lng, method, madhab)
    ↓
Timer.periodic(1s) → update countdown + check prayer change
    ↓
Timer.periodic(30s) → check if athan time reached → onPrayerTime callback
    ↓
AthanNotifier.playAthan() → GoRouter.push('/athan')
```

---

## 7. Navigation

**GoRouter 13.x** with ShellRoute for persistent navigation.

### Route Map

| Path                       | Screen              | Shell |
|----------------------------|---------------------|-------|
| `/`                        | DashboardScreen     | ✅    |
| `/prayer`                  | PrayerScreen        | ✅    |
| `/quran`                   | QuranScreen         | ✅    |
| `/quran/surah/:number`     | SurahReaderScreen   | ✅    |
| `/azkar`                   | AzkarScreen         | ✅    |
| `/azkar/:category`         | AzkarDetailScreen   | ✅    |
| `/settings`                | SettingsScreen      | ✅    |
| `/athan`                   | AthanScreen         | ❌ (fullscreen dialog) |

### Shell Behavior
- **Phone**: `Scaffold` + `BottomNavigationBar`
- **TV**: `Row` with 80px side rail, icon-only nav items

---

## 8. Theme System

### Dark Theme (Default)
Inspired by a night sky over a mosque — deep navy, golden accents, emerald highlights.

### Light Theme
Warm parchment tones (`#F8F4EC`), golden-brown accents — like an illuminated manuscript.

### Switching
Settings → ThemeMode → `MaterialApp.router(themeMode: ...)` re-renders whole app.

### Arabic RTL
- `Directionality(textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr)`
- Applied at widget tree level, not app level, for mixed content support
- Separate `fontFamily` overrides per widget for Arabic text

---

## 9. TV vs Phone Adaptation

### Detection Chain
```dart
1. MethodChannel 'awqati_app/platform' → isAndroidTV (native check)
2. Fallback: screen shortestSide > 600 && aspectRatio > 1.6
3. Breakpoints.isTV(context) used throughout
```

### TV Adaptations

| Aspect              | Phone                    | TV                              |
|---------------------|--------------------------|---------------------------------|
| Navigation          | Bottom bar (5 tabs)      | Side icon rail (80px)           |
| Prayer layout       | Vertical list            | 3-column grid                   |
| Quran list          | Vertical list            | 4-column grid                   |
| Clock font size     | 56px                     | 8% of screen width              |
| Safe zone padding   | System default           | 5% horizontal + vertical        |
| Focus system        | Touch only               | `Focus` widget + key events     |

### `TVFocusable` Widget
Wraps any widget with:
- Gold border glow on focus
- 1.04x scale animation on focus
- Enter/Select key → `onSelect` callback
- Accessible via D-pad navigation

### `TVFocusableCard`
Pre-styled card with focus state:
- Background tint on focus
- Gold border + box shadow on focus
- Animates smoothly

---

## 10. Prayer Times Engine

### Calculation via `adhan` Package

Supported methods:
| Method ID          | Description                      |
|--------------------|----------------------------------|
| `MuslimWorldLeague`| Standard worldwide               |
| `UmmAlQura`        | Saudi Arabia / Gulf              |
| `Egyptian`         | Egypt General Authority          |
| `ISNA`             | North America                    |
| `Karachi`          | South Asia                       |

### Location Strategy
1. Request `LocationPermission.whileInUse`
2. `Geolocator.getCurrentPosition()` with 10s timeout
3. Reverse geocode → city name
4. Cache in Hive settings
5. On failure → use cached coordinates
6. Last resort → Mecca coordinates (21.3891°N, 39.8579°E)

### Real-Time Updates
- `Timer.periodic(1s)` → updates countdown every second
- Prayer change detection: if `currentIndex` changed → rebuild with new highlights
- Midnight refresh: recalculates all prayers for new date

### Athan Trigger
- `Timer.periodic(30s)` checks if any prayer time diff < 30s
- Calls `onPrayerTime` callback → navigates to AthanScreen

---

## 11. Athan System

### Audio Sources
Files must be placed in `assets/audio/`:
- `athan_mecca.mp3`
- `athan_madinah.mp3`
- `athan_egypt.mp3`
- `athan_turkey.mp3`
- `athan_local.mp3`

### Playback Flow
```
Prayer time detected
    ↓
Settings.isSilentMode? → skip
    ↓
AthanNotifier.playAthan(prayerNameEn, prayerNameAr)
    ↓
AudioPlayer.setAsset(assetPath) → play()
    ↓
GoRouter.push('/athan?prayer=Fajr')  ← triggers from app root listener
    ↓
AthanScreen shown (fullscreen)
    ↓
PlayerStateStream.completed → pop screen
```

### AthanScreen Design
- Deep atmospheric background (radial gradient)
- Islamic geometric pattern overlay
- Radiating ring animations (4 rings, staggered phase)
- Pulsing mosque icon
- وقت الأذان in Amiri font
- Sound wave visualizer (7-bar animated)
- Auto-dismisses when audio completes
- Manual dismiss button

---

## 12. Quran Module

### Data Sources

**Offline (embedded):** 22 popular surahs + full Al-Fatiha with translations.

**Online API:** [AlQuran.cloud](https://api.alquran.cloud/v1)
- `GET /surah` — full surah list (114 surahs)
- `GET /surah/{n}` — Arabic text of surah
- `GET /surah/{n}/en.sahih` — Sahih International translation

### Audio Recitation
CDN endpoint: `https://cdn.islamic.network/quran/audio/128/ar.alafasy/{ayahNumber}.mp3`
- Reciter: Sheikh Mishary Rashid Alafasy
- Format: MP3 128kbps
- Per-ayah playback with `just_audio`

### Reader Features
- Arabic text in `ScheherazadeNew` font (full Quran support)
- Font size respects Settings.fontSize scale
- Toggle translation per-session
- Playing ayah highlighted in gold
- Auto-scroll to ayah on play
- Sajda indicator support
- Save/restore last position via Settings

### TV Reading Mode
- 80px horizontal padding (TV safe zone)
- Larger base font (32px × fontScale)
- Focused ayah highlighted via `TVFocusableCard`

---

## 13. Azkar Module

### Categories

| ID             | Arabic              | English         | Count |
|----------------|---------------------|-----------------|-------|
| `morning`      | أذكار الصباح        | Morning Azkar   | 6     |
| `evening`      | أذكار المساء        | Evening Azkar   | 4     |
| `sleep`        | أذكار النوم         | Sleep Azkar     | 5     |
| `after_prayer` | أذكار بعد الصلاة    | After Prayer    | 6     |

### Tasbih Counter (AzkarDetailScreen)
- Displays Arabic text of each dhikr
- Counter starts at `ZikrEntry.count` (e.g., 33, 100)
- Tap counter button → decrement
- `HapticFeedback.lightImpact()` on each tap
- Auto-advance to next dhikr when count reaches 0
- Progress bar shows overall session progress
- Gold → Emerald color transition when done
- Individual reset + full reset options

### Daily Hadith
- Rotates by `DateTime.now().day % hadithCount`
- Stored in `AzkarData.dailyHadiths` (Arabic + English)
- Displayed at top of AzkarScreen

---

## 14. Dashboard

### TV Dashboard Layout
```
[Clock + Date]                    [Next Prayer Countdown]   [City]
──────────────────── ✦ ─────────────────────────────────────────
[Fajr]  [Sunrise]  [Dhuhr]  [Asr]  [Maghrib]  [Isha]
                         ↑ Active highlighted gold
──────────────────────────────────────────────────────────────
              [Rotating Quran Verse] (changes every 15s)
```

### Phone Dashboard Layout
```
Good Morning
14:32:07
Monday, May 28, 2026
٢٨ ذو القعدة ١٤٤٦ هـ
──── ✦ ────
⏰ Next: Asr  [03:42]
──────────────────
[Fajr][Dhuhr][Asr][Maghrib][Isha]
──────────────────
📖 Verse of the Day card
```

### Verse Rotation
- 5 carefully selected Quranic verses
- `Timer.periodic(15s)` cycles index
- `AnimatedSwitcher` with fade + slide transition

---

## 15. Settings System

### Persisted Settings (Hive)

| Key                   | Type     | Default              |
|-----------------------|----------|----------------------|
| language              | String   | 'en'                 |
| theme_mode            | String   | 'dark'               |
| calculation_method    | String   | 'MuslimWorldLeague'  |
| madhab                | String   | 'Shafi'              |
| athan_sound           | String   | 'mecca'              |
| athan_volume          | double   | 0.8                  |
| is_silent_mode        | bool     | false                |
| font_size             | double   | 1.0                  |
| last_lat              | double   | 0.0                  |
| last_lng              | double   | 0.0                  |
| last_city             | String   | ''                   |
| show_translation      | bool     | false                |
| last_quran_surah      | int      | 1                    |
| last_quran_ayah       | int      | 1                    |
| use24hClock           | bool     | true                 |

---

## 16. Local Storage

**Hive** used for all persistence:

```dart
// Open box
final box = await Hive.openBox('settings_box');

// Write
box.put('language', 'ar');

// Read
final lang = box.get('language', defaultValue: 'en');
```

All writes happen in `SettingsNotifier._save()` after every state change.

---

## 17. Build Instructions

### Prerequisites
```bash
flutter --version        # Should be >= 3.16.0
dart --version           # Should be >= 3.2.0
```

### Setup
```bash
git clone <repo>
cd awqati_app
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Add Required Assets
Place these files before building:
```
assets/fonts/Amiri-Regular.ttf
assets/fonts/Amiri-Bold.ttf
assets/fonts/ScheherazadeNew-Regular.ttf
assets/fonts/ScheherazadeNew-Bold.ttf
assets/audio/athan_mecca.mp3
assets/audio/athan_madinah.mp3
assets/audio/athan_egypt.mp3
assets/audio/athan_turkey.mp3
```

Download Amiri: https://fonts.google.com/specimen/Amiri  
Download Scheherazade New: https://fonts.google.com/specimen/Scheherazade+New  
Athan audio: free Islamic audio libraries (e.g., https://www.islamicfinder.org)

### Android Manifest Permissions
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

### Android TV Manifest
In `AndroidManifest.xml`, add:
```xml
<uses-feature android:name="android.software.leanback" android:required="false" />
<uses-feature android:name="android.hardware.touchscreen" android:required="false" />

<activity
    android:name=".MainActivity"
    android:banner="@drawable/banner"
    android:label="Noor"
    android:theme="@style/Theme.Leanback">
    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LEANBACK_LAUNCHER" />
        <category android:name="android.intent.category.LAUNCHER" />
    </intent-filter>
</activity>
```

### Build APK (Phone)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build APK (Android TV)
```bash
flutter build apk --release --target-platform android-arm64
# Same APK works on TV — manifest handles launcher category
```

### Build App Bundle (Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Build for Web
```bash
flutter build web --release
# Output: build/web/
```

---

## 18. Dependencies

| Package                  | Version  | Purpose                            |
|--------------------------|----------|------------------------------------|
| `flutter_riverpod`       | ^2.5.1   | State management                   |
| `go_router`              | ^13.2.0  | Navigation                         |
| `hive` + `hive_flutter`  | ^2.2.3   | Local storage                      |
| `adhan`                  | ^1.1.0   | Prayer time calculations           |
| `just_audio`             | ^0.9.36  | Audio playback (athan, Quran)      |
| `audio_service`          | ^0.18.13 | Background audio                   |
| `geolocator`             | ^11.0.0  | GPS location                       |
| `geocoding`              | ^3.0.0   | Reverse geocoding (city name)      |
| `permission_handler`     | ^11.3.1  | Runtime permissions                |
| `http`                   | ^1.2.1   | Quran API calls                    |
| `intl`                   | ^0.19.0  | Date/time formatting               |
| `hijri`                  | ^2.0.1   | Hijri calendar conversion          |
| `flutter_animate`        | ^4.5.0   | Declarative animations             |
| `google_fonts`           | ^6.2.1   | Cinzel, Cormorant, Josefin Sans    |
| `auto_size_text`         | ^3.0.0   | Text that fits container           |
| `shimmer`                | ^3.0.0   | Loading skeletons                  |
| `lottie`                 | ^3.1.0   | JSON animations (optional)         |

---

## Notes for Production

1. **Athan scheduling**: For precise background athan even when app is closed, integrate `workmanager` or Android `AlarmManager` via platform channel.

2. **Full Quran offline**: Download all 114 surahs as JSON and store in Hive on first launch. The current implementation fetches from API with Al-Fatiha embedded.

3. **App icon for TV**: Create `android/app/src/main/res/drawable/banner.png` (320×180px) for Android TV launcher banner.

4. **Quran audio caching**: Implement `cached_network_image`-style caching for audio files to avoid re-downloading.

5. **Analytics**: Add Firebase Analytics to track feature usage.

6. **Crashlytics**: Add Firebase Crashlytics for production error tracking.

7. **Localization**: Expand beyond Arabic/English using Flutter's `intl` arb files for full i18n.

---

*Awqati App — Built with Flutter • Powered by faith*
