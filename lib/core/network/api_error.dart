import 'package:dio/dio.dart';

String friendlyError(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi terlalu lama. Coba lagi beberapa saat.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internetmu.';
      case DioExceptionType.badResponse:
        return 'Server bermasalah (kode ${error.response?.statusCode}).';
      default:
        return 'Terjadi kesalahan jaringan.';
    }
  }
  return 'Data tidak dapat diproses. Coba lagi.';
}