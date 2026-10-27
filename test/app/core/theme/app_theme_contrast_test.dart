import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/core/theme/app_theme_data.dart';

double contrastRatio(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void expectContrast(
  String pair,
  Color fg,
  Color bg, {
  required double min,
}) {
  final ratio = contrastRatio(fg, bg);
  expect(
    ratio,
    greaterThanOrEqualTo(min),
    reason: '$pair contrast ${ratio.toStringAsFixed(2)}:1 < $min:1',
  );
}

void main() {
  group('App theme WCAG contrast (spot-check)', () {
    for (final entry in {
      'light': buildAppTheme(),
      'dark': buildAppDarkTheme(),
    }.entries) {
      test('${entry.key} scheme pairs meet AA for legend and amounts', () {
        final scheme = entry.value.colorScheme;

        // Legend bodySmall uses onSurfaceVariant on surface (normal text → 4.5:1).
        expectContrast(
          'onSurfaceVariant / surface',
          scheme.onSurfaceVariant,
          scheme.surface,
          min: 4.5,
        );

        // Amounts use primary/error at titleMedium + w600 (~large text → 3:1).
        expectContrast(
          'primary / surface',
          scheme.primary,
          scheme.surface,
          min: 3.0,
        );
        expectContrast(
          'error / surface',
          scheme.error,
          scheme.surface,
          min: 3.0,
        );

        expectContrast(
          'onSurface / surface',
          scheme.onSurface,
          scheme.surface,
          min: 4.5,
        );
      });
    }
  });
}
