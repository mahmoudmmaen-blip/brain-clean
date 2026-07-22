import 'package:brain_clean_mobile/features/bci/presentation/widgets/bci_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bciRingSweepParts keeps colors and stops equal length', () {
    final parts = bciRingSweepParts(const Color(0xFF2DD4BF));
    expect(parts.colors.length, parts.stops.length);
    expect(parts.colors.length, 5);
    expect(parts.stops.first, 0.0);
    expect(parts.stops.last, 1.0);
  });
}
