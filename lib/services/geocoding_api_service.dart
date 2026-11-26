import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/location_model.dart';
import 'weather_api_service.dart';

/// Service lapisan jaringan untuk pencarian kota berdasarkan nama
/// menggunakan Open-Meteo Geocoding API (HTTP GET).
class GeocodingApiService {
  GeocodingApiService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  /// Mencari daftar lokasi sesuai kata kunci [query] dari Open-Meteo Geocoding API.
  /// Mengembalikan list kosong jika kota tidak ditemukan.
  Future<List<LocationModel>> searchCities(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return const [];

    final uri = Uri.parse(ApiConstants.geocodingBaseUrl).replace(
      queryParameters: {
        'name': trimmedQuery,
        'count': ApiConstants.geocodingResultCount.toString(),
        'language': 'id',
        'format': 'json',
      },
    );

    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode != 200) {
        throw WeatherApiException(
          'Gagal mencari lokasi (HTTP ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const WeatherApiException(
          'Format respons pencarian lokasi tidak valid.',
        );
      }

      // Open-Meteo tidak menyertakan key 'results' apabila pencarian tidak menemukan hasil.
      final results = decoded['results'];
      if (results is! List<dynamic>) {
        return const [];
      }

      return results
          .whereType<Map<String, dynamic>>()
          .map(LocationModel.fromJson)
          .toList();
    } on TimeoutException {
      throw const WeatherApiException(
        'Pencarian lokasi melebihi batas waktu. Periksa koneksi internet Anda.',
      );
    } on SocketException {
      throw const WeatherApiException(
        'Tidak ada koneksi internet untuk mencari lokasi.',
      );
    } on http.ClientException {
      throw const WeatherApiException(
        'Gagal menghubungi Open-Meteo Geocoding API.',
      );
    } on FormatException {
      throw const WeatherApiException(
        'Gagal membaca hasil pencarian lokasi dari server.',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
