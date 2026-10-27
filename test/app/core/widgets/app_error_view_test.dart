import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/core/widgets/app_error_view.dart';

void main() {
  testWidgets('announces error message as live region', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppErrorView(
            message: 'Sem conexão. Verifique a internet e tente novamente.',
            onRetry: () {},
          ),
        ),
      ),
    );

    final message = find.text(
      'Sem conexão. Verifique a internet e tente novamente.',
    );
    expect(message, findsOneWidget);
    expect(
      tester.getSemantics(message),
      isSemantics(
        label: 'Sem conexão. Verifique a internet e tente novamente.',
        isLiveRegion: true,
      ),
    );
    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    handle.dispose();
  });
}
