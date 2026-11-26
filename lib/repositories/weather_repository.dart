import 'package:material_ui/material_ui.dart';

import '../models/location_model.dart';
import '../models/weather_response_model.dart';
import '../services/geocoding_api_service.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';

/// Repository yang menjadi pintu tunggal bagi lapisan ViewModel untuk mengakses
/// data jaringan (Open-Meteo API) dan penyimpanan lokal (SharedPreferences).
class WeatherRepository {
  WeatherRepository({
    required this._weatherApiService,
    required this._geocodingApiService,
    required this._localStorageService,
  });

  final WeatherApiService _weatherApiService;
  final GeocodingApiService _geocodingApiService;
  final LocalStorageService _localStorageService;

  /// Mengambil cuaca real-time & prakiraan harian untuk suatu lokasi.
  Future<WeatherResponseModel> getWeatherForLocation(LocationModel location) {
    return _weatherApiService.fetchWeather(
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  /// Mencari daftar kota melalui Open-Meteo Geocoding API.
  Future<List<LocationModel>> searchLocations(String query) {
    return _geocodingApiService.searchCities(query);
  }

  /// Mengambil daftar lokasi favorit dari Local Storage.
  Future<List<LocationModel>> loadFavorites() {
    return _localStorageService.getFavoriteLocations();
  }

  /// Menyimpan daftar lokasi favorit ke Local Storage.
  Future<void> saveFavorites(List<LocationModel> favorites) {
    return _localStorageService.saveFavoriteLocations(favorites);
  }

  /// Mengambil riwayat pencarian lokasi dari Local Storage.
  Future<List<LocationModel>> loadSearchHistory() {
    return _localStorageService.getSearchHistory();
  }

  /// Menambahkan lokasi ke riwayat pencarian lokal.
  Future<List<LocationModel>> recordSearchHistory(LocationModel location) {
    return _localStorageService.addToSearchHistory(location);
  }

  /// Menghapus seluruh riwayat pencarian lokal.
  Future<void> clearSearchHistory() {
    return _localStorageService.clearSearchHistory();
  }

  /// Memuat lokasi terakhir yang dilihat pengguna.
  Future<LocationModel?> loadLastLocation() {
    return _localStorageService.getLastSelectedLocation();
  }

  /// Menyimpan lokasi terakhir yang dipilih pengguna.
  Future<void> saveLastLocation(LocationModel location) {
    return _localStorageService.saveLastSelectedLocation(location);
  }

  /// Memuat preferensi tema tersimpan.
  Future<ThemeMode> loadThemeMode() => _localStorageService.getThemeMode();

  /// Menyimpan preferensi tema.
  Future<void> saveThemeMode(ThemeMode mode) =>
      _localStorageService.saveThemeMode(mode);

  /// Menutup resource HTTP client saat repository tidak lagi digunakan.
  void dispose() {
    _weatherApiService.dispose();
    _geocodingApiService.dispose();
  }
}
