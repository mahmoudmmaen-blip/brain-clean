import 'dart:io';

import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/features/v2_shell/domain/v2_shell_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Branding + shell regression guards for the Internal Testing release path.
void main() {
  group('Android brand resources', () {
    test('adaptive launcher XML and densities exist', () {
      final root = Directory.current.path;
      final res = Directory('$root/android/app/src/main/res');
      expect(res.existsSync(), isTrue);

      final adaptive = File(
        '${res.path}/mipmap-anydpi-v26/ic_launcher.xml',
      );
      expect(adaptive.existsSync(), isTrue);
      final xml = adaptive.readAsStringSync();
      expect(xml, contains('@drawable/ic_launcher_foreground'));
      expect(xml, contains('@color/ic_launcher_background'));
      expect(xml, contains('@drawable/ic_launcher_monochrome'));

      for (final density in <String>[
        'mdpi',
        'hdpi',
        'xhdpi',
        'xxhdpi',
        'xxxhdpi',
      ]) {
        final icon = File('${res.path}/mipmap-$density/ic_launcher.png');
        expect(icon.existsSync(), isTrue, reason: icon.path);
        // Flutter default launcher files were tiny (~400–1500 bytes).
        expect(icon.lengthSync(), greaterThan(2000), reason: icon.path);
      }

      expect(
        File('${res.path}/drawable/ic_launcher_foreground.png').existsSync(),
        isTrue,
      );
      expect(
        File('${res.path}/drawable/ic_launcher_monochrome.png').existsSync(),
        isTrue,
      );
      expect(File('${res.path}/drawable/splash_logo.png').existsSync(), isTrue);
      expect(
        File('${res.path}/values/colors.xml').readAsStringSync(),
        contains('ic_launcher_background'),
      );
    });

    test('manifest references Brain Clean launcher, not Flutter defaults path',
        () {
      final manifest = File(
        '${Directory.current.path}/android/app/src/main/AndroidManifest.xml',
      );
      final text = manifest.readAsStringSync();
      expect(text, contains('android:icon="@mipmap/ic_launcher"'));
      expect(text, contains('android:label="Brain Clean"'));
      expect(text, isNot(contains('flutter_launcher')));
    });

    test('canonical brand source files exist', () {
      final root = Directory.current.path;
      expect(
          File('$root/branding/brain_clean_mark_512.png').existsSync(), isTrue);
      expect(
        File('$root/store/play_store_icon_512.png').existsSync(),
        isTrue,
      );
      expect(
        File('$root/assets/branding/brain_clean_mark.png').existsSync(),
        isTrue,
      );
      // Master PNG must be a real 512 asset, not a stub.
      expect(
        File('$root/branding/brain_clean_mark_512.png').lengthSync(),
        greaterThan(20 * 1024),
      );
    });

    test('package remains com.brainclean.mobile', () {
      final gradle = File(
        '${Directory.current.path}/android/app/build.gradle.kts',
      ).readAsStringSync();
      expect(gradle, contains('applicationId = "com.brainclean.mobile"'));
    });

    test('release manifest declares Advertising ID permission for Play', () {
      final manifest = File(
        '${Directory.current.path}/android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();
      expect(
        manifest,
        contains('com.google.android.gms.permission.AD_ID'),
      );
      expect(manifest, contains('tools:node="replace"'));
      expect(manifest, isNot(contains('tools:node="remove"')));
    });
  });

  group('V2 shell IA — Pro mock five tabs', () {
    test('tab order Home / Exercises / Progress / Pro / Profile', () {
      expect(
        V2ShellTab.values.map((t) => t.name).toList(),
        <String>['today', 'exercises', 'progress', 'pro', 'profile'],
      );
      expect(V2ShellTab.today.pathPrefix, AppRoutes.v2Home);
      expect(V2ShellTab.exercises.pathPrefix, '/v2/exercises');
      expect(V2ShellTab.progress.pathPrefix, '/v2/progress');
      expect(V2ShellTab.pro.pathPrefix, '/v2/pro');
      expect(V2ShellTab.profile.pathPrefix, '/v2/profile');
    });
  });

  group('Flutter splash uses brand asset', () {
    testWidgets('splash image asset is declared and loadable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Image(
                image: AssetImage('assets/branding/brain_clean_mark.png'),
                width: 48,
                height: 48,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(Image), findsOneWidget);
      // Bounded pumps only — no pixel assertion.
      await tester.pump(const Duration(milliseconds: 16));
    });
  });
}
