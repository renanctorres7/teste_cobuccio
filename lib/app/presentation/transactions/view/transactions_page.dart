import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:teste_cobuccio/app/core/router/app_routes.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Extrato')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Arquitetura pronta — Extrato'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () =>
                  context.push(AppRoutes.transactionDetailPath('demo-id')),
              child: const Text('Abrir detalhe (placeholder)'),
            ),
          ],
        ),
      ),
    );
  }
}
