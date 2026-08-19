import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/weather_remote_data_source.dart';
import '../models/location_forecast.dart';

/// 天氣預報資料的存取介面，隔離上層（狀態管理）與底層資料來源的細節。
abstract class WeatherRepository {
  /// 依地區名稱取得今明 36 小時天氣預報。
  ///
  /// 失敗時一律拋出 `weather_failure.dart` 中定義的 `WeatherFailure` 子型別。
  /// 傳入 [cancelToken] 可在呼叫端（例如發出更新的查詢）主動取消這次
  /// 尚未完成的請求，避免已經過期的回應仍持續佔用網路資源。
  Future<LocationForecast> fetchForecast(
    String locationName, {
    CancelToken? cancelToken,
  });
}

class WeatherRepositoryImpl implements WeatherRepository {
  const WeatherRepositoryImpl(this._remoteDataSource);

  final WeatherRemoteDataSource _remoteDataSource;

  @override
  Future<LocationForecast> fetchForecast(
    String locationName, {
    CancelToken? cancelToken,
  }) async {
    return _remoteDataSource.fetchForecast(
      locationName,
      cancelToken: cancelToken,
    );
  }
}

/// 提供 [WeatherRepository] 實作；Widget 測試／單元測試可透過
/// `ProviderScope(overrides: [weatherRepositoryProvider.overrideWithValue(...)])`
/// 輕鬆替換為 mock 實作。
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepositoryImpl(ref.watch(weatherRemoteDataSourceProvider));
});
