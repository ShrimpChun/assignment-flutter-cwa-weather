import 'package:equatable/equatable.dart';

import '../constants/taiwan_locations.dart';

/// 代表天氣查詢流程中所有可能發生的失敗情境。
///
/// 每個子型別都附帶一段可直接呈現於 UI 的繁體中文說明文字（[message]），
/// 讓畫面不需要再依 [WeatherFailure] 的型別另外組字串。
sealed class WeatherFailure extends Equatable {
  const WeatherFailure(this.message);

  /// 可直接顯示於錯誤畫面的說明文字。
  final String message;

  @override
  List<Object?> get props => [message];

  @override
  bool get stringify => true;
}

/// 使用者尚未輸入地區名稱，或輸入內容僅包含空白字元。
final class InvalidInputFailure extends WeatherFailure {
  const InvalidInputFailure()
    : super('請輸入要查詢的地區名稱，例如：$kExampleLocationNameA。');
}

/// 尚未設定中央氣象署 API Key（`--dart-define=CWA_API_KEY=...`）。
final class MissingApiKeyFailure extends WeatherFailure {
  const MissingApiKeyFailure()
    : super('尚未設定中央氣象署開放資料平台 API Key，請參考 README 說明以 --dart-define 提供金鑰。');
}

/// 網路連線逾時、中斷或裝置離線。
final class NetworkFailure extends WeatherFailure {
  const NetworkFailure() : super('網路連線異常，請確認裝置已連上網路後再試一次。');
}

/// API Key 無效或未授權（HTTP 401 / 403，或伺服器回傳 success=false）。
final class UnauthorizedFailure extends WeatherFailure {
  const UnauthorizedFailure() : super('API 金鑰無效或未授權，請確認 CWA API Key 設定是否正確。');
}

/// 伺服器端錯誤，例如 HTTP 5xx 或非預期的 4xx 狀態碼。
final class ServerFailure extends WeatherFailure {
  const ServerFailure({this.statusCode}) : super('中央氣象署伺服器發生錯誤，請稍後再試一次。');

  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// 查詢的地區名稱不存在於 API 回傳資料中。
final class LocationNotFoundFailure extends WeatherFailure {
  const LocationNotFoundFailure(this.locationName)
    : super(
        '查無「$locationName」的天氣預報資料，請確認地區名稱是否正確'
        '（例如：$kExampleLocationNameA、$kExampleLocationNameB、'
        '$kExampleLocationNameC）。',
      );

  final String locationName;

  @override
  List<Object?> get props => [message, locationName];
}

/// API 回傳的資料格式不符預期（缺欄位、型別錯誤等），無法安全解析。
final class DataParsingFailure extends WeatherFailure {
  const DataParsingFailure() : super('取得的天氣資料格式不正確，暫時無法顯示，請稍後再試。');
}

/// 未歸類的未知錯誤，作為所有例外處理的最後防線。
final class UnknownFailure extends WeatherFailure {
  const UnknownFailure() : super('發生未知錯誤，請稍後再試一次。');
}
