/// Konstanta endpoint dan parameter wajib untuk Open-Meteo API.
class ApiConstants {
  ApiConstants._();

  // Base URL Weather Forecast API Open-Meteo
  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1/forecast';

  // Base URL Geocoding API Open-Meteo untuk pencarian kota
  static const String geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  // Parameter field wajib untuk cuaca saat ini (6 field current.*)
  static const String currentFields =
      'temperature_2m,'
      'relative_humidity_2m,'
      'apparent_temperature,'
      'precipitation,'
      'weather_code,'
      'wind_speed_10m';

  // Parameter field wajib untuk prakiraan harian (3 field daily.* wajib + weather_code)
  static const String dailyFields =
      'weather_code,'
      'temperature_2m_max,'
      'temperature_2m_min,'
      'precipitation_probability_max';

  // Zona waktu wajib menggunakan 'auto' sesuai spesifikasi Open-Meteo
  static const String defaultTimezone = 'auto';

  // Jumlah hari prakiraan cuaca harian yang ditampilkan
  static const int forecastDays = 7;

  // Batas maksimal hasil pencarian kota dari Geocoding API
  static const int geocodingResultCount = 10;

  // Batas waktu tunggu (timeout) HTTP request
  static const Duration requestTimeout = Duration(seconds: 15);
}
