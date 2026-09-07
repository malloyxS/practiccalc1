import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_exceptions.dart';
import 'config.dart';

Dio buildDio({String? Function()? tokenProvider}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = tokenProvider?.call();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (kDebugMode) {
          debugPrint('[API] ${options.method} ${options.uri}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint('[API] ${response.statusCode} ${response.requestOptions.uri}');
        }
        final status = response.statusCode ?? 0;
        if (status >= 400) {
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              error: mapHttpError(status, response.data),
            ),
            true,
          );
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          debugPrint('[API] сбой ${error.requestOptions.uri}: ${error.type}');
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
}

Future<T> withRetry<T>(Future<T> Function() action, {int attempts = 3}) async {
  var delay = const Duration(milliseconds: 300);
  Object? lastError;
  for (var i = 0; i < attempts; i++) {
    try {
      return await action();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      lastError = e;
      if (i == attempts - 1) rethrow;
      await Future<void>.delayed(delay);
      delay *= 2;
    } on NetworkException catch (e) {
      lastError = e;
      if (i == attempts - 1) rethrow;
      await Future<void>.delayed(delay);
      delay *= 2;
    }
  }
  throw lastError ?? const ServerException();
}
