import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/core/widgets/app_loading_view.dart';

void main() {
  testWidgets('announces loading via live-region Semantics', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppLoadingView()),
      ),
    );

    expect(find.bySemanticsLabel('Carregando'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Carregando')),
      containsSemantics(
        label: 'Carregando',
        isLiveRegion: true,
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    handle.dispose();
  });

  testWidgets('uses custom label when provided', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppLoadingView(label: 'Carregando extrato'),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Carregando extrato'), findsOneWidget);
    handle.dispose();
  });
}
