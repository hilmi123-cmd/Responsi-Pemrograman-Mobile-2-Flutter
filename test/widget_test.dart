import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:responsi_flutter_weather/main.dart';
import 'package:responsi_flutter_weather/models/location_model.dart';
import 'package:responsi_flutter_weather/repositories/weather_repository.dart';
import 'package:responsi_flutter_weather/services/geocoding_api_service.dart';
import 'package:responsi_flutter_weather/services/local_storage_service.dart';
import 'package:responsi_flutter_weather/services/weather_api_service.dart';
import 'package:responsi_flutter_weather/views/widgets/location_list_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _sampleWeatherJson() => {
  'latitude': -7.42139,
  'longitude': 109.23444,
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
};

WeatherRepository _buildMockRepository({
  bool Function()? shouldFailWeather,
}) {
  final mockClient = MockClient((request) async {
    if (request.url.host == 'geocoding-api.open-meteo.com') {
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
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    }

    if (shouldFailWeather != null && shouldFailWeather()) {
      return http.Response(
        '{"error": true, "reason": "Server sedang sibuk"}',
        503,
      );
    }

    return http.Response(
      jsonEncode(_sampleWeatherJson()),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });

  return WeatherRepository(
    weatherApiService: WeatherApiService(client: mockClient),
    geocodingApiService: GeocodingApiService(client: mockClient),
    localStorageService: LocalStorageService(),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'Alur lengkap: Empty state -> Cari kota -> Favorit -> Tampil 9 field cuaca di Home',
    (WidgetTester tester) async {
      final repository = _buildMockRepository();
      await tester.pumpWidget(WeatherApp(repository: repository));
      await tester.pumpAndSettle();

      // 1. State kosong saat pertama kali dibuka tanpa lokasi tersimpan
      expect(find.text('Belum Ada Kota Dipilih'), findsOneWidget);

      // 2. Buka Search / Location Screen
      await tester.tap(find.text('Cari Kota Sekarang'));
      await tester.pumpAndSettle();
      expect(find.text('Cari Lokasi & Favorit'), findsOneWidget);

      // 3. Ketik nama kota dan tunggu debounce selesai
      await tester.enterText(find.byType(TextField), 'Purwokerto');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // 4. Hasil Geocoding API muncul, simpan ke favorit lalu pilih kota
      final resultTile = find.byType(LocationListTile);
      expect(resultTile, findsOneWidget);
      expect(
        find.descendant(of: resultTile, matching: find.text('Purwokerto')),
        findsOneWidget,
      );
      await tester.tap(find.byIcon(Icons.star_border_rounded));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(of: resultTile, matching: find.text('Purwokerto')),
      );
      await tester.pumpAndSettle();

      // 5. Home Screen menampilkan seluruh 9 field wajib dari Open-Meteo
      expect(find.text('Purwokerto'), findsWidgets);
      expect(find.text('28.6'), findsOneWidget); // current.temperature_2m
      expect(find.text('Hujan'), findsWidgets); // current.weather_code (61)
      expect(find.text('78%'), findsOneWidget); // current.relative_humidity_2m
      expect(
        find.text('32.1°C'),
        findsOneWidget,
      ); // current.apparent_temperature
      expect(find.text('11.4 km/h'), findsOneWidget); // current.wind_speed_10m
      expect(find.text('0.5 mm'), findsOneWidget); // current.precipitation
      expect(
        find.text('80%'),
        findsWidgets,
      ); // daily.precipitation_probability_max
      expect(find.text('23°'), findsOneWidget); // daily.temperature_2m_min
      expect(find.text('32°'), findsWidgets); // daily.temperature_2m_max
    },
  );

  testWidgets(
    'Error State menampilkan tombol Coba Lagi dan berhasil memuat ulang saat retry',
    (WidgetTester tester) async {
      var fail = true;
      final repository = _buildMockRepository(shouldFailWeather: () => fail);
      await tester.pumpWidget(WeatherApp(repository: repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cari Kota Sekarang'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Purwokerto');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(LocationListTile),
          matching: find.text('Purwokerto'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gagal Memuat Cuaca'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      // Simulasikan koneksi pulih lalu tekan Coba Lagi
      fail = false;
      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      expect(find.text('28.6'), findsOneWidget);
    },
  );

  testWidgets(
    'Memuat ulang otomatis lokasi favorit & terakhir tersimpan pada layar sempit (320x640) tanpa overflow',
    (WidgetTester tester) async {
      const savedCity = LocationModel(
        id: 1630328,
        name: 'Purwokerto',
        latitude: -7.42139,
        longitude: 109.23444,
        country: 'Indonesia',
        admin1: 'Jawa Tengah',
      );
      final storage = LocalStorageService();
      await storage.saveFavoriteLocations([savedCity]);
      await storage.saveLastSelectedLocation(savedCity);

      // Uji pada viewport layar ponsel sempit
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final repository = _buildMockRepository();
      await tester.pumpWidget(WeatherApp(repository: repository));
      await tester.pumpAndSettle();

      // Otomatis memuat cuaca & menampilkan chip favorit tanpa error overflow
      expect(find.text('Lokasi Favorit'), findsOneWidget);
      expect(find.text('28.6'), findsOneWidget);
      expect(find.text('Detail Cuaca Saat Ini'), findsOneWidget);
    },
  );
}
