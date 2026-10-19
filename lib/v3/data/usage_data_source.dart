import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'usage_day_total.dart';

/// On-device screen-time source (never uploaded).
abstract class UsageDataSource {
  Future<bool> hasAccess();
  Future<bool> openSettings();
  Future<List<UsageDayTotal>> dailyTotals(int days);
}

class ChannelUsageDataSource implements UsageDataSource {
  ChannelUsageDataSource({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('brainclean/usage');

  final MethodChannel _channel;

  @override
  Future<bool> hasAccess() async {
    if (kIsWeb) return false;
    try {
      final raw = await _channel.invokeMethod<bool>('hasAccess');
      return raw == true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> openSettings() async {
    if (kIsWeb) return false;
    try {
      final raw = await _channel.invokeMethod<bool>('openSettings');
      return raw == true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<UsageDayTotal>> dailyTotals(int days) async {
    if (kIsWeb) return const [];
    try {
      final raw = await _channel.invokeMethod<List<dynamic>>(
        'dailyTotals',
        {'days': days},
      );
      if (raw == null) return const [];
      return raw
          .map(
            (e) => UsageDayTotal.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }
}

/// In-memory fake for widget/unit tests.
class FakeUsageDataSource implements UsageDataSource {
  FakeUsageDataSource({
    this.hasAccessValue = false,
    this.days = const [],
    this.openSettingsResult = true,
  });

  bool hasAccessValue;
  List<UsageDayTotal> days;
  bool openSettingsResult;
  int openSettingsCalls = 0;
  int dailyTotalsCalls = 0;

  @override
  Future<bool> hasAccess() async => hasAccessValue;

  @override
  Future<bool> openSettings() async {
    openSettingsCalls++;
    return openSettingsResult;
  }

  @override
  Future<List<UsageDayTotal>> dailyTotals(int daysCount) async {
    dailyTotalsCalls++;
    return days;
  }
}
