/// Model data lokasi dari Open-Meteo Geocoding API sekaligus digunakan untuk
/// penyimpanan Local Storage (lokasi favorit, riwayat pencarian, lokasi terakhir).
class LocationModel {
  const LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country = '',
    this.countryCode = '',
    this.admin1 = '',
    this.timezone = '',
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String countryCode;
  final String admin1;
  final String timezone;

  /// Label wilayah lengkap, misal: "Jawa Tengah, Indonesia".
  String get subtitle {
    final parts = <String>[];
    if (admin1.isNotEmpty && admin1.toLowerCase() != name.toLowerCase()) {
      parts.add(admin1);
    }
    if (country.isNotEmpty) {
      parts.add(country);
    }
    return parts.join(', ');
  }

  /// Label koordinat ringkas untuk informasi tambahan.
  String get coordinatesLabel =>
      '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';

  /// Deserialisasi dari JSON Open-Meteo Geocoding API atau Local Storage.
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final lat = (json['latitude'] as num?)?.toDouble() ?? 0.0;
    final lon = (json['longitude'] as num?)?.toDouble() ?? 0.0;

    return LocationModel(
      id: (json['id'] as num?)?.toInt() ?? Object.hash(json['name'], lat, lon),
      name: (json['name'] as String?)?.trim() ?? 'Lokasi Tidak Diketahui',
      latitude: lat,
      longitude: lon,
      country: (json['country'] as String?)?.trim() ?? '',
      countryCode: (json['country_code'] as String?)?.trim() ?? '',
      admin1: (json['admin1'] as String?)?.trim() ?? '',
      timezone: (json['timezone'] as String?)?.trim() ?? '',
    );
  }

  /// Serialisasi ke JSON untuk disimpan di SharedPreferences.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'country_code': countryCode,
      'admin1': admin1,
      'timezone': timezone,
    };
  }

  /// Memeriksa kesamaan lokasi berdasarkan ID atau koordinat yang sangat berdekatan.
  bool isSameLocation(LocationModel other) {
    if (id != 0 && other.id != 0 && id == other.id) return true;
    return name.toLowerCase() == other.name.toLowerCase() &&
        (latitude - other.latitude).abs() < 0.01 &&
        (longitude - other.longitude).abs() < 0.01;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel && isSameLocation(other);
  }

  @override
  int get hashCode => id != 0 ? id.hashCode : Object.hash(name, latitude, longitude);
}
