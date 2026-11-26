import 'current_weather_model.dart';
import 'daily_forecast_model.dart';

/// Model respons lengkap dari Open-Meteo Weather Forecast API.
class WeatherResponseModel {
  const WeatherResponseModel({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.current,
    required this.daily,
  });

  final double latitude;
  final double longitude;
  final String timezone;
  final CurrentWeatherModel current;
  final List<DailyForecastModel> daily;

  /// Mengambil peluang hujan maksimum hari ini (`daily[0].precipitation_probability_max`)
  /// untuk ditampilkan pada ringkasan informasi tambahan di Home Screen.
  int get todayPrecipitationProbabilityMax =>
      daily.isNotEmpty ? daily.first.precipitationProbabilityMax : 0;

  /// Deserialisasi JSON lengkap dari Open-Meteo Weather Forecast API.
  factory WeatherResponseModel.fromJson(Map<String, dynamic> json) {
    final currentMap = json['current'] as Map<String, dynamic>?;
    final dailyMap = json['daily'] as Map<String, dynamic>?;

    if (currentMap == null || dailyMap == null) {
      throw const FormatException(
        'Struktur respons Open-Meteo tidak lengkap (objek current/daily tidak ditemukan).',
      );
    }

    return WeatherResponseModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timezone: (json['timezone'] as String?) ?? 'auto',
      current: CurrentWeatherModel.fromJson(
        currentMap,
        unitsJson: json['current_units'] as Map<String, dynamic>?,
      ),
      daily: DailyForecastModel.listFromDailyJson(dailyMap),
    );
  }
}
