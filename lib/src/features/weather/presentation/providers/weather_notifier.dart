import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/weather_failure.dart';
import '../../data/repositories/weather_repository.dart';
import '../state/weather_ui_state.dart';

/// 管理天氣查詢畫面狀態（初始／查詢中／成功／失敗）的狀態管理者。
///
/// 使用 Riverpod 原生的 [Notifier]（非 hooks_riverpod／flutter_hooks），
/// 符合本專案「嚴禁使用 hook」的規範。
class WeatherNotifier extends Notifier<WeatherUiState> {
  /// 遞增的請求序號，用來識別「目前這次呼叫是否仍是最新的查詢」。
  ///
  /// 若使用者連續查詢兩個地區（例如先查「臺北市」又立刻改查「高雄市」），
  /// 網路回應可能不按送出順序抵達；沒有這個保護的話，較舊查詢的回應
  /// 有機率在較新查詢之後才完成，並以過期資料覆蓋掉正確的結果。
  int _requestId = 0;

  @override
  WeatherUiState build() => const WeatherInitial();

  /// 依使用者輸入的地區名稱查詢天氣。
  ///
  /// 會先在本機驗證輸入是否為空白，避免發出不必要的 API 請求；
  /// 驗證通過後才會依序切換為 [WeatherLoading]，再依結果切換為
  /// [WeatherSuccess] 或 [WeatherError]。
  Future<void> search(String rawInput) async {
    final locationName = rawInput.trim();
    final requestId = ++_requestId;

    if (locationName.isEmpty) {
      state = const WeatherError(InvalidInputFailure());
      return;
    }

    state = const WeatherLoading();

    try {
      final forecast = await ref
          .read(weatherRepositoryProvider)
          .fetchForecast(locationName);
      if (requestId != _requestId) return;
      state = WeatherSuccess(forecast);
    } on WeatherFailure catch (failure) {
      if (requestId != _requestId) return;
      state = WeatherError(failure);
    } catch (_) {
      if (requestId != _requestId) return;
      state = const WeatherError(UnknownFailure());
    }
  }

  /// 重設回初始狀態（例如使用者清空搜尋欄位時），並讓任何尚未完成的
  /// 查詢請求失效，避免其結果在重設之後才姍姍來遲地覆蓋畫面。
  void reset() {
    _requestId++;
    state = const WeatherInitial();
  }
}

final weatherNotifierProvider =
    NotifierProvider<WeatherNotifier, WeatherUiState>(WeatherNotifier.new);
