import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/app_widget.dart';
import 'package:teste_cobuccio/app/core/router/app_router.dart';

void main() {
  testWidgets('Dashboard placeholder is shown', (tester) async {
    await tester.pumpWidget(AppWidget(router: createAppRouter()));
    await tester.pumpAndSettle();

    expect(find.text('Arquitetura pronta'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
