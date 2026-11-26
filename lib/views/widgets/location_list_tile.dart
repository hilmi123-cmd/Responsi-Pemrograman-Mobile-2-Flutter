import 'package:material_ui/material_ui.dart';

import '../../models/location_model.dart';

/// Item daftar lokasi yang dipakai ulang untuk hasil pencarian API,
/// daftar lokasi favorit, dan riwayat pencarian di Search / Location Screen.
class LocationListTile extends StatelessWidget {
  const LocationListTile({
    super.key,
    required this.location,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    this.leadingIcon = Icons.location_on_outlined,
  });

  final LocationModel location;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final IconData leadingIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(leadingIcon, color: colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location.subtitle.isNotEmpty
                          ? location.subtitle
                          : location.coordinatesLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: isFavorite
                    ? 'Hapus dari favorit'
                    : 'Simpan ke favorit',
                onPressed: onToggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isFavorite
                      ? Colors.amber.shade600
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
