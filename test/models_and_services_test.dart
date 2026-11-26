import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:responsi_flutter_weather/models/location_model.dart';
import 'package:responsi_flutter_weather/services/geocoding_api_service.dart';
import 'package:responsi_flutter_weather/services/local_storage_service.dart';
import 'package:responsi_flutter_weather/services/weather_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('WeatherApiService', () {
    test(
      'mengirim HTTP GET dengan parameter wajib Open-Meteo dan mem-parsing 9 field wajib',
      () async {
        late Uri capturedUri;
        late String capturedMethod;

        final mockClient = MockClient((request) async {
          capturedUri = request.url;
          capturedMethod = request.method;

          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'latitude': -7.4243,
                'longitude': 109.2396,
                'timezone': 'Asia/Jakarta',
                'current_units': {
                  'temperature_2m': '°C',
                  'relative_humidity_2m': '%',
                  'apparent_temperature': '°C',
                  'precipitation': 'mm',
                  'weather_code': 'wmo code',
                  'wind_speed_10m': 'km/h',
                },
                'current': {
                  'time': '2026-11-25T18:00',
                  'temperature_2m': 28.6,
                  'relative_humidity_2m': 78,
                  'apparent_temperature': 32.1,
                  'precipitation': 0.5,
                  'weather_code': 61,
                  'wind_speed_10m': 11.4,
                },
                'daily': {
                  'time': ['2026-11-25', '2026-11-26'],
                  'weather_code': [61, 2],
                  'temperature_2m_max': [31.5, 32.0],
                  'temperature_2m_min': [23.4, 24.1],
                  'precipitation_probability_max': [80, 35],
                },
              }),
            ),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final service = WeatherApiService(client: mockClient);
        final result = await service.fetchWeather(
          latitude: -7.4243,
          longitude: 109.2396,
        );

        // Verifikasi metode GET & seluruh parameter wajib
        expect(capturedMethod, 'GET');
        expect(capturedUri.host, 'api.open-meteo.com');
        expect(capturedUri.queryParameters['latitude'], '-7.4243');
        expect(capturedUri.queryParameters['longitude'], '109.2396');
        expect(capturedUri.queryParameters['timezone'], 'auto');

        final currentParam = capturedUri.queryParameters['current'] ?? '';
        expect(currentParam, contains('temperature_2m'));
        expect(currentParam, contains('relative_humidity_2m'));
        expect(currentParam, contains('apparent_temperature'));
        expect(currentParam, contains('precipitation'));
        expect(currentParam, contains('weather_code'));
        expect(currentParam, contains('wind_speed_10m'));

        final dailyParam = capturedUri.queryParameters['daily'] ?? '';
        expect(dailyParam, contains('temperature_2m_max'));
        expect(dailyParam, contains('temperature_2m_min'));
        expect(dailyParam, contains('precipitation_probability_max'));

        // Verifikasi parsing 9 field API wajib dan dekode UTF-8 simbol derajat (°C)
        expect(result.current.temperatureUnit, '°C');
        expect(result.current.temperature2m, 28.6);
        expect(result.current.relativeHumidity2m, 78);
        expect(result.current.apparentTemperature, 32.1);
        expect(result.current.precipitation, 0.5);
        expect(result.current.weatherCode, 61);
        expect(result.current.windSpeed10m, 11.4);
        expect(result.daily.length, 2);
        expect(result.daily.first.temperature2mMax, 31.5);
        expect(result.daily.first.temperature2mMin, 23.4);
        expect(result.daily.first.precipitationProbabilityMax, 80);
      },
    );

    test('melempar WeatherApiException saat server mengembalikan error', () async {
      final mockClient = MockClient(
        (_) async => http.Response('{"error": true, "reason": "Bad request"}', 400),
      );
      final service = WeatherApiService(client: mockClient);

      expect(
        () => service.fetchWeather(latitude: 0, longitude: 0),
        throwsA(isA<WeatherApiException>()),
      );
    });
  });

  group('GeocodingApiService', () {
    test('mencari kota via HTTP GET dan menangani hasil kosong', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.host, 'geocoding-api.open-meteo.com');

        if (request.url.queryParameters['name'] == 'Purwokerto') {
          return http.Response(
            jsonEncode({
              'results': [
                {
                  'id': 1630328,
                  'name': 'Purwokerto',
                  'latitude': -7.42139,
                  'longitude': 109.23444,
                  'country': 'Indonesia',
                  'country_code': 'ID',
                  'admin1': 'Jawa Tengah',
                  'timezone': 'Asia/Jakarta',
                },
              ],
            }),
            200,
          );
        }

        // Respons Open-Meteo ketika tidak ada kota yang cocok
        return http.Response(jsonEncode({'generationtime_ms': 0.4}), 200);
      });

      final service = GeocodingApiService(client: mockClient);
      final found = await service.searchCities('Purwokerto');
      expect(found.length, 1);
      expect(found.first.name, 'Purwokerto');
      expect(found.first.subtitle, 'Jawa Tengah, Indonesia');

      final empty = await service.searchCities('KotaTidakAda12345');
      expect(empty, isEmpty);
    });
  });

  group('LocalStorageService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('menyimpan dan memuat ulang lokasi favorit, riwayat, dan lokasi terakhir', () async {
      final storage = LocalStorageService();
      const purwokerto = LocationModel(
        id: 1630328,
        name: 'Purwokerto',
        latitude: -7.42139,
        longitude: 109.23444,
        country: 'Indonesia',
        admin1: 'Jawa Tengah',
      );

      await storage.saveFavoriteLocations([purwokerto]);
      await storage.addToSearchHistory(purwokerto);
      await storage.saveLastSelectedLocation(purwokerto);

      final loadedFavorites = await storage.getFavoriteLocations();
      final loadedHistory = await storage.getSearchHistory();
      final loadedLast = await storage.getLastSelectedLocation();

      expect(loadedFavorites.length, 1);
      expect(loadedFavorites.first.name, 'Purwokerto');
      expect(loadedHistory.length, 1);
      expect(loadedHistory.first.name, 'Purwokerto');
      expect(loadedLast?.name, 'Purwokerto');
    });
  });
}
