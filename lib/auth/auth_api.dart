import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/app_user.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<AuthTokens> login(String username, String password) => guard(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'username': username, 'password': password},
    );
    return AuthTokens.fromJson(response.data ?? const {});
  });

  Future<AuthTokens> register({
    required String username,
    required String password,
    required String displayName,
  }) => guard(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'username': username,
        'password': password,
        'displayName': displayName,
      },
    );
    return AuthTokens.fromJson(response.data ?? const {});
  });

  Future<AppUser> me() => guard(() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return AppUser.fromJson(response.data ?? const {});
  });

  Future<AuthTokens> refresh(String refreshToken) => guard(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return AuthTokens.fromJson(response.data ?? const {});
  });
}
