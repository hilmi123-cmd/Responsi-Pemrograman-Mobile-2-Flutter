import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../../viewmodels/view_state.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../widgets/location_list_tile.dart';
import '../widgets/state_feedback_view.dart';

/// Screen 2: Search / Location Screen (`StatefulWidget`).
/// Menyediakan input pencarian kota real-time via Open-Meteo Geocoding API,
/// pemilihan kota untuk ditampilkan di Home Screen, pengelolaan lokasi favorit,
/// serta riwayat pencarian yang tersimpan di Local Storage.
class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final searchVm = context.read<SearchViewModel>();
      searchVm.clearSearch();
      searchVm.loadHistory();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() {});
    _debounceTimer?.cancel();

    if (value.trim().isEmpty) {
      context.read<SearchViewModel>().clearSearch();
      return;
    }

    // Debounce 450ms agar tidak membanjiri Open-Meteo Geocoding API saat mengetik.
    _debounceTimer = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      context.read<SearchViewModel>().searchCities(value);
    });
  }

  void _onSearchSubmitted(String value) {
    _debounceTimer?.cancel();
    context.read<SearchViewModel>().searchCities(value);
  }

  void _clearSearchField() {
    _debounceTimer?.cancel();
    _searchController.clear();
    setState(() {});
    context.read<SearchViewModel>().clearSearch();
    _searchFocusNode.requestFocus();
  }

  Future<void> _selectLocation(LocationModel location) async {
    final searchVm = context.read<SearchViewModel>();
    final weatherVm = context.read<WeatherViewModel>();

    await searchVm.recordSelectedLocation(location);
    // Mulai request cuaca dan langsung kembali ke Home Screen.
    unawaited(weatherVm.selectLocation(location));

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _toggleFavorite(LocationModel location) async {
    final added = await context.read<WeatherViewModel>().toggleFavorite(
      location,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            added
                ? '${location.name} ditambahkan ke favorit.'
                : '${location.name} dihapus dari favorit.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasInput = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Cari Lokasi & Favorit')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            children: [
              // Kolom pencarian kota
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  textInputAction: TextInputAction.search,
                  onChanged: _onQueryChanged,
                  onSubmitted: _onSearchSubmitted,
                  decoration: InputDecoration(
                    hintText: 'Cari nama kota (misal: Purwokerto, Jakarta)...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: hasInput
                        ? IconButton(
                            tooltip: 'Bersihkan pencarian',
                            onPressed: _clearSearchField,
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                  ),
                ),
              ),

              // Konten utama: Hasil pencarian API atau Daftar Favorit & Riwayat
              Expanded(
                child: Consumer2<SearchViewModel, WeatherViewModel>(
                  builder: (context, searchVm, weatherVm, _) {
                    if (hasInput) {
                      return _buildSearchResultsBody(
                        context,
                        searchVm,
                        weatherVm,
                      );
                    }
                    return _buildSavedLocationsBody(
                      context,
                      theme,
                      searchVm,
                      weatherVm,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsBody(
    BuildContext context,
    SearchViewModel searchVm,
    WeatherViewModel weatherVm,
  ) {
    switch (searchVm.searchState) {
      case ViewState.initial:
        if (_searchController.text.trim().length >= 2) {
          return StateFeedbackView.loading(
            title: 'Menyiapkan Pencarian...',
            message: 'Menghubungi Open-Meteo Geocoding API.',
          );
        }
        return StateFeedbackView.empty(
          icon: Icons.keyboard_alt_outlined,
          title: 'Ketik Nama Kota',
          message:
              'Masukkan minimal 2 karakter untuk mencari lokasi melalui Open-Meteo Geocoding API.',
        );

      case ViewState.loading:
        return StateFeedbackView.loading(
          title: 'Mencari "${searchVm.query}"...',
          message: 'Menghubungi Open-Meteo Geocoding API.',
        );

      case ViewState.empty:
        return StateFeedbackView.empty(
          icon: Icons.location_off_rounded,
          title: 'Kota Tidak Ditemukan',
          message:
              'Tidak ada hasil untuk "${searchVm.query}". Periksa ejaan atau coba kata kunci kota lain.',
          actionLabel: 'Hapus Pencarian',
          actionIcon: Icons.clear_rounded,
          onAction: _clearSearchField,
        );

      case ViewState.error:
        return StateFeedbackView.error(
          title: 'Pencarian Gagal',
          message:
              searchVm.errorMessage ??
              'Tidak dapat mengambil hasil pencarian dari Open-Meteo.',
          onRetry: searchVm.retryLastSearch,
        );

      case ViewState.loaded:
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: searchVm.searchResults.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final location = searchVm.searchResults[index];
            return LocationListTile(
              location: location,
              isFavorite: weatherVm.isFavorite(location),
              onTap: () => _selectLocation(location),
              onToggleFavorite: () => _toggleFavorite(location),
            );
          },
        );
    }
  }

  Widget _buildSavedLocationsBody(
    BuildContext context,
    ThemeData theme,
    SearchViewModel searchVm,
    WeatherViewModel weatherVm,
  ) {
    final favorites = weatherVm.favorites;
    final history = searchVm.searchHistory;
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      children: [
        // Bagian 1: Lokasi Favorit tersimpan di Local Storage
        Row(
          children: [
            Icon(Icons.star_rounded, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text('Lokasi Favorit', style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 10),
        if (favorites.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(
                    Icons.star_outline_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Belum ada lokasi favorit. Cari kota lalu tekan ikon bintang untuk menyimpannya secara lokal.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...favorites.map(
            (location) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LocationListTile(
                location: location,
                isFavorite: true,
                leadingIcon: Icons.star_rounded,
                onTap: () => _selectLocation(location),
                onToggleFavorite: () => _toggleFavorite(location),
              ),
            ),
          ),

        const SizedBox(height: 20),

        // Bagian 2: Riwayat Pencarian tersimpan di Local Storage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text('Riwayat Pencarian', style: theme.textTheme.titleMedium),
              ],
            ),
            if (history.isNotEmpty)
              TextButton(
                onPressed: searchVm.clearHistory,
                child: const Text('Hapus Riwayat'),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (history.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(
                    Icons.manage_search_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Belum ada riwayat pencarian. Kota yang Anda pilih akan otomatis tersimpan di sini.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...history.map(
            (location) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LocationListTile(
                location: location,
                isFavorite: weatherVm.isFavorite(location),
                leadingIcon: Icons.history_rounded,
                onTap: () => _selectLocation(location),
                onToggleFavorite: () => _toggleFavorite(location),
              ),
            ),
          ),
      ],
    );
  }
}
