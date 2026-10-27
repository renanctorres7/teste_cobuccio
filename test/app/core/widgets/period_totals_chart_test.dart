import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/core/domain/money.dart';
import 'package:teste_cobuccio/app/core/widgets/period_totals_chart.dart';

void main() {
  testWidgets('exposes Entradas/Saídas totals via Semantics', (tester) async {
    final handle = tester.ensureSemantics();

    const income = Money(5000);
    const expense = Money(2000);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PeriodTotalsChart(
            totalIncome: income,
            totalExpense: expense,
          ),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel(
        'Entradas ${income.format()}, Saídas ${expense.format()}',
      ),
      findsOneWidget,
    );
    expect(find.text('Entradas'), findsOneWidget);
    expect(find.text('Saídas'), findsOneWidget);
    expect(find.text(income.format()), findsOneWidget);
    expect(find.text(expense.format()), findsOneWidget);
    handle.dispose();
  });

  testWidgets('lays out without overflow at 200% text scale', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(2),
            ),
            child: child!,
          );
        },
        home: const Scaffold(
          body: PeriodTotalsChart(
            totalIncome: Money(123456789),
            totalExpense: Money(987654321),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Entradas'), findsOneWidget);
    expect(find.text('Saídas'), findsOneWidget);
  });
}
