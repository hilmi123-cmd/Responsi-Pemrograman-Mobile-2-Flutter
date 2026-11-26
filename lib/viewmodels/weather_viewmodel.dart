import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../models/weather_response_model.dart';
import '../repositories/weather_repository.dart';
import '../services/weather_api_service.dart';
import 'view_state.dart';

/// ViewModel utama untuk Home / Weather Screen serta manajemen lokasi favorit.
/// Mengelola siklus state: loading, loaded, empty, dan error.
class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel({required this._repository});

  final WeatherRepository _repository;

  ViewState _state = ViewState.initial;
  LocationModel? _selectedLocation;
  WeatherResponseModel? _weather;
  List<LocationModel> _favorites = const [];
  String? _errorMessage;
  bool _isRefreshing = false;
  int _activeRequestId = 0;

  ViewState get state => _state;
  LocationModel? get selectedLocation => _selectedLocation;
  WeatherResponseModel? get weather => _weather;
  List<LocationModel> get favorites => List.unmodifiable(_favorites);
  String? get errorMessage => _errorMessage;
  bool get isRefreshing => _isRefreshing;

  /// Memeriksa apakah [location] sudah tersimpan di daftar favorit.
  bool isFavorite(LocationModel location) {
    return _favorites.any((fav) => fav.isSameLocation(location));
  }

  /// Memuat data tersimpan dari Local Storage saat aplikasi pertama kali dibuka.
  /// Jika lokasi terakhir atau lokasi favorit tersedia, langsung mengambil cuaca
  /// real-time dari Open-Meteo. Jika belum ada, menampilkan state kosong (empty).
  Future<void> initialize() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _favorites = await _repository.loadFavorites();
      final lastLocation = await _repository.loadLastLocation();
      final initialLocation =
          lastLocation ?? (_favorites.isNotEmpty ? _favorites.first : null);

      if (initialLocation == null) {
        _selectedLocation = null;
        _weather = null;
        _state = ViewState.empty;
        notifyListeners();
        return;
      }

      await selectLocation(initialLocation, saveToStorage: false);
    } catch (e) {
      _errorMessage = 'Gagal memuat data lokal: $e';
      _state = ViewState.error;
      notifyListeners();
    }
  }

  /// Memilih kota baru, menyimpannya sebagai lokasi terakhir di Local Storage,
  /// lalu mengambil data cuaca real-time dari Open-Meteo Weather Forecast API.
  Future<void> selectLocation(
    LocationModel location, {
    bool saveToStorage = true,
  }) async {
    final isDifferentCity =
        _selectedLocation == null || !_selectedLocation!.isSameLocation(location);

    _selectedLocation = location;
    if (isDifferentCity) {
      _weather = null;
    }
    _errorMessage = null;
    _isRefreshing = false;
    _state = ViewState.loading;
    notifyListeners();

    if (saveToStorage) {
      await _repository.saveLastLocation(location);
    }

    await _fetchWeatherInternal(location);
  }

  /// Memperbarui data cuaca kota yang sedang aktif (pull-to-refresh atau retry).
  Future<void> refreshWeather() async {
    final location = _selectedLocation;
    if (location == null) {
      _state = ViewState.empty;
      notifyListeners();
      return;
    }

    if (_state == ViewState.loaded && _weather != null) {
      _isRefreshing = true;
      notifyListeners();
    } else {
      _state = ViewState.loading;
      _errorMessage = null;
      notifyListeners();
    }

    await _fetchWeatherInternal(location);
    _isRefreshing = false;
    notifyListeners();
  }

  /// Menambah atau menghapus lokasi dari daftar favorit dan menyimpannya ke Local Storage.
  /// Mengembalikan `true` jika lokasi ditambahkan ke favorit, `false` jika dihapus.
  Future<bool> toggleFavorite(LocationModel location) async {
    final exists = isFavorite(location);
    final updated = exists
        ? _favorites.where((fav) => !fav.isSameLocation(location)).toList()
        : <LocationModel>[location, ..._favorites];

    _favorites = updated;
    notifyListeners();

    await _repository.saveFavorites(updated);
    return !exists;
  }

  /// Menghapus lokasi tertentu dari daftar favorit.
  Future<void> removeFavorite(LocationModel location) async {
    if (!isFavorite(location)) return;
    _favorites = _favorites
        .where((fav) => !fav.isSameLocation(location))
        .toList();
    notifyListeners();
    await _repository.saveFavorites(_favorites);
  }

  Future<void> _fetchWeatherInternal(LocationModel location) async {
    final requestId = ++_activeRequestId;

    try {
      final response = await _repository.getWeatherForLocation(location);
      if (requestId != _activeRequestId) return;

      if (response.daily.isEmpty) {
        _weather = null;
        _state = ViewState.empty;
      } else {
        _weather = response;
        _state = ViewState.loaded;
      }
      _errorMessage = null;
    } on WeatherApiException catch (e) {
      if (requestId != _activeRequestId) return;
      _errorMessage = e.message;
      _state = ViewState.error;
    } catch (_) {
      if (requestId != _activeRequestId) return;
      _errorMessage =
          'Terjadi kesalahan tak terduga saat memuat data cuaca. Silakan coba lagi.';
      _state = ViewState.error;
    }

    notifyListeners();
  }
}
