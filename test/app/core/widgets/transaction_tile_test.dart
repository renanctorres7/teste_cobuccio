import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_type_enum.dart';
import 'package:teste_cobuccio/app/core/widgets/transaction_tile.dart';

import '../../../helpers/fixtures.dart';

void main() {
  testWidgets('exposes description without decorative icon label', (
    tester,
  ) async {
    final tx = sampleTransaction(type: TransactionTypeEnum.income);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransactionTile(
            transaction: tx,
            isHidden: false,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Bitcoin variação'), findsOneWidget);
    expect(find.textContaining('Entrada'), findsOneWidget);
    final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_downward));
    expect(icon.semanticLabel, isNull);
  });

  testWidgets('lays out without overflow at 200% text scale', (tester) async {
    final tx = sampleTransaction(
      description: 'Transferência internacional com descrição bem longa',
      cents: 123456789,
    );

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
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: TransactionTile(
              transaction: tx,
              isHidden: false,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Transferência internacional'), findsOneWidget);
  });
}
