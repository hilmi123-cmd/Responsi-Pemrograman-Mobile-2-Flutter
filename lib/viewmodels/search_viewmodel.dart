import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../repositories/weather_repository.dart';
import '../services/weather_api_service.dart';
import 'view_state.dart';

/// ViewModel untuk Search / Location Screen.
/// Menangani pencarian kota real-time ke Open-Meteo Geocoding API
/// serta pengelolaan riwayat pencarian di Local Storage.
class SearchViewModel extends ChangeNotifier {
  SearchViewModel({required this._repository});

  final WeatherRepository _repository;

  ViewState _searchState = ViewState.initial;
  String _query = '';
  List<LocationModel> _searchResults = const [];
  List<LocationModel> _searchHistory = const [];
  String? _errorMessage;
  int _activeRequestId = 0;

  ViewState get searchState => _searchState;
  String get query => _query;
  List<LocationModel> get searchResults => List.unmodifiable(_searchResults);
  List<LocationModel> get searchHistory => List.unmodifiable(_searchHistory);
  String? get errorMessage => _errorMessage;

  /// Memuat riwayat pencarian lokasi yang tersimpan di Local Storage.
  Future<void> loadHistory() async {
    _searchHistory = await _repository.loadSearchHistory();
    notifyListeners();
  }

  /// Melakukan pencarian kota ke Open-Meteo Geocoding API.
  /// Menggunakan [_activeRequestId] agar respons lama tidak menimpa hasil terbaru.
  Future<void> searchCities(String input) async {
    final trimmed = input.trim();
    _query = trimmed;

    if (trimmed.isEmpty) {
      clearSearch();
      return;
    }

    if (trimmed.length < 2) {
      _searchResults = const [];
      _errorMessage = null;
      _searchState = ViewState.initial;
      notifyListeners();
      return;
    }

    final requestId = ++_activeRequestId;
    _searchState = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.searchLocations(trimmed);
      if (requestId != _activeRequestId) return;

      _searchResults = results;
      _searchState = results.isEmpty ? ViewState.empty : ViewState.loaded;
      _errorMessage = null;
    } on WeatherApiException catch (e) {
      if (requestId != _activeRequestId) return;
      _searchResults = const [];
      _errorMessage = e.message;
      _searchState = ViewState.error;
    } catch (_) {
      if (requestId != _activeRequestId) return;
      _searchResults = const [];
      _errorMessage = 'Terjadi kesalahan saat mencari kota. Silakan coba lagi.';
      _searchState = ViewState.error;
    }

    notifyListeners();
  }

  /// Mengulangi pencarian terakhir ketika pengguna menekan tombol "Coba Lagi".
  Future<void> retryLastSearch() async {
    if (_query.isNotEmpty) {
      await searchCities(_query);
    }
  }

  /// Menyimpan lokasi yang dipilih ke riwayat pencarian di Local Storage.
  Future<void> recordSelectedLocation(LocationModel location) async {
    _searchHistory = await _repository.recordSearchHistory(location);
    notifyListeners();
  }

  /// Menghapus seluruh riwayat pencarian lokal.
  Future<void> clearHistory() async {
    await _repository.clearSearchHistory();
    _searchHistory = const [];
    notifyListeners();
  }

  /// Mengosongkan input dan hasil pencarian aktif.
  void clearSearch() {
    _activeRequestId++;
    _query = '';
    _searchResults = const [];
    _errorMessage = null;
    _searchState = ViewState.initial;
    notifyListeners();
  }
}
