import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/core/widgets/stale_cache_banner.dart';

void main() {
  testWidgets('shows stale cache warning as live region', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: StaleCacheBanner())),
    );

    final message = find.text(StaleCacheBanner.message);
    expect(message, findsOneWidget);
    expect(
      tester.getSemantics(message),
      isSemantics(label: StaleCacheBanner.message, isLiveRegion: true),
    );
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    handle.dispose();
  });
}
