import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Avatar a partir de [fotoPerfilBase64]. Sem foto ou dados inválidos: silhueta padrão.
class UserProfileAvatar extends StatelessWidget {
  final String? fotoPerfilBase64;
  final double radius;
  final Color? backgroundColor;
  final Color iconColor;
  final double iconSize;

  const UserProfileAvatar({
    super.key,
    this.fotoPerfilBase64,
    required this.radius,
    this.backgroundColor,
    required this.iconColor,
    double? iconSize,
  }) : iconSize = iconSize ?? radius * 1.15;

  static Uint8List? decodeFotoPerfil(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final s = raw.trim();
      final payload = s.startsWith('data:') && s.contains(',') ? s.split(',').last : s;
      return base64Decode(payload);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = decodeFotoPerfil(fotoPerfilBase64);
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: bytes != null ? MemoryImage(bytes) : null,
      child: bytes == null
          ? Icon(Icons.person, size: iconSize, color: iconColor)
          : null,
    );
  }
}
