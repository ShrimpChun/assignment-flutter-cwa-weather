import 'package:dio/dio.dart';
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

  /// 目前這次請求對應的取消權杖，讓下一個請求可以主動中止前一個
  /// 已確定會被捨棄結果的舊請求，避免浪費網路資源。
  CancelToken? _cancelToken;

  @override
  WeatherUiState build() => const WeatherInitial();

  /// 依使用者輸入的地區名稱查詢天氣。
  ///
  /// 會先在本機驗證輸入是否為空白，避免發出不必要的 API 請求；
  /// 驗證通過後才會依序切換為 [WeatherLoading]，再依結果切換為
  /// [WeatherSuccess] 或 [WeatherError]。
  Future<void> search(String rawInput) async {
    final locationName = rawInput.trim();

    if (locationName.isEmpty) {
      _invalidatePreviousRequest();
      state = const WeatherError(InvalidInputFailure());
      return;
    }

    state = const WeatherLoading();
    await _fetchAndApply(locationName);
  }

  /// 重新查詢目前已顯示的地區（例如下拉刷新）。
  ///
  /// 與 [search] 不同之處：不會先切換為 [WeatherLoading]，讓畫面在
  /// 重新整理期間仍保留原有的天氣資料，改由 `RefreshIndicator` 自身的
  /// 轉圈動畫提示使用者「正在更新」，避免整個結果畫面被 Loading
  /// 畫面取代、造成使用者體感上的閃爍。
  Future<void> refresh(String locationName) => _fetchAndApply(locationName);

  Future<void> _fetchAndApply(String locationName) async {
    final requestId = _invalidatePreviousRequest();
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;

    late final WeatherUiState result;
    try {
      final forecast = await ref
          .read(weatherRepositoryProvider)
          .fetchForecast(locationName, cancelToken: cancelToken);
      result = WeatherSuccess(forecast);
    } on WeatherFailure catch (failure) {
      result = WeatherError(failure);
    } catch (_) {
      result = const WeatherError(UnknownFailure());
    }

    if (requestId == _requestId) {
      state = result;
    }
  }

  /// 取消前一個尚未完成的請求並讓其結果失效，回傳這次新請求的序號。
  int _invalidatePreviousRequest() {
    _cancelToken?.cancel();
    _cancelToken = null;
    return ++_requestId;
  }

  /// 重設回初始狀態（例如使用者清空搜尋欄位時），並取消任何尚未完成的
  /// 查詢請求，避免其結果在重設之後才姍姍來遲地覆蓋畫面。
  void reset() {
    _invalidatePreviousRequest();
    state = const WeatherInitial();
  }
}

final weatherNotifierProvider =
    NotifierProvider<WeatherNotifier, WeatherUiState>(WeatherNotifier.new);
