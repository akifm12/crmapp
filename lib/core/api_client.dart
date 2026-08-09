import 'dart:async';

import 'package:dio/dio.dart';

import 'config.dart';
import 'secure_storage.dart';

/// Fires whenever a request comes back 401 — the app's auth state listens
/// to this to clear itself and bounce the user to the login screen.
final unauthorizedEvents = StreamController<void>.broadcast();

class ApiClient {
  ApiClient._();

  static final Dio instance = _build();

  static Dio _build() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.readToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await SecureStorage.deleteToken();
          unauthorizedEvents.add(null);
        }
        handler.next(error);
      },
    ));

    return dio;
  }
}
