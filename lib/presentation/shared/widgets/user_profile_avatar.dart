import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Avatar a partir de [fotoUrl] (rede) ou [fotoPerfilBase64]. Sem foto válida: silhueta padrão.
class UserProfileAvatar extends StatelessWidget {
  final String? fotoPerfilBase64;
  /// URL da foto (ex.: Google Cloud Storage); tem prioridade sobre base64 quando preenchida.
  final String? fotoUrl;
  final double radius;
  final Color? backgroundColor;
  final Color iconColor;
  final double iconSize;

  const UserProfileAvatar({
    super.key,
    this.fotoPerfilBase64,
    this.fotoUrl,
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

  Widget _fallbackAvatar() {
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

  @override
  Widget build(BuildContext context) {
    final url = fotoUrl?.trim();
    if (url != null && url.isNotEmpty) {
      final size = radius * 2;
      return ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return ColoredBox(
                color: backgroundColor ?? Colors.grey.shade200,
                child: Center(
                  child: SizedBox(
                    width: radius * 0.9,
                    height: radius * 0.9,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: iconColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => _fallbackAvatar(),
          ),
        ),
      );
    }

    return _fallbackAvatar();
  }
}
