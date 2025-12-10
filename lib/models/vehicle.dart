/// Modelo de Veículo para aluguel
class Vehicle {
  final String id;
  final String name;
  final String icon;
  final String price;
  final String imageUrl;
  final List<String> features;

  Vehicle({
    required this.id,
    required this.name,
    required this.icon,
    required this.price,
    required this.imageUrl,
    required this.features,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '🚗',
      price: json['price'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      features: List<String>.from(json['features'] ?? []),
    );
  }
}

/// Modelo de Carro para aluguel
class CarRental {
  final String id;
  final String category;
  final String models;
  final String pricePix;
  final String priceCard;
  final String installments;

  CarRental({
    required this.id,
    required this.category,
    required this.models,
    required this.pricePix,
    required this.priceCard,
    required this.installments,
  });

  factory CarRental.fromJson(Map<String, dynamic> json) {
    return CarRental(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      models: json['models'] ?? '',
      pricePix: json['pricePix'] ?? '',
      priceCard: json['priceCard'] ?? '',
      installments: json['installments'] ?? '',
    );
  }
}







