import 'package:dio/dio.dart';

const String kBaseUrl =
    'https://zaidanrazzak190804-blip.github.io/elearning-mock-api';

Dio createDio() {
  return Dio(
    BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}