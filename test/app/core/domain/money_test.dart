import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/core/domain/money.dart';

void main() {
  group('Money', () {
    test('fromReais converts to cents', () {
      expect(Money.fromReais(10.50).cents, 1050);
      expect(Money.fromReais(0).cents, 0);
    });

    test('supports addition and subtraction', () {
      const a = Money(1000);
      const b = Money(250);

      expect((a + b).cents, 1250);
      expect((a - b).cents, 750);
      expect((-a).cents, -1000);
    });

    test('exposes sign helpers', () {
      expect(const Money(0).isZero, isTrue);
      expect(const Money(1).isPositive, isTrue);
      expect(const Money(-1).isNegative, isTrue);
    });

    test('formats in pt_BR', () {
      final formatted = const Money(123456).format();
      expect(formatted, contains('R\$'));
      expect(formatted, contains('1.234,56'));
    });
  });
}
