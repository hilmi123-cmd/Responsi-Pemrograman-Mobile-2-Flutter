import 'package:material_ui/material_ui.dart';

import '../repositories/weather_repository.dart';

/// ViewModel ringan untuk mengelola preferensi mode tema (Light / Dark / System).
class ThemeViewModel extends ChangeNotifier {
  ThemeViewModel({required this._repository});

  final WeatherRepository _repository;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> initialize() async {
    _themeMode = await _repository.loadThemeMode();
    notifyListeners();
  }

  Future<void> toggleTheme(Brightness activeBrightness) async {
    _themeMode = activeBrightness == Brightness.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
    await _repository.saveThemeMode(_themeMode);
  }
}
