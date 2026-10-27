import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/core/domain/money.dart';
import 'package:teste_cobuccio/app/core/widgets/period_totals_chart.dart';

void main() {
  testWidgets('exposes Entradas/Saídas totals via Semantics', (tester) async {
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
  });
}
