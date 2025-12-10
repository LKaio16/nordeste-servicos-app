/// Modelo de Artigo/Dica
class Article {
  final String id;
  final String title;
  final String icon;
  final String content;
  final String imageUrl;
  final String category;

  Article({
    required this.id,
    required this.title,
    required this.icon,
    required this.content,
    required this.imageUrl,
    required this.category,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      icon: json['icon'] ?? '📄',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? 'Geral',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'content': content,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}







