/// 應用程式執行期設定。
///
/// 中央氣象署開放資料平台的 API Key 屬於機敏資訊，絕不可寫死於原始碼、
/// 版本控制或文件中。本專案透過編譯期常數
/// `--dart-define=CWA_API_KEY=xxxx` 由執行者於本機注入，例如：
///
/// ```sh
/// flutter run --dart-define=CWA_API_KEY=你的金鑰
/// ```
///
/// 若未提供，[cwaApiKey] 會是空字串，應用程式會以
/// [MissingApiKeyFailure]（見 `weather_failure.dart`）明確告知使用者，
/// 而不是讓底層 HTTP 請求以難以理解的方式失敗。
abstract final class AppConfig {
  static const String cwaApiKey = String.fromEnvironment('CWA_API_KEY');
}
