import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_endpoints.dart';

/// 提供整個應用程式共用、已設定基本逾時與除錯攔截器的 [Dio] 實例。
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(_RedactedLogInterceptor());
  }

  return dio;
});

/// 僅於 Debug 模式輸出請求方法／路徑／回應狀態碼。
///
/// 刻意不印出查詢參數與標頭，避免 Authorization（API Key）
/// 意外外洩於除錯日誌中。
class _RedactedLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[Dio] → ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint(
      '[Dio] ← ${response.statusCode} ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[Dio] ✗ ${err.requestOptions.path}: ${err.type}');
    handler.next(err);
  }
}
