/// 星期幾的中文簡稱，索引對應 [DateTime.weekday]（1=一 … 7=日）。
const List<String> _kWeekdayNames = ['一', '二', '三', '四', '五', '六', '日'];

String _twoDigits(int value) => value.toString().padLeft(2, '0');

/// 將時間格式化為「M/d (週) HH:mm」，例如「8/19 (三) 18:00」。
String formatWeatherDateTime(DateTime time) {
  final weekday = _kWeekdayNames[time.weekday - 1];
  return '${time.month}/${time.day} ($weekday) '
      '${_twoDigits(time.hour)}:${_twoDigits(time.minute)}';
}

/// 將時段格式化為「M/d (週) HH:mm ~ M/d (週) HH:mm」。
String formatWeatherTimeRange(DateTime start, DateTime end) {
  return '${formatWeatherDateTime(start)} ~ ${formatWeatherDateTime(end)}';
}
