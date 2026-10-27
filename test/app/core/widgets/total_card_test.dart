import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/core/widgets/total_card.dart';

void main() {
  testWidgets('does not attach semanticLabel on decorative icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TotalCard(
            label: 'Entradas',
            value: r'R$ 50,00',
            icon: Icons.arrow_downward,
            color: Colors.green,
            isHidden: false,
          ),
        ),
      ),
    );

    expect(find.text('Entradas'), findsOneWidget);
    expect(find.text(r'R$ 50,00'), findsOneWidget);
    final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_downward));
    expect(icon.semanticLabel, isNull);
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
          body: SizedBox(
            width: 180,
            child: TotalCard(
              label: 'Entradas',
              value: r'R$ 1.234,56',
              icon: Icons.arrow_downward,
              color: Colors.green,
              isHidden: false,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Entradas'), findsOneWidget);
  });
}
