import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:teste_cobuccio/app/core/theme/app_theme_data.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Extrato Financeiro',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
