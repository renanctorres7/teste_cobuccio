import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/core/widgets/offline_banner.dart';

void main() {
  testWidgets('shows offline warning as live region', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: OfflineBanner())),
    );

    final message = find.text(OfflineBanner.message);
    expect(message, findsOneWidget);
    expect(
      tester.getSemantics(message),
      isSemantics(label: OfflineBanner.message, isLiveRegion: true),
    );
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    handle.dispose();
  });
}
