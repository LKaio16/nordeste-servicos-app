import '../config/app_constants.dart';

/// Modelo de Passeio/Tour
class Tour {
  final int id;
  final String name;
  final String description;
  final String fullDescription;
  final String price;
  final String duration;
  final List<String> includes;
  final String imageUrl;
  final int? topSeller;
  final List<TourCategory> categories;
  final bool featured;
  final String? tag;
  final String? whatsappLink;

  Tour({
    required this.id,
    required this.name,
    required this.description,
    required this.fullDescription,
    required this.price,
    required this.duration,
    required this.includes,
    required this.imageUrl,
    this.topSeller,
    required this.categories,
    this.featured = false,
    this.tag,
    this.whatsappLink,
  });

  /// Factory para criar Tour a partir do JSON da API
  factory Tour.fromApiJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? 0;
    final categoria = json['categoria']?.toString().toUpperCase() ?? '';
    
    // Mapeia categoria da API para TourCategory
    TourCategory category;
    switch (categoria) {
      case 'AVENTURA':
        category = TourCategory.aventura;
        break;
      case 'AQUATICO':
      case 'MERGULHO':
      case 'BARCO':
        category = TourCategory.aquaticos;
        break;
      case 'TERRESTRE':
      case 'TRILHA':
        category = TourCategory.terrestres;
        break;
      case 'EXCLUSIVO':
      case 'VIP':
        category = TourCategory.exclusivos;
        break;
      default:
        category = TourCategory.todos;
    }

    // Processa itens incluídos - pode ser List ou String
    List<String> itensIncluidos = [];
    final itens = json['itensIncluidos'];
    if (itens is List) {
      itensIncluidos = itens.map((e) => e.toString()).toList();
    } else if (itens is String && itens.isNotEmpty) {
      itensIncluidos = itens.split(',').map((e) => e.trim()).toList();
    }

    // Formata o valor para exibição
    final valor = json['valor'];
    String priceFormatted;
    if (valor is num) {
      priceFormatted = 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
    } else if (valor is String) {
      priceFormatted = valor.contains('R\$') ? valor : 'R\$ $valor';
    } else {
      priceFormatted = 'Consulte';
    }

    // Parseia topRanking (TOP_1, TOP_2, TOP_3, etc) para número
    int? topRanking;
    final topRankingStr = json['topRanking']?.toString();
    if (topRankingStr != null && topRankingStr.startsWith('TOP_')) {
      topRanking = int.tryParse(topRankingStr.replaceFirst('TOP_', ''));
    }

    // Usa linkImagem da API se disponível, senão constrói
    String imageUrl = json['linkImagem']?.toString() ?? 
                      '${AppConstants.apiBaseUrl}/api/passeios/$id/imagem';

    return Tour(
      id: id,
      name: json['titulo']?.toString() ?? json['name']?.toString() ?? '',
      description: json['descricao']?.toString() ?? json['description']?.toString() ?? '',
      fullDescription: json['descricao']?.toString() ?? json['fullDescription']?.toString() ?? '',
      price: priceFormatted,
      duration: json['duracao']?.toString() ?? json['duration']?.toString() ?? '',
      includes: itensIncluidos,
      imageUrl: imageUrl,
      topSeller: topRanking,
      categories: [TourCategory.todos, category],
      featured: topRanking != null, // Passeios com ranking são featured
      tag: json['tag']?.toString(),
      whatsappLink: json['linkWhatsapp']?.toString(),
    );
  }

  /// Factory para criar Tour a partir de JSON genérico (mock)
  factory Tour.fromJson(Map<String, dynamic> json) {
    // Se tem campos da API, usa fromApiJson
    if (json.containsKey('titulo') || json.containsKey('categoria')) {
      return Tour.fromApiJson(json);
    }
    
    return Tour(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      fullDescription: json['fullDescription'] ?? '',
      price: json['price'] ?? '',
      duration: json['duration'] ?? '',
      includes: List<String>.from(json['includes'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
      topSeller: json['topSeller'],
      categories: (json['categories'] as List?)
          ?.map((c) => TourCategory.values.firstWhere(
                (e) => e.name == c,
                orElse: () => TourCategory.todos,
              ))
          .toList() ?? [TourCategory.todos],
      featured: json['featured'] ?? false,
      tag: json['tag'],
      whatsappLink: json['linkWhatsapp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'fullDescription': fullDescription,
      'price': price,
      'duration': duration,
      'includes': includes,
      'imageUrl': imageUrl,
      'topSeller': topSeller,
      'categories': categories.map((c) => c.name).toList(),
      'featured': featured,
      'tag': tag,
      'linkWhatsapp': whatsappLink,
    };
  }
}

enum TourCategory {
  todos,
  aquaticos,
  terrestres,
  exclusivos,
  aventura,
}

extension TourCategoryExtension on TourCategory {
  String get label {
    switch (this) {
      case TourCategory.todos:
        return 'Todos';
      case TourCategory.aquaticos:
        return 'Aquáticos';
      case TourCategory.terrestres:
        return 'Terrestres';
      case TourCategory.exclusivos:
        return 'Exclusivos';
      case TourCategory.aventura:
        return 'Aventura';
    }
  }
}
