import 'package:equatable/equatable.dart';

/// 單一時段（通常為 12 小時）的天氣預報資料。
///
/// 對應中央氣象署「一般天氣預報－今明 36 小時」API 中，
/// `Wx`（天氣現象）、`PoP`（降雨機率）、`MinT`（最低溫）、
/// `MaxT`（最高溫）、`CI`（舒適度指數）等要素在同一時間區段的組合。
class WeatherPeriod extends Equatable {
  const WeatherPeriod({
    required this.startTime,
    required this.endTime,
    required this.weatherDescription,
    required this.rainProbabilityPercent,
    required this.minTemperatureCelsius,
    required this.maxTemperatureCelsius,
    required this.comfortIndex,
  });

  /// 該時段起始時間。
  final DateTime startTime;

  /// 該時段結束時間。
  final DateTime endTime;

  /// 天氣現象文字描述，例如「多雲時晴」。
  final String weatherDescription;

  /// 降雨機率（百分比，0～100）。API 若未提供則為 null。
  final int? rainProbabilityPercent;

  /// 最低溫（攝氏）。
  final int minTemperatureCelsius;

  /// 最高溫（攝氏）。
  final int maxTemperatureCelsius;

  /// 舒適度指數文字描述，例如「舒適」。
  final String comfortIndex;

  @override
  List<Object?> get props => [
    startTime,
    endTime,
    weatherDescription,
    rainProbabilityPercent,
    minTemperatureCelsius,
    maxTemperatureCelsius,
    comfortIndex,
  ];
}
