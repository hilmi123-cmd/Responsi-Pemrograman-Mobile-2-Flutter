import 'package:material_ui/material_ui.dart';

/// Komponen seragam untuk menampilkan state Loading, Data Kosong (Empty), dan Error.
class StateFeedbackView extends StatelessWidget {
  const StateFeedbackView._({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.isLoading = false,
    this.accentColor,
    this.primaryActionLabel,
    this.primaryActionIcon,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  factory StateFeedbackView.loading({
    Key? key,
    String title = 'Memuat Data...',
    String message = 'Sedang mengambil data terbaru dari Open-Meteo API.',
  }) {
    return StateFeedbackView._(
      key: key,
      icon: Icons.cloud_sync_rounded,
      title: title,
      message: message,
      isLoading: true,
    );
  }

  factory StateFeedbackView.empty({
    Key? key,
    IconData icon = Icons.location_city_rounded,
    required String title,
    required String message,
    String? actionLabel,
    IconData? actionIcon,
    VoidCallback? onAction,
  }) {
    return StateFeedbackView._(
      key: key,
      icon: icon,
      title: title,
      message: message,
      primaryActionLabel: actionLabel,
      primaryActionIcon: actionIcon,
      onPrimaryAction: onAction,
    );
  }

  factory StateFeedbackView.error({
    Key? key,
    String title = 'Gagal Memuat Data',
    required String message,
    String retryLabel = 'Coba Lagi',
    VoidCallback? onRetry,
    String? secondaryActionLabel,
    VoidCallback? onSecondaryAction,
  }) {
    return StateFeedbackView._(
      key: key,
      icon: Icons.wifi_off_rounded,
      title: title,
      message: message,
      accentColor: Colors.redAccent,
      primaryActionLabel: retryLabel,
      primaryActionIcon: Icons.refresh_rounded,
      onPrimaryAction: onRetry,
      secondaryActionLabel: secondaryActionLabel,
      onSecondaryAction: onSecondaryAction,
    );
  }

  final IconData icon;
  final String title;
  final String message;
  final bool isLoading;
  final Color? accentColor;
  final String? primaryActionLabel;
  final IconData? primaryActionIcon;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resolvedAccent = accentColor ?? colorScheme.primary;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: resolvedAccent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(18),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: resolvedAccent,
                            ),
                          )
                        : Icon(icon, size: 34, color: resolvedAccent),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (primaryActionLabel != null &&
                      onPrimaryAction != null) ...[
                    const SizedBox(height: 22),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: onPrimaryAction,
                          icon: Icon(primaryActionIcon ?? Icons.arrow_forward),
                          label: Text(primaryActionLabel!),
                        ),
                        if (secondaryActionLabel != null &&
                            onSecondaryAction != null)
                          OutlinedButton(
                            onPressed: onSecondaryAction,
                            child: Text(secondaryActionLabel!),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
