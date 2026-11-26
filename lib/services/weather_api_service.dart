import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/weather_response_model.dart';

/// Exception khusus untuk kesalahan jaringan atau respons API.
class WeatherApiException implements Exception {
  const WeatherApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Service lapisan jaringan untuk mengambil data cuaca real-time
/// dari Open-Meteo Weather Forecast API menggunakan HTTP GET.
class WeatherApiService {
  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Melakukan HTTP GET ke Open-Meteo Weather Forecast API dengan seluruh
  /// parameter wajib (`latitude`, `longitude`, `current`, `daily`, `timezone=auto`).
  Future<WeatherResponseModel> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(ApiConstants.weatherBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': ApiConstants.currentFields,
        'daily': ApiConstants.dailyFields,
        'timezone': ApiConstants.defaultTimezone,
        'forecast_days': ApiConstants.forecastDays.toString(),
      },
    );

    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(ApiConstants.requestTimeout);

      final responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode != 200) {
        String reason = 'Gagal memuat data cuaca (HTTP ${response.statusCode}).';
        try {
          final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
          if (decoded['reason'] is String) {
            reason = decoded['reason'] as String;
          }
        } catch (_) {
          // Gunakan pesan default jika body error bukan JSON.
        }
        throw WeatherApiException(reason);
      }

      final decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, dynamic>) {
        throw const WeatherApiException(
          'Format data cuaca dari server tidak valid.',
        );
      }

      return WeatherResponseModel.fromJson(decoded);
    } on TimeoutException {
      throw const WeatherApiException(
        'Koneksi ke server Open-Meteo melebihi batas waktu. Periksa koneksi internet Anda.',
      );
    } on SocketException {
      throw const WeatherApiException(
        'Tidak ada koneksi internet. Pastikan perangkat Anda terhubung ke jaringan.',
      );
    } on http.ClientException {
      throw const WeatherApiException(
        'Gagal terhubung ke layanan Open-Meteo. Coba beberapa saat lagi.',
      );
    } on FormatException catch (e) {
      throw WeatherApiException(e.message);
    }
  }

  void dispose() {
    _client.close();
  }
}
