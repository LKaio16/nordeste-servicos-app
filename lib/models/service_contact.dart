import 'package:flutter/material.dart';

/// Modelo de Contato de Serviço de Emergência
class EmergencyService {
  final String name;
  final String phone;
  final IconData icon;
  final List<Color> gradientColors;

  EmergencyService({
    required this.name,
    required this.phone,
    required this.icon,
    required this.gradientColors,
  });
}

/// Modelo de Categoria de Serviço
class ServiceCategory {
  final String name;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final List<ServiceContact> contacts;

  ServiceCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.contacts,
  });
}

/// Modelo de Contato de Serviço
class ServiceContact {
  final String name;
  final String phone;

  ServiceContact({
    required this.name,
    required this.phone,
  });

  factory ServiceContact.fromJson(Map<String, dynamic> json) {
    return ServiceContact(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}







