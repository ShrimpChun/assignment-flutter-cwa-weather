/// 測試用的中央氣象署 F-C0032-001 API 回應 JSON fixtures。
library;

Map<String, dynamic> validForecastResponse({String locationName = '臺北市'}) {
  return {
    'success': 'true',
    'records': {
      'location': [
        {
          'locationName': locationName,
          'weatherElement': [
            {
              'elementName': 'Wx',
              'time': [
                {
                  'startTime': '2026-08-19 18:00:00',
                  'endTime': '2026-08-20 06:00:00',
                  'parameter': {'parameterName': '多雲', 'parameterValue': '4'},
                },
                {
                  'startTime': '2026-08-20 06:00:00',
                  'endTime': '2026-08-20 18:00:00',
                  'parameter': {
                    'parameterName': '晴時多雲',
                    'parameterValue': '2',
                  },
                },
              ],
            },
            {
              'elementName': 'PoP',
              'time': [
                {
                  'startTime': '2026-08-19 18:00:00',
                  'endTime': '2026-08-20 06:00:00',
                  'parameter': {
                    'parameterName': '20',
                    'parameterUnit': '百分比',
                  },
                },
                {
                  'startTime': '2026-08-20 06:00:00',
                  'endTime': '2026-08-20 18:00:00',
                  'parameter': {
                    'parameterName': '10',
                    'parameterUnit': '百分比',
                  },
                },
              ],
            },
            {
              'elementName': 'MinT',
              'time': [
                {
                  'startTime': '2026-08-19 18:00:00',
                  'endTime': '2026-08-20 06:00:00',
                  'parameter': {'parameterName': '26', 'parameterUnit': 'C'},
                },
                {
                  'startTime': '2026-08-20 06:00:00',
                  'endTime': '2026-08-20 18:00:00',
                  'parameter': {'parameterName': '25', 'parameterUnit': 'C'},
                },
              ],
            },
            {
              'elementName': 'MaxT',
              'time': [
                {
                  'startTime': '2026-08-19 18:00:00',
                  'endTime': '2026-08-20 06:00:00',
                  'parameter': {'parameterName': '30', 'parameterUnit': 'C'},
                },
                {
                  'startTime': '2026-08-20 06:00:00',
                  'endTime': '2026-08-20 18:00:00',
                  'parameter': {'parameterName': '32', 'parameterUnit': 'C'},
                },
              ],
            },
            {
              'elementName': 'CI',
              'time': [
                {
                  'startTime': '2026-08-19 18:00:00',
                  'endTime': '2026-08-20 06:00:00',
                  'parameter': {'parameterName': '舒適'},
                },
                {
                  'startTime': '2026-08-20 06:00:00',
                  'endTime': '2026-08-20 18:00:00',
                  'parameter': {'parameterName': '悶熱'},
                },
              ],
            },
          ],
        },
      ],
    },
  };
}

Map<String, dynamic> emptyLocationResponse() => {
  'success': 'true',
  'records': {'location': <dynamic>[]},
};

Map<String, dynamic> unauthorizedResponse() => {
  'success': 'false',
  'records': <String, dynamic>{},
};
