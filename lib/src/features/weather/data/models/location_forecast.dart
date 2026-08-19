import 'package:equatable/equatable.dart';

import '../../../../core/error/weather_failure.dart';
import 'weather_period.dart';

/// 單一地區的天氣預報資料，包含地區名稱與其下各時段預報。
class LocationForecast extends Equatable {
  const LocationForecast({required this.locationName, required this.periods});

  /// 地區名稱，例如「臺北市」。
  final String locationName;

  /// 依時間排序的時段預報列表（今明 36 小時通常為 3 個時段）。
  final List<WeatherPeriod> periods;

  @override
  List<Object?> get props => [locationName, periods];

  /// 將 API `records.location[i]` 這一層的原始 JSON 轉換為 [LocationForecast]。
  ///
  /// 中央氣象署 API 將天氣現象（Wx）、降雨機率（PoP）、最低溫（MinT）、
  /// 最高溫（MaxT）、舒適度（CI）拆成各自獨立的陣列，須以 `startTime` /
  /// `endTime` 互相比對後才能組成單一時段的完整預報。只要資料形狀不符合
  /// 預期（缺少必要欄位、型別錯誤等），一律拋出 [DataParsingFailure]，
  /// 讓上層能安全地轉為錯誤畫面，而不是讓例外未經處理往外傳播。
  factory LocationForecast.fromJson(Map<String, dynamic> json) {
    final rawLocationName = json['locationName'];
    if (rawLocationName is! String || rawLocationName.trim().isEmpty) {
      throw const DataParsingFailure();
    }

    final weatherElement = json['weatherElement'];
    if (weatherElement is! List) {
      throw const DataParsingFailure();
    }

    final elementsByName = <String, List<dynamic>>{};
    for (final element in weatherElement) {
      if (element is! Map<String, dynamic>) continue;
      final name = element['elementName'];
      final time = element['time'];
      if (name is String && time is List) {
        elementsByName[name] = time;
      }
    }

    const requiredElements = ['Wx', 'MinT', 'MaxT', 'CI'];
    for (final name in requiredElements) {
      final times = elementsByName[name];
      if (times == null || times.isEmpty) {
        throw const DataParsingFailure();
      }
    }

    final wxTimes = elementsByName['Wx']!;
    final periods = <WeatherPeriod>[];

    for (final wxEntry in wxTimes) {
      if (wxEntry is! Map<String, dynamic>) {
        throw const DataParsingFailure();
      }

      final startTime = _parseDateTime(wxEntry['startTime']);
      final endTime = _parseDateTime(wxEntry['endTime']);

      periods.add(
        WeatherPeriod(
          startTime: startTime,
          endTime: endTime,
          weatherDescription: _parameterName(wxEntry),
          rainProbabilityPercent: elementsByName['PoP'] == null
              ? null
              : _matchingNullableIntParameter(
                  elementsByName['PoP']!,
                  startTime,
                  endTime,
                ),
          minTemperatureCelsius: _matchingIntParameter(
            elementsByName['MinT']!,
            startTime,
            endTime,
          ),
          maxTemperatureCelsius: _matchingIntParameter(
            elementsByName['MaxT']!,
            startTime,
            endTime,
          ),
          comfortIndex: _matchingStringParameter(
            elementsByName['CI']!,
            startTime,
            endTime,
          ),
        ),
      );
    }

    if (periods.isEmpty) {
      throw const DataParsingFailure();
    }

    return LocationForecast(
      locationName: rawLocationName.trim(),
      periods: periods,
    );
  }

  static DateTime? _tryParseDateTime(Object? value) {
    if (value is! String) return null;
    return DateTime.tryParse(value);
  }

  static DateTime _parseDateTime(Object? value) {
    final parsed = _tryParseDateTime(value);
    if (parsed == null) {
      throw const DataParsingFailure();
    }
    return parsed;
  }

  /// 依 `startTime`/`endTime` 在 [entries] 中尋找對應時段的原始資料。
  ///
  /// 刻意不做「找不到相符時間就退而使用相同索引」之類的備援：中央氣象署
  /// 這支 API 的各天氣要素（Wx/PoP/MinT/MaxT/CI）在正常情況下時間區段
  /// 必定一致，若真的對不上，代表資料本身有異常，寧可整筆視為格式錯誤
  /// （見呼叫端的 [DataParsingFailure]），也不要靜默配對到錯誤的時段。
  static Map<String, dynamic>? _findMatchingEntry(
    List<dynamic> entries,
    DateTime startTime,
    DateTime endTime,
  ) {
    for (final entry in entries) {
      if (entry is! Map<String, dynamic>) continue;
      final entryStart = _tryParseDateTime(entry['startTime']);
      final entryEnd = _tryParseDateTime(entry['endTime']);
      if (entryStart == startTime && entryEnd == endTime) {
        return entry;
      }
    }
    return null;
  }

  static String _parameterName(Map<String, dynamic> entry) {
    final parameter = entry['parameter'];
    if (parameter is! Map<String, dynamic>) {
      throw const DataParsingFailure();
    }
    final name = parameter['parameterName'];
    if (name is! String || name.isEmpty) {
      throw const DataParsingFailure();
    }
    return name;
  }

  static int _matchingIntParameter(
    List<dynamic> entries,
    DateTime startTime,
    DateTime endTime,
  ) {
    final entry = _findMatchingEntry(entries, startTime, endTime);
    if (entry == null) {
      throw const DataParsingFailure();
    }
    final value = int.tryParse(_parameterName(entry));
    if (value == null) {
      throw const DataParsingFailure();
    }
    return value;
  }

  static String _matchingStringParameter(
    List<dynamic> entries,
    DateTime startTime,
    DateTime endTime,
  ) {
    final entry = _findMatchingEntry(entries, startTime, endTime);
    if (entry == null) {
      throw const DataParsingFailure();
    }
    return _parameterName(entry);
  }

  static int? _matchingNullableIntParameter(
    List<dynamic> entries,
    DateTime startTime,
    DateTime endTime,
  ) {
    final entry = _findMatchingEntry(entries, startTime, endTime);
    if (entry == null) return null;
    final parameter = entry['parameter'];
    if (parameter is! Map<String, dynamic>) return null;
    final name = parameter['parameterName'];
    if (name is! String) return null;
    return int.tryParse(name);
  }
}
