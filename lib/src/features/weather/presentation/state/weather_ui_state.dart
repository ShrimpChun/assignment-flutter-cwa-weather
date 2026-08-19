import 'package:equatable/equatable.dart';

import '../../../../core/error/weather_failure.dart';
import '../../data/models/location_forecast.dart';

/// 天氣查詢畫面的四種互斥狀態。
///
/// 對應需求中的四個畫面：
/// - [WeatherInitial]：尚未查詢
/// - [WeatherLoading]：查詢中
/// - [WeatherSuccess]：查詢成功並顯示資料
/// - [WeatherError]：查詢失敗並顯示對應錯誤訊息
sealed class WeatherUiState extends Equatable {
  const WeatherUiState();

  @override
  List<Object?> get props => [];
}

/// 使用者尚未輸入查詢條件時的初始狀態。
final class WeatherInitial extends WeatherUiState {
  const WeatherInitial();
}

/// 正在向中央氣象署 API 發出查詢請求。
final class WeatherLoading extends WeatherUiState {
  const WeatherLoading();
}

/// 查詢成功，附帶該地區的天氣預報資料。
final class WeatherSuccess extends WeatherUiState {
  const WeatherSuccess(this.forecast);

  final LocationForecast forecast;

  @override
  List<Object?> get props => [forecast];
}

/// 查詢失敗，附帶對應的失敗原因。
final class WeatherError extends WeatherUiState {
  const WeatherError(this.failure);

  final WeatherFailure failure;

  @override
  List<Object?> get props => [failure];
}
