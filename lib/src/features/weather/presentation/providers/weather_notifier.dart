import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/weather_failure.dart';
import '../../data/repositories/weather_repository.dart';
import '../state/weather_ui_state.dart';

/// 管理天氣查詢畫面狀態（初始／查詢中／成功／失敗）的狀態管理者。
///
/// 使用 Riverpod 原生的 [Notifier]（非 hooks_riverpod／flutter_hooks），
/// 符合本專案「嚴禁使用 hook」的規範。
class WeatherNotifier extends Notifier<WeatherUiState> {
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
      state = const WeatherError(InvalidInputFailure());
      return;
    }

    state = const WeatherLoading();

    try {
      final forecast = await ref
          .read(weatherRepositoryProvider)
          .fetchForecast(locationName);
      state = WeatherSuccess(forecast);
    } on WeatherFailure catch (failure) {
      state = WeatherError(failure);
    } catch (_) {
      state = const WeatherError(UnknownFailure());
    }
  }

  /// 重設回初始狀態（例如使用者清空搜尋欄位時）。
  void reset() {
    state = const WeatherInitial();
  }
}

final weatherNotifierProvider =
    NotifierProvider<WeatherNotifier, WeatherUiState>(WeatherNotifier.new);
