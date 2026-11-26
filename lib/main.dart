import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'repositories/weather_repository.dart';
import 'services/geocoding_api_service.dart';
import 'services/local_storage_service.dart';
import 'services/weather_api_service.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WeatherApp());
}

/// Root widget aplikasi (`StatelessWidget`) yang merakit seluruh lapisan MVVM
/// menggunakan [MultiProvider] dan menerapkan Material 3 [AppTheme].
class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key, this.repository});

  /// Opsional: memungkinkan injeksi repository tiruan saat pengujian (testing).
  final WeatherRepository? repository;

  WeatherRepository _createDefaultRepository() {
    return WeatherRepository(
      weatherApiService: WeatherApiService(),
      geocodingApiService: GeocodingApiService(),
      localStorageService: LocalStorageService(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<WeatherRepository>(
          create: (_) => repository ?? _createDefaultRepository(),
          dispose: (_, repo) {
            // Hanya tutup HTTP client jika dibuat oleh aplikasi (bukan injeksi test).
            if (repository == null) {
              repo.dispose();
            }
          },
        ),
        ChangeNotifierProvider<ThemeViewModel>(
          create: (context) =>
              ThemeViewModel(repository: context.read<WeatherRepository>())
                ..initialize(),
        ),
        ChangeNotifierProvider<WeatherViewModel>(
          create: (context) =>
              WeatherViewModel(repository: context.read<WeatherRepository>()),
        ),
        ChangeNotifierProvider<SearchViewModel>(
          create: (context) =>
              SearchViewModel(repository: context.read<WeatherRepository>()),
        ),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVm, _) {
          return MaterialApp(
            title: 'Cuaca Open-Meteo',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeVm.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
