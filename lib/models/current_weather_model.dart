/// Model data cuaca saat ini (`current`) dari Open-Meteo Weather Forecast API.
/// Memuat seluruh 6 field `current.*` wajib sesuai spesifikasi.
class CurrentWeatherModel {
  const CurrentWeatherModel({
    required this.time,
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed10m,
    this.temperatureUnit = '°C',
    this.humidityUnit = '%',
    this.precipitationUnit = 'mm',
    this.windSpeedUnit = 'km/h',
  });

  /// Waktu pengukuran cuaca terkini (ISO-8601).
  final String time;

  /// Field wajib 1: `current.temperature_2m` (Suhu saat ini).
  final double temperature2m;

  /// Field wajib 2: `current.relative_humidity_2m` (Kelembapan udara).
  final int relativeHumidity2m;

  /// Field wajib 3: `current.apparent_temperature` (Suhu yang dirasakan).
  final double apparentTemperature;

  /// Field wajib 4: `current.precipitation` (Curah hujan saat ini).
  final double precipitation;

  /// Field wajib 5: `current.weather_code` (Kode kondisi cuaca WMO).
  final int weatherCode;

  /// Field wajib 6: `current.wind_speed_10m` (Kecepatan angin pada ketinggian 10m).
  final double windSpeed10m;

  final String temperatureUnit;
  final String humidityUnit;
  final String precipitationUnit;
  final String windSpeedUnit;

  /// Deserialisasi objek `current` dan `current_units` dari JSON Open-Meteo.
  factory CurrentWeatherModel.fromJson(
    Map<String, dynamic> currentJson, {
    Map<String, dynamic>? unitsJson,
  }) {
    return CurrentWeatherModel(
      time: (currentJson['time'] as String?) ?? '',
      temperature2m: (currentJson['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity2m:
          (currentJson['relative_humidity_2m'] as num?)?.round() ?? 0,
      apparentTemperature:
          (currentJson['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      precipitation: (currentJson['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (currentJson['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed10m: (currentJson['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      temperatureUnit: (unitsJson?['temperature_2m'] as String?) ?? '°C',
      humidityUnit: (unitsJson?['relative_humidity_2m'] as String?) ?? '%',
      precipitationUnit: (unitsJson?['precipitation'] as String?) ?? 'mm',
      windSpeedUnit: (unitsJson?['wind_speed_10m'] as String?) ?? 'km/h',
    );
  }
}
