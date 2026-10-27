import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:teste_cobuccio/app/core/widgets/grouped_transactions_list.dart';

import '../../../helpers/fixtures.dart';

void main() {
  testWidgets('marks date headers and load-more for screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    final tx = sampleTransaction(occurredAt: DateTime.utc(2026, 10, 27, 12));
    final header = DateFormat('dd/MM/yyyy').format(tx.occurredAt.toLocal());
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GroupedTransactionsList(
            controller: controller,
            items: [tx],
            isLoadingMore: true,
            onTransactionTap: (_) {},
            isHidden: false,
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.text(header)),
      containsSemantics(label: header, isHeader: true),
    );
    expect(find.bySemanticsLabel('Carregando mais itens'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Carregando mais itens')),
      containsSemantics(
        label: 'Carregando mais itens',
        isLiveRegion: true,
      ),
    );
    handle.dispose();
  });
}
