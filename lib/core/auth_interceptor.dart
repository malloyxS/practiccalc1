import 'package:dio/dio.dart';

import '../state/auth_notifier.dart';

void attachRefreshInterceptor(Dio dio, AuthNotifier auth) {
  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      onError: (error, handler) async {
        final status = error.response?.statusCode;
        final path = error.requestOptions.path;
        if (status == 401 && !path.contains('/auth/')) {
          try {
            await auth.refreshTokens();
            final options = error.requestOptions;
            options.headers['Authorization'] = 'Bearer ${auth.accessToken}';
            final response = await dio.fetch(options);
            return handler.resolve(response);
          } catch (_) {
            await auth.logout();
          }
        }
        return handler.next(error);
      },
    ),
  );
}
