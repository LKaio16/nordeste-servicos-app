import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../config/app_colors.dart';
import '../services/auth_service.dart';

/// Widget para imagens com cache e placeholder
class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool useAuth;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.useAuth = false,
  });

  @override
  Widget build(BuildContext context) {
    // Obtém headers de autenticação se necessário
    Map<String, String>? headers;
    if (useAuth) {
      final authService = AuthService();
      final token = authService.accessToken;
      if (token != null && token.isNotEmpty) {
        headers = {'Authorization': 'Bearer $token'};
      }
    }

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      httpHeaders: headers,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: AppColors.gray200,
        highlightColor: AppColors.gray100,
        child: Container(
          width: width,
          height: height,
          color: AppColors.gray200,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: AppColors.gray200,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_rounded, color: AppColors.gray400, size: 32),
            SizedBox(height: 8),
            Text(
              'Imagem indisponível',
              style: TextStyle(color: AppColors.gray500, fontSize: 12),
            ),
          ],
        ),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }
}

/// Widget específico para imagens autenticadas da API
class AuthenticatedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AuthenticatedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final token = authService.accessToken;
    
    Map<String, String>? headers;
    if (token != null && token.isNotEmpty) {
      headers = {'Authorization': 'Bearer $token'};
    }

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      httpHeaders: headers,
      placeholder: (context, url) => placeholder ?? Shimmer.fromColors(
        baseColor: AppColors.gray200,
        highlightColor: AppColors.gray100,
        child: Container(
          width: width,
          height: height,
          color: AppColors.gray200,
        ),
      ),
      errorWidget: (context, url, error) => errorWidget ?? Container(
        width: width,
        height: height,
        color: AppColors.gray100,
        child: Icon(
          Icons.image_not_supported_rounded, 
          color: AppColors.gray400, 
          size: width != null ? width! * 0.4 : 32,
        ),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }
}
