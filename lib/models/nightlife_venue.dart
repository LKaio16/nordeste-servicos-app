import '../config/app_constants.dart';

/// Modelo de local de Vida Noturna
/// Mapeia o VidaNoturnaResponse da API
class NightlifeVenue {
  final String id;
  final String name;
  final String description;
  final String type;
  final String schedule;
  final String highlight;
  final String imageUrl;
  final double rating;
  final String whatsapp;
  final String? linkGoogleMaps;

  NightlifeVenue({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.schedule,
    required this.highlight,
    required this.imageUrl,
    required this.rating,
    required this.whatsapp,
    this.linkGoogleMaps,
  });

  /// Cria um NightlifeVenue a partir do JSON da API (VidaNoturnaResponse)
  factory NightlifeVenue.fromApiJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '0';
    
    // A API retorna linkImagem já com o path completo ou relativo
    String imageUrl = json['linkImagem']?.toString() ?? '';
    
    // Se o link não está completo (não começa com http/https), constrói
    if (imageUrl.isEmpty || (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://'))) {
      // Se começa com /, é um path relativo, então adiciona a base URL
      if (imageUrl.startsWith('/')) {
        imageUrl = '${AppConstants.apiBaseUrl}$imageUrl';
      } else {
        // Se está vazio ou não começa com /, constrói o path padrão
        imageUrl = '${AppConstants.apiBaseUrl}/api/vida-noturna/$id/imagem';
      }
    }
    
    return NightlifeVenue(
      id: id,
      name: json['titulo']?.toString() ?? json['name']?.toString() ?? '',
      description: json['descricao']?.toString() ?? json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Bar', // Tipo padrão se não tiver
      schedule: json['horarioFuncionamento']?.toString() ?? json['schedule']?.toString() ?? '',
      highlight: json['destaque']?.toString() ?? json['highlight']?.toString() ?? '',
      imageUrl: imageUrl,
      rating: 0.0, // A API não retorna rating, mantém 0
      whatsapp: json['numeroWhatsapp']?.toString() ?? json['whatsapp']?.toString() ?? '',
      linkGoogleMaps: json['linkGoogleMaps']?.toString(),
    );
  }

  /// Factory para criar NightlifeVenue a partir de JSON genérico (mock)
  factory NightlifeVenue.fromJson(Map<String, dynamic> json) {
    // Se tem campos da API, usa fromApiJson
    if (json.containsKey('titulo') || json.containsKey('descricao') || json.containsKey('horarioFuncionamento')) {
      return NightlifeVenue.fromApiJson(json);
    }
    
    return NightlifeVenue(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      schedule: json['schedule'] ?? '',
      highlight: json['highlight'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      whatsapp: json['whatsapp'] ?? '',
      linkGoogleMaps: json['linkGoogleMaps'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': name,
      'descricao': description,
      'type': type,
      'horarioFuncionamento': schedule,
      'destaque': highlight,
      'linkImagem': imageUrl,
      'rating': rating,
      'numeroWhatsapp': whatsapp,
      'linkGoogleMaps': linkGoogleMaps,
    };
  }
}







