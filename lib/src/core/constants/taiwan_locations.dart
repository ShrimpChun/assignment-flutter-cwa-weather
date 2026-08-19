/// 用於錯誤訊息中示範正確輸入格式的地區名稱。
///
/// 定義成獨立常數（而非直接在錯誤文字裡寫死字串、或以
/// `kTaiwanLocations[i]` 索引取值）有兩個原因：
/// 1. Dart 的 `const` 建構子不允許在編譯期常數運算式中對 List 取索引，
///    這幾個名稱又需要用於 `WeatherFailure` 的 `const` 建構子中；
/// 2. 讓下方 [kTaiwanLocations] 清單與錯誤訊息共用同一份字面值，
///    避免兩處各自維護、日後改其中一處卻忘了改另一處。
const String kExampleLocationNameA = '臺北市';
const String kExampleLocationNameB = '臺中市';
const String kExampleLocationNameC = '高雄市';

/// 中央氣象署「一般天氣預報」API 所支援的 22 個直轄市／縣市名稱。
///
/// 用於主畫面提供快速選取的建議清單，協助使用者輸入正確、
/// 與 API 完全相符的地區名稱，降低「查無地區」錯誤發生的機率。
const List<String> kTaiwanLocations = [
  kExampleLocationNameA, // 臺北市
  '新北市',
  '桃園市',
  kExampleLocationNameB, // 臺中市
  '臺南市',
  kExampleLocationNameC, // 高雄市
  '基隆市',
  '新竹市',
  '新竹縣',
  '苗栗縣',
  '彰化縣',
  '南投縣',
  '雲林縣',
  '嘉義市',
  '嘉義縣',
  '屏東縣',
  '宜蘭縣',
  '花蓮縣',
  '臺東縣',
  '澎湖縣',
  '金門縣',
  '連江縣',
];
