# 中央氣象署天氣預報（CWA Weather）

以 Flutter 開發的天氣查詢 App，串接中央氣象署（CWA）開放資料平台的
「一般天氣預報－今明 36 小時天氣預報」API（`F-C0032-001`），
讓使用者輸入縣市名稱即可查詢當地未來 36 小時的天氣現象、溫度區間、
降雨機率與體感舒適度。

## 目錄

- [功能特色](#功能特色)
- [畫面狀態](#畫面狀態)
- [技術棧](#技術棧)
- [專案架構](#專案架構)
- [開始使用](#開始使用)
  - [必要條件](#必要條件)
  - [取得 API Key](#取得-api-key)
  - [安裝依賴](#安裝依賴)
  - [執行應用程式](#執行應用程式)
- [執行測試](#執行測試)
- [錯誤處理](#錯誤處理)
- [設計決策說明](#設計決策說明)
- [已知限制](#已知限制)

## 功能特色

- 主畫面上方為搜尋欄位，輸入縣市名稱（例如「臺北市」）後點擊右側
  「確認」按鈕即可查詢。
- 提供 22 個直轄市／縣市的快捷選單，點擊即可直接查詢，降低輸入
  錯誤地區名稱的機率。
- 查詢結果以卡片呈現各時段（通常為 2～3 個 12 小時時段）的天氣現象、
  最高／最低溫、降雨機率、體感舒適度，並依天氣描述顯示對應圖示。
- 支援下拉刷新，重新查詢目前顯示中的地區。
- 完整錯誤處理與提示文字：輸入驗證、網路異常、API 金鑰無效、
  伺服器錯誤、查無地區、資料格式錯誤等情境皆有對應的繁體中文說明。
- Material 3 設計，支援亮色／暗色主題，並針對無障礙（Semantics）
  與鍵盤操作（搜尋鍵送出、Tab 焦點）做了基本優化。

## 畫面狀態

App 依照查詢狀態切換以下四種畫面（對應 `WeatherUiState` 的四個子型別）：

| 狀態 | 對應 Widget | 說明 |
| --- | --- | --- |
| 尚未查詢 | `WeatherInitialView` | 顯示引導文字，提示使用者輸入地區名稱 |
| 查詢中 | `WeatherLoadingView` | 顯示載入中的進度指示與說明文字 |
| 查詢成功 | `WeatherResultView` | 顯示天氣預報卡片列表，可下拉刷新 |
| 查詢失敗 | `WeatherErrorView` | 依失敗原因顯示對應錯誤說明，並視情況提供「重試」按鈕 |

## 技術棧

- **Flutter** 3.44 / **Dart** 3.12（SDK 需求：`^3.12.2`）
- **狀態管理**：[`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod)
  （使用 Riverpod 原生 `Notifier` / `NotifierProvider`，**未使用**
  `hooks_riverpod` 或 `flutter_hooks`）
- **網路請求**：[`dio`](https://pub.dev/packages/dio)
- **值物件相等性**：[`equatable`](https://pub.dev/packages/equatable)
- **測試**：`flutter_test` + [`mocktail`](https://pub.dev/packages/mocktail)

## 專案架構

採分層架構，依「資料層 → 狀態管理 → 呈現層」拆分，方便測試與維護：

```
lib/
├── main.dart                          # 進入點，包上 ProviderScope
└── src/
    ├── app.dart                       # MaterialApp、主題設定
    ├── core/
    │   ├── config/app_config.dart     # 讀取 --dart-define 的 API Key
    │   ├── error/weather_failure.dart # 所有錯誤情境的 sealed class
    │   ├── network/                   # Dio 實例、API 端點常數
    │   ├── theme/app_theme.dart       # Material 3 亮／暗主題
    │   └── utils/date_formatter.dart  # 時間格式化（不依賴 intl）
    └── features/weather/
        ├── data/
        │   ├── models/                # LocationForecast、WeatherPeriod
        │   ├── datasources/           # 呼叫 API、解析／轉換錯誤
        │   ├── repositories/          # 隔離資料來源細節
        │   └── taiwan_locations.dart  # 22 縣市快捷清單
        └── presentation/
            ├── state/                 # WeatherUiState（四種畫面狀態）
            ├── providers/              # WeatherNotifier
            ├── screens/                # WeatherHomeScreen（主畫面）
            └── widgets/                # 四種畫面 Widget、搜尋欄、卡片等
```

資料流向：`WeatherHomeScreen` → 使用者輸入 → `WeatherNotifier.search()` →
`WeatherRepository` → `WeatherRemoteDataSource`（呼叫 Dio）→ 解析為
`LocationForecast` 或拋出對應的 `WeatherFailure` → `WeatherNotifier`
更新 `WeatherUiState` → UI 依狀態重新渲染。

## 開始使用

### 必要條件

- Flutter SDK（建議 3.44 以上，已於 `pubspec.yaml` 設定 `sdk: ^3.12.2`）
- 已設定好的 Android 模擬器或 iOS 模擬器（或實機）
- 中央氣象署開放資料平台的會員帳號與 API Key

### 取得 API Key

前往[中央氣象署開放資料平台](https://opendata.cwa.gov.tw/)註冊帳號並
申請授權碼（Authorization Key）。

> **重要：** 本專案的 API Key **不會**寫死於任何原始碼、設定檔或本文件中，
> 一律透過 Dart 的編譯期環境變數（`--dart-define`）於**執行或測試時**
> 由使用者自行注入，避免金鑰外洩或被提交進版本控制。

### 安裝依賴

```sh
flutter pub get
```

### 執行應用程式

以 `--dart-define` 帶入你自己的 API Key 執行（請將 `你的金鑰` 替換為
實際取得的授權碼）：

```sh
# 列出目前可用的裝置／模擬器
flutter devices

# 在指定裝置上執行（以 Android 模擬器為例）
flutter run -d emulator-5554 --dart-define=CWA_API_KEY=你的金鑰

# 在 iOS 模擬器上執行
flutter run -d "iPhone 17 Pro" --dart-define=CWA_API_KEY=你的金鑰
```

若忘記帶入 `CWA_API_KEY`，App 不會發出任何網路請求，而是直接顯示
「尚未設定中央氣象署開放資料平台 API Key」的錯誤畫面，明確告知原因。

## 執行測試

```sh
flutter test
```

測試不需要（也不應該）連線至真實 API 或帶入真實金鑰——所有網路互動
皆以 `mocktail` 模擬 `Dio` / `Repository`，確保測試快速、穩定且可重複執行。

測試涵蓋：

- **資料解析**（`test/features/weather/data/models`）：合法資料、
  缺少欄位、型別錯誤、地區名稱空白、數值無法轉換、日期格式錯誤等。
- **資料來源與錯誤映射**（`test/features/weather/data/datasources`）：
  缺少 API Key、地區查無資料、`success=false`、非 JSON 回應、
  各類 `DioException`（連線逾時、離線、HTTP 401、HTTP 500）。
- **狀態管理**（`test/features/weather/presentation/providers`）：
  四種狀態的正確轉換、輸入驗證、非預期例外的兜底處理。
- **UI／互動**（`test/features/weather/presentation/widgets`、`screens`）：
  四種畫面的渲染、搜尋流程、快捷選單、鍵盤送出、查詢中防止重複送出、
  下拉刷新。

## 錯誤處理

所有失敗情境統一以 `WeatherFailure`（sealed class，見
`lib/src/core/error/weather_failure.dart`）表示，每個子型別皆附帶
可直接顯示於 UI 的繁體中文說明：

| 情境 | 對應型別 | 使用者看到的訊息（節錄） |
| --- | --- | --- |
| 未輸入地區名稱 | `InvalidInputFailure` | 請輸入要查詢的地區名稱 |
| 未設定 API Key | `MissingApiKeyFailure` | 尚未設定中央氣象署開放資料平台 API Key |
| 網路離線／逾時 | `NetworkFailure` | 網路連線異常，請確認裝置已連上網路 |
| API 金鑰無效（401/403 或 success=false） | `UnauthorizedFailure` | API 金鑰無效或未授權 |
| 伺服器錯誤（5xx 等） | `ServerFailure` | 中央氣象署伺服器發生錯誤 |
| 查無此地區 | `LocationNotFoundFailure` | 查無「OOO」的天氣預報資料 |
| API 回傳資料格式不正確 | `DataParsingFailure` | 取得的天氣資料格式不正確 |
| 其他未預期例外 | `UnknownFailure` | 發生未知錯誤 |

## 設計決策說明

- **API Key 注入方式**：`WeatherRemoteDataSource` 以建構子注入 API Key，
  而非在內部直接讀取全域常數，讓單元測試能輕易替換假金鑰，不需依賴
  編譯期環境變數即可完整覆蓋所有分支。
- **不使用程式碼產生器**：模型的 JSON 解析採手動撰寫（未使用
  `freezed` / `json_serializable`），換取更精準的防呆檢查（例如以
  `startTime`/`endTime` 比對不同天氣要素陣列）與更快的建置速度。
- **不使用 `intl` 套件**：時間格式化改以少量手動邏輯實作
  （`core/utils/date_formatter.dart`），降低相依套件數量。
- **快捷縣市選單**：中央氣象署 API 要求 `locationName` 需與縣市全名
  完全相符，快捷選單可大幅降低使用者因輸入錯誤（例如少打「臺」字）
  而觸發「查無地區」錯誤的機率。

## 已知限制

- 本 App 僅串接「一般天氣預報－今明 36 小時」（`F-C0032-001`），
  不含鄉鎮市區等級或未來一週預報。
- 目前僅提供 Android／iOS 平台設定；未產生 Web／桌面平台專案檔。

## 開發工具說明

本專案的程式碼與文件是與 [Claude Code](https://claude.com/claude-code)
（Anthropic 推出的 CLI 開發代理）協作完成，實際使用方式如下：

- 專案骨架建置：以 `flutter create` 產生 Android／iOS 平台骨架，並由
  Claude Code 加入依賴套件（dio、flutter_riverpod、mocktail 等）與
  嚴格化 `analysis_options.yaml` 靜態分析規則。
- 分層架構與功能實作：由 Claude Code 依「資料層 → 狀態管理 → 呈現層」
  的分層架構，撰寫 API 資料解析、Repository/DataSource、Riverpod
  狀態管理，以及主畫面與四種狀態 Widget。
- 測試撰寫：由 Claude Code 撰寫涵蓋各種正常／錯誤情境的單元測試與
  Widget 測試，並在撰寫過程中實際發現並修正了程式中的真實缺陷。
- 程式碼審查與反覆修正：透過 Claude Code 的 `code-review` 技能，
  分兩輪對整份實作進行嚴格審查，找出競速條件、下拉刷新體驗、資料
  一致性等問題後逐一修正，並補上對應的回歸測試。
- 實機驗證：由 Claude Code 於 Android／iOS 模擬器上實際建置、安裝、
  操作 App，以真實 API Key 驗證各項功能與畫面行為。
- 每一項改動皆拆分為獨立、附有清楚說明的 git commit，方便追溯每個
  階段實際做了什麼調整。
