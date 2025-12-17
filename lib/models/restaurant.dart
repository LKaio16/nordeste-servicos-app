import '../config/app_constants.dart';

/// Modelo de Restaurante
/// Mapeia o RestauranteResponse da API
class Restaurant {
  final String id;
  final String name;
  final String description;
  final String whatsapp;
  final String phone;
  final String imageUrl;
  final bool hasReservation;
  final bool hasDelivery;
  final String priceRange;
  final String? linkCardapio;
  final String? tipoAcao; // FAZER_RESERVA, FAZER_PEDIDO

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.whatsapp,
    required this.phone,
    required this.imageUrl,
    required this.hasReservation,
    required this.hasDelivery,
    required this.priceRange,
    this.linkCardapio,
    this.tipoAcao,
  });

  /// Cria um Restaurant a partir do JSON da API (RestauranteResponse)
  factory Restaurant.fromApiJson(Map<String, dynamic> json) {
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
        imageUrl = '${AppConstants.apiBaseUrl}/api/restaurantes/$id/imagem';
      }
    }
    
    // Mapeia categoria da API para priceRange
    // A API retorna categoriaCifroes que já vem formatado ($, $$, $$$, $$$$)
    String priceRange = json['categoriaCifroes']?.toString() ?? 
                       json['priceRange']?.toString() ?? 
                       '\$\$';
    
    // Se não tem categoriaCifroes, tenta mapear da categoria enum
    if (priceRange.isEmpty || priceRange == 'null') {
      final categoria = json['categoria']?.toString().toUpperCase() ?? '';
      switch (categoria) {
        case 'ECONOMICO':
          priceRange = '\$';
          break;
        case 'MODERADO':
          priceRange = '\$\$';
          break;
        case 'SOFISTICADO':
          priceRange = '\$\$\$';
          break;
        case 'PREMIUM':
          priceRange = '\$\$\$\$';
          break;
        default:
          priceRange = '\$\$';
      }
    }
    
    // Determina hasReservation e hasDelivery baseado no tipoAcao
    final tipoAcao = json['tipoAcao']?.toString() ?? '';
    final hasReservation = tipoAcao == 'FAZER_RESERVA';
    final hasDelivery = tipoAcao == 'FAZER_PEDIDO';
    
    return Restaurant(
      id: id,
      name: json['nome']?.toString() ?? json['name']?.toString() ?? '',
      description: json['descricao']?.toString() ?? json['description']?.toString() ?? '',
      whatsapp: json['numeroWhatsapp']?.toString() ?? json['whatsapp']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['numeroWhatsapp']?.toString() ?? '',
      imageUrl: imageUrl,
      hasReservation: hasReservation,
      hasDelivery: hasDelivery,
      priceRange: priceRange,
      linkCardapio: json['linkCardapio']?.toString(),
      tipoAcao: tipoAcao.isNotEmpty ? tipoAcao : null,
    );
  }

  /// Factory para criar Restaurant a partir de JSON genérico (mock)
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    // Se tem campos da API, usa fromApiJson
    if (json.containsKey('nome') || json.containsKey('descricao') || json.containsKey('categoria')) {
      return Restaurant.fromApiJson(json);
    }
    
    return Restaurant(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      phone: json['phone'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      hasReservation: json['hasReservation'] ?? false,
      hasDelivery: json['hasDelivery'] ?? false,
      priceRange: json['priceRange'] ?? '\$\$',
      linkCardapio: json['linkCardapio'],
      tipoAcao: json['tipoAcao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'whatsapp': whatsapp,
      'phone': phone,
      'imageUrl': imageUrl,
      'hasReservation': hasReservation,
      'hasDelivery': hasDelivery,
      'priceRange': priceRange,
      'linkCardapio': linkCardapio,
      'tipoAcao': tipoAcao,
    };
  }
}







