/// Model satu hari prakiraan cuaca (`daily`) dari Open-Meteo Weather Forecast API.
/// Memuat seluruh 3 field `daily.*` wajib (`temperature_2m_max`, `temperature_2m_min`,
/// `precipitation_probability_max`) beserta tanggal dan `weather_code`.
class DailyForecastModel {
  const DailyForecastModel({
    required this.date,
    required this.weatherCode,
    required this.temperature2mMax,
    required this.temperature2mMin,
    required this.precipitationProbabilityMax,
  });

  /// Tanggal prakiraan (`daily.time`, format `YYYY-MM-DD`).
  final String date;

  /// Kode cuaca harian (`daily.weather_code`) untuk menampilkan ikon prakiraan.
  final int weatherCode;

  /// Field wajib 7: `daily.temperature_2m_max` (Suhu maksimum harian).
  final double temperature2mMax;

  /// Field wajib 8: `daily.temperature_2m_min` (Suhu minimum harian).
  final double temperature2mMin;

  /// Field wajib 9: `daily.precipitation_probability_max` (Peluang hujan maksimum harian).
  final int precipitationProbabilityMax;

  /// Memetakan struktur array paralel `daily` dari Open-Meteo menjadi List model harian.
  static List<DailyForecastModel> listFromDailyJson(
    Map<String, dynamic> dailyJson,
  ) {
    final times = (dailyJson['time'] as List<dynamic>?) ?? const [];
    final weatherCodes =
        (dailyJson['weather_code'] as List<dynamic>?) ?? const [];
    final maxTemps =
        (dailyJson['temperature_2m_max'] as List<dynamic>?) ?? const [];
    final minTemps =
        (dailyJson['temperature_2m_min'] as List<dynamic>?) ?? const [];
    final precipProbs =
        (dailyJson['precipitation_probability_max'] as List<dynamic>?) ??
        const [];

    final count = times.length;
    final forecasts = <DailyForecastModel>[];

    for (var i = 0; i < count; i++) {
      forecasts.add(
        DailyForecastModel(
          date: times[i]?.toString() ?? '',
          weatherCode: i < weatherCodes.length
              ? (weatherCodes[i] as num?)?.toInt() ?? 0
              : 0,
          temperature2mMax: i < maxTemps.length
              ? (maxTemps[i] as num?)?.toDouble() ?? 0.0
              : 0.0,
          temperature2mMin: i < minTemps.length
              ? (minTemps[i] as num?)?.toDouble() ?? 0.0
              : 0.0,
          precipitationProbabilityMax: i < precipProbs.length
              ? (precipProbs[i] as num?)?.round() ?? 0
              : 0,
        ),
      );
    }

    return forecasts;
  }
}
