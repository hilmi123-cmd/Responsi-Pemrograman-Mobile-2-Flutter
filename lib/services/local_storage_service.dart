import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';

/// Service penyimpanan lokal menggunakan [SharedPreferences] untuk menyimpan:
/// 1. Daftar lokasi favorit
/// 2. Riwayat pencarian kota
/// 3. Lokasi terakhir yang dipilih pengguna
/// 4. Preferensi tema (Light / Dark / System)
class LocalStorageService {
  static const String _favoritesKey = 'favorite_locations_v1';
  static const String _historyKey = 'search_history_v1';
  static const String _lastLocationKey = 'last_selected_location_v1';
  static const String _themeModeKey = 'app_theme_mode_v1';
  static const int _maxHistoryItems = 8;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Memuat seluruh lokasi favorit yang tersimpan.
  Future<List<LocationModel>> getFavoriteLocations() async {
    final prefs = await _prefs;
    return _decodeLocationList(prefs.getStringList(_favoritesKey));
  }

  /// Menyimpan daftar lokasi favorit secara persisten.
  Future<void> saveFavoriteLocations(List<LocationModel> locations) async {
    final prefs = await _prefs;
    final encoded = locations.map((loc) => jsonEncode(loc.toJson())).toList();
    await prefs.setStringList(_favoritesKey, encoded);
  }

  /// Memuat riwayat pencarian lokasi yang pernah dipilih pengguna.
  Future<List<LocationModel>> getSearchHistory() async {
    final prefs = await _prefs;
    return _decodeLocationList(prefs.getStringList(_historyKey));
  }

  /// Menambahkan lokasi ke bagian paling atas riwayat pencarian (tanpa duplikasi).
  Future<List<LocationModel>> addToSearchHistory(LocationModel location) async {
    final current = await getSearchHistory();
    final updated = <LocationModel>[
      location,
      ...current.where((item) => !item.isSameLocation(location)),
    ];

    final trimmed = updated.take(_maxHistoryItems).toList();
    final prefs = await _prefs;
    await prefs.setStringList(
      _historyKey,
      trimmed.map((loc) => jsonEncode(loc.toJson())).toList(),
    );
    return trimmed;
  }

  /// Menghapus seluruh riwayat pencarian.
  Future<void> clearSearchHistory() async {
    final prefs = await _prefs;
    await prefs.remove(_historyKey);
  }

  /// Memuat lokasi terakhir yang dibuka agar tampil kembali saat aplikasi dibuka ulang.
  Future<LocationModel?> getLastSelectedLocation() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_lastLocationKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return LocationModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  /// Menyimpan lokasi yang sedang dipilih pengguna.
  Future<void> saveLastSelectedLocation(LocationModel location) async {
    final prefs = await _prefs;
    await prefs.setString(_lastLocationKey, jsonEncode(location.toJson()));
  }

  /// Memuat preferensi mode tema aplikasi.
  Future<ThemeMode> getThemeMode() async {
    final prefs = await _prefs;
    final stored = prefs.getString(_themeModeKey);
    switch (stored) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Menyimpan preferensi mode tema aplikasi.
  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await _prefs;
    await prefs.setString(_themeModeKey, mode.name);
  }

  List<LocationModel> _decodeLocationList(List<String>? rawList) {
    if (rawList == null || rawList.isEmpty) return const [];
    final results = <LocationModel>[];
    for (final raw in rawList) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        results.add(LocationModel.fromJson(decoded));
      } catch (_) {
        // Lewati entri rusak jika ada tanpa menghentikan proses pemuatan.
      }
    }
    return results;
  }
}
