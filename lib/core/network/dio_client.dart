// Migrado de: src/api/api.js (axios.create)
// axios instance → Dio com AuthInterceptor
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';
import 'api_interceptors.dart';

// Em produção: usar variável de ambiente ou flavor
// Para emulador Android: 10.0.2.2 aponta para localhost do host
// Para dispositivo físico: IP da máquina na rede local
const _kBaseUrl = 'http://10.0.2.2:8080/api/v1';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _kBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(AuthInterceptor(ref.read(secureStorageProvider)));
  return dio;
});
