import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/weather_failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_provider.dart';
import '../models/location_forecast.dart';

/// 負責直接呼叫中央氣象署開放資料平台 API 的資料來源。
///
/// 此類別只關心「怎麼把一個地區名稱換成 [LocationForecast]」，
/// 所有可能發生的錯誤都會被轉換成 [WeatherFailure] 的子型別拋出，
/// 呼叫端（Repository / Notifier）不需要認識 Dio 或原始 JSON 的細節。
///
/// API Key 以建構子注入（而非直接讀取 [AppConfig] 全域常數），
/// 讓單元測試能輕易替換為假金鑰，不必依賴編譯期環境變數。
class WeatherRemoteDataSource {
  const WeatherRemoteDataSource(this._dio, {required this.apiKey});

  final Dio _dio;

  /// 中央氣象署開放資料平台 API Key，由呼叫端注入（見類別文件說明）。
  final String apiKey;

  Future<LocationForecast> fetchForecast(String locationName) async {
    if (apiKey.trim().isEmpty) {
      throw const MissingApiKeyFailure();
    }

    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(
        ApiEndpoints.generalForecast36h,
        queryParameters: {
          'Authorization': apiKey,
          'locationName': locationName,
          'format': 'JSON',
        },
      );
    } on DioException catch (error) {
      throw _mapDioException(error);
    }

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw const DataParsingFailure();
    }

    if (!_isSuccess(body['success'])) {
      throw const UnauthorizedFailure();
    }

    final records = body['records'];
    if (records is! Map<String, dynamic>) {
      throw const DataParsingFailure();
    }

    final locations = records['location'];
    if (locations is! List) {
      throw const DataParsingFailure();
    }

    if (locations.isEmpty) {
      throw LocationNotFoundFailure(locationName);
    }

    final firstLocation = locations.first;
    if (firstLocation is! Map<String, dynamic>) {
      throw const DataParsingFailure();
    }

    return LocationForecast.fromJson(firstLocation);
  }

  /// 判斷 API 回應中的 `success` 欄位是否代表成功。
  ///
  /// 中央氣象署官方文件中 `success` 為字串 `"true"`/`"false"`，但也一併
  /// 容忍 JSON 布林值 `true`/`false`，避免未來 API 回應格式微調時，
  /// 錯誤地把授權失敗誤判為格式錯誤。缺少此欄位則視為成功（沿用舊行為，
  /// 交由後續的 `records` 檢查把關資料完整性）。
  bool _isSuccess(Object? success) {
    return switch (success) {
      final String value => value.toLowerCase() == 'true',
      final bool value => value,
      null => true,
      _ => false,
    };
  }

  WeatherFailure _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
        return const NetworkFailure();
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return const UnknownFailure();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return const UnauthorizedFailure();
        }
        return ServerFailure(statusCode: statusCode);
    }
  }
}

/// 提供 [WeatherRemoteDataSource] 單例，供 Repository 使用。
final weatherRemoteDataSourceProvider = Provider<WeatherRemoteDataSource>((
  ref,
) {
  return WeatherRemoteDataSource(
    ref.watch(dioProvider),
    apiKey: AppConfig.cwaApiKey,
  );
});
