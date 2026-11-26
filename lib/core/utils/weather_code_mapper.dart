import 'package:material_ui/material_ui.dart';

/// Informasi tampilan hasil pemetaan WMO Weather Code dari Open-Meteo.
class WeatherConditionInfo {
  const WeatherConditionInfo({
    required this.label,
    required this.description,
    required this.icon,
    required this.gradientColors,
  });

  final String label;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
}

/// Memetakan kode cuaca WMO (`weather_code`) dari Open-Meteo ke deskripsi,
/// ikon Material, dan palet gradien yang mudah dibaca pengguna.
class WeatherCodeMapper {
  WeatherCodeMapper._();

  static WeatherConditionInfo map(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return const WeatherConditionInfo(
          label: 'Cerah',
          description: 'Langit cerah tanpa awan',
          icon: Icons.wb_sunny_rounded,
          gradientColors: [Color(0xFF1E88E5), Color(0xFF4FC3F7)],
        );
      case 1:
        return const WeatherConditionInfo(
          label: 'Cerah Berawan',
          description: 'Sebagian besar cerah',
          icon: Icons.wb_sunny_outlined,
          gradientColors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
        );
      case 2:
        return const WeatherConditionInfo(
          label: 'Berawan Sebagian',
          description: 'Awan tersebar di sebagian langit',
          icon: Icons.cloud_queue_rounded,
          gradientColors: [Color(0xFF3F72AF), Color(0xFF6C9BCF)],
        );
      case 3:
        return const WeatherConditionInfo(
          label: 'Mendung',
          description: 'Langit tertutup awan tebal',
          icon: Icons.cloud_rounded,
          gradientColors: [Color(0xFF546E7A), Color(0xFF78909C)],
        );
      case 45:
      case 48:
        return const WeatherConditionInfo(
          label: 'Berkabut',
          description: 'Kabut mengurangi jarak pandang',
          icon: Icons.foggy,
          gradientColors: [Color(0xFF607D8B), Color(0xFF90A4AE)],
        );
      case 51:
      case 53:
      case 55:
        return const WeatherConditionInfo(
          label: 'Gerimis',
          description: 'Hujan gerimis ringan hingga sedang',
          icon: Icons.grain_rounded,
          gradientColors: [Color(0xFF455A64), Color(0xFF607D8B)],
        );
      case 56:
      case 57:
        return const WeatherConditionInfo(
          label: 'Gerimis Beku',
          description: 'Gerimis disertai suhu dingin',
          icon: Icons.ac_unit_rounded,
          gradientColors: [Color(0xFF37474F), Color(0xFF5C6BC0)],
        );
      case 61:
      case 63:
      case 65:
        return const WeatherConditionInfo(
          label: 'Hujan',
          description: 'Hujan ringan hingga lebat',
          icon: Icons.water_drop_rounded,
          gradientColors: [Color(0xFF283593), Color(0xFF3949AB)],
        );
      case 66:
      case 67:
        return const WeatherConditionInfo(
          label: 'Hujan Beku',
          description: 'Hujan disertai suhu membeku',
          icon: Icons.cloudy_snowing,
          gradientColors: [Color(0xFF1A237E), Color(0xFF3F51B5)],
        );
      case 71:
      case 73:
      case 75:
      case 77:
        return const WeatherConditionInfo(
          label: 'Salju',
          description: 'Turun salju ringan hingga lebat',
          icon: Icons.ac_unit_rounded,
          gradientColors: [Color(0xFF3949AB), Color(0xFF7986CB)],
        );
      case 80:
      case 81:
      case 82:
        return const WeatherConditionInfo(
          label: 'Hujan Lokal',
          description: 'Hujan deras bersifat sementara',
          icon: Icons.umbrella_rounded,
          gradientColors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
        );
      case 85:
      case 86:
        return const WeatherConditionInfo(
          label: 'Hujan Salju',
          description: 'Hujan salju bersifat lokal',
          icon: Icons.snowing,
          gradientColors: [Color(0xFF303F9F), Color(0xFF5C6BC0)],
        );
      case 95:
        return const WeatherConditionInfo(
          label: 'Badai Petir',
          description: 'Hujan lebat disertai petir',
          icon: Icons.thunderstorm_rounded,
          gradientColors: [Color(0xFF1E293B), Color(0xFF475569)],
        );
      case 96:
      case 99:
        return const WeatherConditionInfo(
          label: 'Badai Petir & Es',
          description: 'Badai petir disertai hujan es',
          icon: Icons.flash_on_rounded,
          gradientColors: [Color(0xFF0F172A), Color(0xFF334155)],
        );
      default:
        return const WeatherConditionInfo(
          label: 'Tidak Diketahui',
          description: 'Kondisi cuaca tidak teridentifikasi',
          icon: Icons.wb_cloudy_rounded,
          gradientColors: [Color(0xFF334155), Color(0xFF64748B)],
        );
    }
  }
}
