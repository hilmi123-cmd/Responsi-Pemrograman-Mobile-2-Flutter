import 'package:material_ui/material_ui.dart';

import '../../models/weather_response_model.dart';

/// Grid responsif untuk menampilkan seluruh informasi cuaca tambahan wajib:
/// 1. Kelembapan (`current.relative_humidity_2m`)
/// 2. Suhu yang dirasakan (`current.apparent_temperature`)
/// 3. Kecepatan angin (`current.wind_speed_10m`)
/// 4. Curah hujan (`current.precipitation`)
/// 5. Peluang hujan hari ini (`daily.precipitation_probability_max`)
class WeatherMetricsGrid extends StatelessWidget {
  const WeatherMetricsGrid({super.key, required this.weather});

  final WeatherResponseModel weather;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = weather.current;

    final metrics = <_WeatherMetricData>[
      _WeatherMetricData(
        label: 'Kelembapan',
        value: '${current.relativeHumidity2m}${current.humidityUnit}',
        helper: 'Kelembapan udara',
        icon: Icons.water_drop_outlined,
        accentColor: const Color(0xFF0288D1),
      ),
      _WeatherMetricData(
        label: 'Suhu Dirasakan',
        value:
            '${current.apparentTemperature.toStringAsFixed(1)}${current.temperatureUnit}',
        helper: 'Apparent temperature',
        icon: Icons.thermostat_rounded,
        accentColor: const Color(0xFFEF6C00),
      ),
      _WeatherMetricData(
        label: 'Kecepatan Angin',
        value:
            '${current.windSpeed10m.toStringAsFixed(1)} ${current.windSpeedUnit}',
        helper: 'Angin pada 10 meter',
        icon: Icons.air_rounded,
        accentColor: const Color(0xFF00897B),
      ),
      _WeatherMetricData(
        label: 'Curah Hujan',
        value:
            '${current.precipitation.toStringAsFixed(1)} ${current.precipitationUnit}',
        helper: 'Presipitasi saat ini',
        icon: Icons.umbrella_rounded,
        accentColor: const Color(0xFF3949AB),
      ),
      _WeatherMetricData(
        label: 'Peluang Hujan',
        value: '${weather.todayPrecipitationProbabilityMax}%',
        helper: 'Probabilitas maks hari ini',
        icon: Icons.cloudy_snowing,
        accentColor: const Color(0xFF5E35B1),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detail Cuaca Saat Ini', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 12.0;
            final width = constraints.maxWidth;
            final columns = width >= 840
                ? 5
                : width >= 560
                ? 3
                : 2;
            final cardWidth = (width - (spacing * (columns - 1))) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: metrics.map((metric) {
                return SizedBox(
                  width: cardWidth,
                  child: _MetricCard(metric: metric),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _WeatherMetricData {
  const _WeatherMetricData({
    required this.label,
    required this.value,
    required this.helper,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final String value;
  final String helper;
  final IconData icon;
  final Color accentColor;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _WeatherMetricData metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: metric.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(metric.icon, size: 18, color: metric.accentColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    metric.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              metric.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              metric.helper,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
