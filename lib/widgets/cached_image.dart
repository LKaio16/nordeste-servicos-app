import 'package:flutter/foundation.dart';
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
    // Log da URL
    debugPrint('CachedImage: URL = $imageUrl');
    debugPrint('CachedImage: useAuth = $useAuth');
    
    // Se URL vazia, mostra placeholder
    if (imageUrl.isEmpty) {
      debugPrint('CachedImage: URL vazia!');
      return _buildErrorWidget();
    }

    // Obtém headers de autenticação se necessário
    Map<String, String>? headers;
    if (useAuth) {
      final authService = AuthService();
      final token = authService.accessToken;
      debugPrint('CachedImage: Token disponível = ${token != null && token.isNotEmpty}');
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
      placeholder: (context, url) {
        debugPrint('CachedImage: Carregando... $url');
        return Shimmer.fromColors(
          baseColor: AppColors.gray200,
          highlightColor: AppColors.gray100,
          child: Container(
            width: width,
            height: height,
            color: AppColors.gray200,
          ),
        );
      },
      errorWidget: (context, url, error) {
        debugPrint('CachedImage: ERRO ao carregar $url');
        debugPrint('CachedImage: Erro = $error');
        return _buildErrorWidget();
      },
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: AppColors.gray200,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.gray400,
          size: 28,
        ),
      ),
    );
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
    debugPrint('AuthenticatedImage: URL = $imageUrl');
    
    if (imageUrl.isEmpty) {
      debugPrint('AuthenticatedImage: URL vazia!');
      return _buildDefaultError();
    }

    final authService = AuthService();
    final token = authService.accessToken;
    
    debugPrint('AuthenticatedImage: Token disponível = ${token != null && token.isNotEmpty}');
    
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
      placeholder: (context, url) {
        debugPrint('AuthenticatedImage: Carregando... $url');
        return placeholder ?? Shimmer.fromColors(
          baseColor: AppColors.gray200,
          highlightColor: AppColors.gray100,
          child: Container(
            width: width,
            height: height,
            color: AppColors.gray200,
          ),
        );
      },
      errorWidget: (context, url, error) {
        debugPrint('AuthenticatedImage: ERRO ao carregar $url');
        debugPrint('AuthenticatedImage: Erro = $error');
        return errorWidget ?? _buildDefaultError();
      },
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      color: AppColors.gray100,
      child: Icon(
        Icons.image_not_supported_rounded, 
        color: AppColors.gray400, 
        size: width != null ? width! * 0.4 : 32,
      ),
    );
  }
}
