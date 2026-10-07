import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Android 15+ edge-to-edge: draw behind system bars; content uses SafeArea.
abstract final class SystemUi {
  static Future<void> enableEdgeToEdge() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(overlayStyle(Brightness.dark));
  }

  /// Transparent system bars — avoid opaque [statusBarColor] / nav bar fills
  /// that trip Play Console deprecated edge-to-edge API warnings.
  static SystemUiOverlayStyle overlayStyle(Brightness brightness) {
    final lightIcons = brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          lightIcons ? Brightness.light : Brightness.dark,
      statusBarBrightness: lightIcons ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          lightIcons ? Brightness.light : Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    );
  }
}
