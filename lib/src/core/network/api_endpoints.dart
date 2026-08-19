/// 中央氣象署開放資料平台相關的 API 位址常數。
abstract final class ApiEndpoints {
  /// 開放資料平台 REST API 基礎網址。
  static const String baseUrl = 'https://opendata.cwa.gov.tw/api';

  /// 一般天氣預報－今明 36 小時天氣預報。
  static const String generalForecast36h = '/v1/rest/datastore/F-C0032-001';
}
