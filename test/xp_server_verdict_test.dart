import 'package:brain_clean_mobile/features/gamification/domain/xp_server_verdict.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('XpServerVerdict.fromJson', () {
    test('accepted status maps to accepted verdict', () {
      final verdict = XpServerVerdict.fromJson({
        'id': 'entry-1',
        'status': 'accepted',
      });

      expect(verdict.id, 'entry-1');
      expect(verdict.accepted, isTrue);
      expect(verdict.reason, isNull);
    });

    test('non-accepted status keeps rejection reason', () {
      final verdict = XpServerVerdict.fromJson({
        'id': 'entry-2',
        'status': 'rejected',
        'reason': 'daily_cap',
      });

      expect(verdict.accepted, isFalse);
      expect(verdict.reason, 'daily_cap');
    });

    test('missing fields fall back to empty id and rejection', () {
      final verdict = XpServerVerdict.fromJson({});

      expect(verdict.id, '');
      expect(verdict.accepted, isFalse);
      expect(verdict.reason, isNull);
    });
  });

  group('XpVerifyResponse.fromJson', () {
    test('parses verdict list and server total', () {
      final response = XpVerifyResponse.fromJson({
        'verdicts': [
          {'id': 'a', 'status': 'accepted'},
          {'id': 'b', 'status': 'rejected', 'reason': 'implausible'},
        ],
        'serverTotalXp': 250,
      });

      expect(response.serverTotalXp, 250);
      expect(response.verdicts.map((v) => v.id), ['a', 'b']);
      expect(response.verdicts.map((v) => v.accepted), [true, false]);
    });

    test('skips non-map verdict items', () {
      final response = XpVerifyResponse.fromJson({
        'verdicts': [
          'garbage',
          42,
          {'id': 'a', 'status': 'accepted'},
        ],
      });

      expect(response.verdicts, hasLength(1));
      expect(response.verdicts.single.id, 'a');
    });

    test('non-list verdicts and absent total degrade to empty response', () {
      final response = XpVerifyResponse.fromJson({'verdicts': 'nope'});

      expect(response.verdicts, isEmpty);
      expect(response.serverTotalXp, 0);
    });

    test('double server total is truncated to int', () {
      final response = XpVerifyResponse.fromJson({'serverTotalXp': 99.9});

      expect(response.serverTotalXp, 99);
    });
  });
}
