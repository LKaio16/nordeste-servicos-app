/// Modelo de Ponto de Interesse
class PointOfInterest {
  final String id;
  final String name;
  final String type;
  final String coords;
  final double? latitude;
  final double? longitude;

  PointOfInterest({
    required this.id,
    required this.name,
    required this.type,
    required this.coords,
    this.latitude,
    this.longitude,
  });

  factory PointOfInterest.fromJson(Map<String, dynamic> json) {
    return PointOfInterest(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      coords: json['coords'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'coords': coords,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}







