/// Modelo de local de Vida Noturna
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
  });

  factory NightlifeVenue.fromJson(Map<String, dynamic> json) {
    return NightlifeVenue(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      schedule: json['schedule'] ?? '',
      highlight: json['highlight'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      whatsapp: json['whatsapp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'schedule': schedule,
      'highlight': highlight,
      'imageUrl': imageUrl,
      'rating': rating,
      'whatsapp': whatsapp,
    };
  }
}







