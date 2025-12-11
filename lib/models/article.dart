import '../config/app_constants.dart';

/// Modelo de Artigo/Dica
/// Mapeia o DicaResponse da API
class Article {
  final int id;
  final String title;
  final String icon;
  final String content;
  final String imageUrl;
  final String category;
  final String? whatsappLink;

  Article({
    required this.id,
    required this.title,
    required this.icon,
    required this.content,
    required this.imageUrl,
    required this.category,
    this.whatsappLink,
  });

  /// Cria um Article a partir do JSON da API (DicaResponse)
  factory Article.fromApiJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? 0;
    
    // A API retorna linkImagem e linkIcone já com o path completo
    // Ex: http://localhost:8080/api/dicas/1/imagem
    String imageUrl = json['linkImagem']?.toString() ?? '';
    String iconUrl = json['linkIcone']?.toString() ?? '';
    
    // Se o link não está completo, constrói
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      imageUrl = '${AppConstants.apiBaseUrl}/api/dicas/$id/imagem';
    }
    if (iconUrl.isEmpty || !iconUrl.startsWith('http')) {
      iconUrl = '${AppConstants.apiBaseUrl}/api/dicas/$id/icone';
    }
    
    return Article(
      id: id,
      title: json['titulo']?.toString() ?? '',
      icon: iconUrl, // Usa URL do ícone da API
      content: json['descricao']?.toString() ?? '',
      imageUrl: imageUrl,
      category: json['tag']?.toString() ?? 'Geral',
      whatsappLink: json['linkWhatsapp']?.toString(),
    );
  }

  /// Factory para criar Article a partir de JSON genérico (mock)
  factory Article.fromJson(Map<String, dynamic> json) {
    // Se tem campos da API, usa fromApiJson
    if (json.containsKey('titulo') || json.containsKey('descricao')) {
      return Article.fromApiJson(json);
    }
    
    return Article(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      icon: json['icon'] ?? '📄',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? 'Geral',
      whatsappLink: json['whatsappLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': title,
      'tag': category,
      'descricao': content,
      'linkImagem': imageUrl,
      'linkIcone': icon,
      'linkWhatsapp': whatsappLink,
    };
  }
}
