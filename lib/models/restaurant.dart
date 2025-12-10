/// Modelo de Restaurante
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
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      phone: json['phone'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      hasReservation: json['hasReservation'] ?? false,
      hasDelivery: json['hasDelivery'] ?? false,
      priceRange: json['priceRange'] ?? '\$\$',
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
    };
  }
}







