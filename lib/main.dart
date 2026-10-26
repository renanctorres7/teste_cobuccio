import 'package:flutter/material.dart';
import 'package:teste_cobuccio/app/app_widget.dart';
import 'package:teste_cobuccio/app/core/di/injection.dart';
import 'package:teste_cobuccio/app/core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(AppWidget(router: createAppRouter()));
}
