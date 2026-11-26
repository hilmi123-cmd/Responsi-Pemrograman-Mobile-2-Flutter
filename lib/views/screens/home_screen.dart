import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../viewmodels/view_state.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../widgets/current_weather_hero.dart';
import '../widgets/daily_forecast_section.dart';
import '../widgets/favorite_chips_bar.dart';
import '../widgets/state_feedback_view.dart';
import '../widgets/weather_metrics_grid.dart';
import 'search_location_screen.dart';

/// Screen 1: Home / Weather Screen (`StatefulWidget`).
/// Menampilkan informasi cuaca terkini, detail tambahan, dan prakiraan harian
/// dari Open-Meteo API sesuai lokasi aktif yang dipilih pengguna.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Memuat lokasi tersimpan & favorit dari Local Storage tepat setelah frame pertama.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WeatherViewModel>().initialize();
    });
  }

  Future<void> _openSearchScreen() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const SearchLocationScreen()),
    );
  }

  Future<void> _handleToggleFavorite(
    WeatherViewModel viewModel,
    LocationModel location,
  ) async {
    final added = await viewModel.toggleFavorite(location);
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            added
                ? '${location.name} disimpan ke lokasi favorit.'
                : '${location.name} dihapus dari lokasi favorit.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuaca Open-Meteo'),
        actions: [
          IconButton(
            tooltip: 'Cari Kota & Favorit',
            onPressed: _openSearchScreen,
            icon: const Icon(Icons.search_rounded),
          ),
          Consumer<WeatherViewModel>(
            builder: (context, viewModel, _) {
              final canRefresh =
                  viewModel.selectedLocation != null &&
                  viewModel.state != ViewState.loading;
              return IconButton(
                tooltip: 'Muat Ulang Cuaca',
                onPressed: canRefresh ? viewModel.refreshWeather : null,
                icon: const Icon(Icons.refresh_rounded),
              );
            },
          ),
          IconButton(
            tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
            onPressed: () {
              context.read<ThemeViewModel>().toggleTheme(theme.brightness);
            },
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<WeatherViewModel>(
        builder: (context, viewModel, _) {
          return _buildBody(context, viewModel);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSearchScreen,
        icon: const Icon(Icons.travel_explore_rounded),
        label: const Text('Pilih Kota'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel viewModel) {
    switch (viewModel.state) {
      case ViewState.initial:
      case ViewState.loading:
        final cityName = viewModel.selectedLocation?.name;
        return StateFeedbackView.loading(
          title: cityName != null
              ? 'Memuat Cuaca $cityName...'
              : 'Menyiapkan Aplikasi...',
          message:
              'Mengambil data cuaca real-time dan prakiraan harian dari Open-Meteo API.',
        );

      case ViewState.empty:
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (viewModel.favorites.isNotEmpty) ...[
                    FavoriteChipsBar(
                      favorites: viewModel.favorites,
                      selectedLocation: viewModel.selectedLocation,
                      onSelect: viewModel.selectLocation,
                    ),
                    const SizedBox(height: 16),
                  ],
                  StateFeedbackView.empty(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Belum Ada Kota Dipilih',
                    message:
                        'Cari nama kota secara real-time melalui Open-Meteo Geocoding API untuk melihat kondisi cuaca terkini dan prakiraan 7 hari ke depan.',
                    actionLabel: 'Cari Kota Sekarang',
                    actionIcon: Icons.search_rounded,
                    onAction: _openSearchScreen,
                  ),
                ],
              ),
            ),
          ),
        );

      case ViewState.error:
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (viewModel.favorites.isNotEmpty) ...[
                    FavoriteChipsBar(
                      favorites: viewModel.favorites,
                      selectedLocation: viewModel.selectedLocation,
                      onSelect: viewModel.selectLocation,
                    ),
                    const SizedBox(height: 16),
                  ],
                  StateFeedbackView.error(
                    title: 'Gagal Memuat Cuaca',
                    message:
                        viewModel.errorMessage ??
                        'Tidak dapat terhubung ke Open-Meteo API. Periksa koneksi internet Anda.',
                    onRetry: viewModel.refreshWeather,
                    secondaryActionLabel: 'Ganti Kota',
                    onSecondaryAction: _openSearchScreen,
                  ),
                ],
              ),
            ),
          ),
        );

      case ViewState.loaded:
        final location = viewModel.selectedLocation;
        final weather = viewModel.weather;
        if (location == null || weather == null) {
          return StateFeedbackView.empty(
            title: 'Data Cuaca Kosong',
            message: 'Silakan pilih kota lain untuk melihat prakiraan cuaca.',
            actionLabel: 'Cari Kota',
            actionIcon: Icons.search_rounded,
            onAction: _openSearchScreen,
          );
        }

        return RefreshIndicator(
          onRefresh: viewModel.refreshWeather,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (viewModel.isRefreshing)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: LinearProgressIndicator(minHeight: 3),
                      ),
                    if (viewModel.favorites.isNotEmpty) ...[
                      FavoriteChipsBar(
                        favorites: viewModel.favorites,
                        selectedLocation: location,
                        onSelect: viewModel.selectLocation,
                      ),
                      const SizedBox(height: 16),
                    ],
                    CurrentWeatherHero(
                      location: location,
                      weather: weather,
                      isFavorite: viewModel.isFavorite(location),
                      onToggleFavorite: () =>
                          _handleToggleFavorite(viewModel, location),
                    ),
                    const SizedBox(height: 22),
                    WeatherMetricsGrid(weather: weather),
                    const SizedBox(height: 22),
                    DailyForecastSection(forecasts: weather.daily),
                    const SizedBox(height: 16),
                    Text(
                      'Sumber data real-time: Open-Meteo API • Zona waktu: ${weather.timezone}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    }
  }
}
