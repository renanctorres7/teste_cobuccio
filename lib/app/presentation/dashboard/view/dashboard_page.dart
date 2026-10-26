import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:teste_cobuccio/app/core/router/app_routes.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Arquitetura pronta'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.push(AppRoutes.transactions),
              child: const Text('Ir para Extrato'),
            ),
          ],
        ),
      ),
    );
  }
}
