import 'package:material_ui/material_ui.dart';

import '../../models/location_model.dart';

/// Bar chip horizontal untuk berpindah cepat antar lokasi favorit yang tersimpan.
class FavoriteChipsBar extends StatelessWidget {
  const FavoriteChipsBar({
    super.key,
    required this.favorites,
    required this.selectedLocation,
    required this.onSelect,
  });

  final List<LocationModel> favorites;
  final LocationModel? selectedLocation;
  final ValueChanged<LocationModel> onSelect;

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                Icons.star_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Lokasi Favorit',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: favorites.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final location = favorites[index];
              final isSelected =
                  selectedLocation != null &&
                  selectedLocation!.isSameLocation(location);

              return ChoiceChip(
                label: Text(location.name),
                selected: isSelected,
                onSelected: (_) {
                  if (!isSelected) {
                    onSelect(location);
                  }
                },
                avatar: Icon(
                  isSelected ? Icons.location_on_rounded : Icons.star_rounded,
                  size: 16,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
