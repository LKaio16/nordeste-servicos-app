/// Modelo de Ponto de Interesse
/// Mapeia o PontoInteresseResponse da API
class PointOfInterest {
  final String id;
  final String name;
  final String type;
  final String coords;
  final String? linkGoogleMaps;
  final double? latitude;
  final double? longitude;

  PointOfInterest({
    required this.id,
    required this.name,
    required this.type,
    required this.coords,
    this.linkGoogleMaps,
    this.latitude,
    this.longitude,
  });

  /// Cria um PointOfInterest a partir do JSON da API (PontoInteresseResponse)
  factory PointOfInterest.fromApiJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '0';
    final titulo = json['titulo']?.toString() ?? '';
    final categoria = json['categoria']?.toString() ?? '';
    final tag = json['tag']?.toString() ?? '';
    final linkGoogleMaps = json['linkGoogleMaps']?.toString();
    
    // Tenta extrair coordenadas do link do Google Maps se disponível
    double? latitude;
    double? longitude;
    if (linkGoogleMaps != null && linkGoogleMaps.isNotEmpty) {
      // Tenta extrair coordenadas do link (formato comum: @lat,lng)
      final match = RegExp(r'@(-?\d+\.?\d*),(-?\d+\.?\d*)').firstMatch(linkGoogleMaps);
      if (match != null) {
        latitude = double.tryParse(match.group(1) ?? '');
        longitude = double.tryParse(match.group(2) ?? '');
      }
    }
    
    return PointOfInterest(
      id: id,
      name: titulo,
      type: categoria,
      coords: tag, // Usa tag como coords temporariamente
      linkGoogleMaps: linkGoogleMaps,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Factory para criar PointOfInterest a partir de JSON genérico (mock)
  factory PointOfInterest.fromJson(Map<String, dynamic> json) {
    // Se tem campos da API, usa fromApiJson
    if (json.containsKey('titulo') || json.containsKey('categoria') || json.containsKey('linkGoogleMaps')) {
      return PointOfInterest.fromApiJson(json);
    }
    
    return PointOfInterest(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      coords: json['coords'] ?? '',
      linkGoogleMaps: json['linkGoogleMaps'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': name,
      'categoria': type,
      'tag': coords,
      'linkGoogleMaps': linkGoogleMaps,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}







