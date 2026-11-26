import 'package:material_ui/material_ui.dart';

import '../../core/utils/date_formatter.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../models/daily_forecast_model.dart';

/// Bagian prakiraan cuaca beberapa hari ke depan pada Home Screen.
/// Menampilkan `daily.temperature_2m_max`, `daily.temperature_2m_min`,
/// `daily.precipitation_probability_max`, tanggal, dan ikon kondisi cuaca.
class DailyForecastSection extends StatelessWidget {
  const DailyForecastSection({super.key, required this.forecasts});

  final List<DailyForecastModel> forecasts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (forecasts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Prakiraan ${forecasts.length} Hari Ke Depan',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Min / Maks',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 380;

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: forecasts.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                ),
                itemBuilder: (context, index) {
                  final item = forecasts[index];
                  final condition = WeatherCodeMapper.map(item.weatherCode);

                  if (isCompact) {
                    return _CompactForecastRow(
                      item: item,
                      index: index,
                      condition: condition,
                    );
                  }

                  return _RegularForecastRow(
                    item: item,
                    index: index,
                    condition: condition,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RegularForecastRow extends StatelessWidget {
  const _RegularForecastRow({
    required this.item,
    required this.index,
    required this.condition,
  });

  final DailyForecastModel item;
  final int index;
  final WeatherConditionInfo condition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Hari & tanggal
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormatter.formatDayName(item.date, index: index),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  DateFormatter.formatShortDate(item.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Ikon cuaca & label singkat
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(condition.icon, size: 22, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    condition.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Peluang hujan maksimum (`daily.precipitation_probability_max`)
          _RainProbabilityBadge(
            probability: item.precipitationProbabilityMax,
          ),
          const SizedBox(width: 12),

          // Suhu minimum & maksimum harian
          _TempMinMaxText(
            minTemp: item.temperature2mMin,
            maxTemp: item.temperature2mMax,
          ),
        ],
      ),
    );
  }
}

/// Tata letak adaptif 2 baris untuk layar ponsel sempit (< 380px) agar bebas overflow.
class _CompactForecastRow extends StatelessWidget {
  const _CompactForecastRow({
    required this.item,
    required this.index,
    required this.condition,
  });

  final DailyForecastModel item;
  final int index;
  final WeatherConditionInfo condition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.formatDayName(item.date, index: index),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      DateFormatter.formatShortDate(item.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _TempMinMaxText(
                minTemp: item.temperature2mMin,
                maxTemp: item.temperature2mMax,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(condition.icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  condition.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _RainProbabilityBadge(
                probability: item.precipitationProbabilityMax,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RainProbabilityBadge extends StatelessWidget {
  const _RainProbabilityBadge({required this.probability});

  final int probability;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.water_drop_rounded, size: 13, color: colorScheme.primary),
          const SizedBox(width: 3),
          Text(
            '$probability%',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _TempMinMaxText extends StatelessWidget {
  const _TempMinMaxText({required this.minTemp, required this.maxTemp});

  final double minTemp;
  final double maxTemp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${minTemp.round()}°',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          ' / ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.outline,
          ),
        ),
        Text(
          '${maxTemp.round()}°',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
