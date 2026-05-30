// lib/core/utils/platform_utils.dart
// Detects whether running on Android TV or phone/tablet

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlatformUtils {
  PlatformUtils._();

  static bool _isTV = false;
  static bool _initialized = false;

  /// Call once during app startup
  static Future<void> initialize() async {
    if (_initialized) return;
    if (Platform.isAndroid) {
      try {
        const channel = MethodChannel('noor_app/platform');
        final result = await channel.invokeMethod<bool>('isAndroidTV');
        _isTV = result ?? false;
      } catch (_) {
        // Fallback: check screen size in build context
        _isTV = false;
      }
    }
    _initialized = true;
  }

  static bool get isTV => _isTV;
  static bool get isPhone => !_isTV;

  /// Detect TV based on screen dimensions as fallback
  static bool isTVFromContext(BuildContext context) {
    if (_isTV) return true;
    final size = MediaQuery.of(context).size;
    // TVs typically have large screens with specific aspect ratios
    final diagonal = (size.width * size.width + size.height * size.height);
    return size.shortestSide > 600 && size.aspectRatio > 1.6 && diagonal > 500000;
  }

  /// Returns appropriate padding for TV safe zone
  static EdgeInsets tvSafePadding(BuildContext context) {
    if (!isTVFromContext(context)) return EdgeInsets.zero;
    final size = MediaQuery.of(context).size;
    return EdgeInsets.symmetric(
      horizontal: size.width * 0.05,
      vertical: size.height * 0.05,
    );
  }

  /// Returns scale factor for TV text sizes
  static double textScaleFactor(BuildContext context) {
    return isTVFromContext(context) ? 1.3 : 1.0;
  }
}

/// Responsive breakpoints
class Breakpoints {
  static const double phone = 600;
  static const double tablet = 900;
  static const double tv = 1280;

  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < phone;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= phone && w < tv;
  }

  static bool isTV(BuildContext context) =>
      MediaQuery.of(context).size.width >= tv;

  static T responsive<T>(
    BuildContext context, {
    required T phone,
    T? tablet,
    T? tv,
  }) {
    if (isTV(context) && tv != null) return tv;
    if (isTablet(context) && tablet != null) return tablet;
    return phone;
  }
}
