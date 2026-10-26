import 'package:flutter/material.dart';

class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe da transação')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Arquitetura pronta — Detalhe'),
            const SizedBox(height: 8),
            Text('id: $transactionId'),
          ],
        ),
      ),
    );
  }
}
