import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:teste_cobuccio/app/core/network/dio_client.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  _registerCore();
  _registerData();
  _registerInfra();
  _registerDomain();
  _registerPresentation();
}

void _registerCore() {
  getIt.registerLazySingleton<Dio>(DioClient.create);
}

void _registerData() {}

void _registerInfra() {}

void _registerDomain() {}

void _registerPresentation() {}
