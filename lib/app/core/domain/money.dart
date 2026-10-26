import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

final class Money extends Equatable implements Comparable<Money> {
  const Money(this.cents);

  factory Money.fromReais(num reais) {
    return Money((reais * 100).round());
  }

  final int cents;

  double get asReais => cents / 100;

  Money operator +(Money other) => Money(cents + other.cents);

  Money operator -(Money other) => Money(cents - other.cents);

  Money operator -() => Money(-cents);

  bool get isZero => cents == 0;

  bool get isPositive => cents > 0;

  bool get isNegative => cents < 0;

  String format({String locale = 'pt_BR', String symbol = r'R$'}) {
    final formatter = NumberFormat.currency(locale: locale, symbol: symbol);
    return formatter.format(asReais);
  }

  @override
  int compareTo(Money other) => cents.compareTo(other.cents);

  @override
  List<Object?> get props => [cents];

  @override
  String toString() => format();
}
