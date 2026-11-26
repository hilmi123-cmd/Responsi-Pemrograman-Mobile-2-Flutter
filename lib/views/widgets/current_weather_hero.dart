import 'package:material_ui/material_ui.dart';

import '../../core/utils/date_formatter.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../models/location_model.dart';
import '../../models/weather_response_model.dart';

/// Kartu utama pada Home Screen yang menampilkan nama kota, kondisi cuaca terkini
/// (`current.weather_code`), suhu saat ini (`current.temperature_2m`), serta tombol favorit.
class CurrentWeatherHero extends StatelessWidget {
  const CurrentWeatherHero({
    super.key,
    required this.location,
    required this.weather,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final LocationModel location;
  final WeatherResponseModel weather;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = weather.current;
    final condition = WeatherCodeMapper.map(current.weatherCode);
    final today = weather.daily.isNotEmpty ? weather.daily.first : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: condition.gradientColors,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: condition.gradientColors.first.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris atas: Nama kota + tombol simpan ke favorit
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              location.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (location.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.only(left: 26),
                          child: Text(
                            location.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: isFavorite
                      ? 'Hapus dari favorit'
                      : 'Simpan ke favorit',
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: onToggleFavorite,
                      icon: Icon(
                        isFavorite
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: isFavorite ? Colors.amberAccent : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bagian tengah: Suhu saat ini & Ikon kondisi cuaca (responsif via Wrap)
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 330;
                return Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            current.temperature2m.toStringAsFixed(1),
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: isCompact ? 52 : 64,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 2),
                            child: Text(
                              current.temperatureUnit,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            condition.icon,
                            size: isCompact ? 38 : 44,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                condition.label,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                condition.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Baris bawah: Ringkasan Min/Maks hari ini, suhu terasa, dan waktu update
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                if (today != null)
                  _HeroBadge(
                    icon: Icons.swap_vert_rounded,
                    label:
                        'Maks ${today.temperature2mMax.toStringAsFixed(1)}° / Min ${today.temperature2mMin.toStringAsFixed(1)}°',
                  ),
                _HeroBadge(
                  icon: Icons.thermostat_rounded,
                  label:
                      'Terasa ${current.apparentTemperature.toStringAsFixed(1)}${current.temperatureUnit}',
                ),
                if (current.time.isNotEmpty)
                  _HeroBadge(
                    icon: Icons.schedule_rounded,
                    label: DateFormatter.formatLastUpdated(current.time),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
