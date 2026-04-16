import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../styles/app_colors.dart';

/// Indicadores de página com rolagem horizontal e texto "n / total" para evitar overflow com muitas fotos.
class OsPhotoPageIndicators extends StatelessWidget {
  final int count;
  final int currentIndex;

  const OsPhotoPageIndicators({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${currentIndex + 1} / $count',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 16,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                count,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: currentIndex == index ? 10 : 8,
                    height: currentIndex == index ? 10 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentIndex == index
                          ? AppColors.primaryBlue
                          : AppColors.textLight.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Imagem da miniatura do carrossel: decode dimensionado + gaplessPlayback reduz piscar no iOS.
class OsFotoCoverImage extends StatelessWidget {
  final String? url;
  final Uint8List? bytes;
  final Object? imageKey;

  const OsFotoCoverImage({
    super.key,
    required this.url,
    required this.bytes,
    this.imageKey,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final cw = (constraints.maxWidth * dpr).round().clamp(1, 4096);
        final ch = (constraints.maxHeight * dpr).round().clamp(1, 4096);

        if (url != null && url!.isNotEmpty) {
          return RepaintBoundary(
            child: Image.network(
              url!,
              key: ValueKey(imageKey ?? url),
              fit: BoxFit.cover,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
              cacheWidth: cw,
              cacheHeight: ch,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey.shade600),
              ),
            ),
          );
        }
        if (bytes != null && bytes!.isNotEmpty) {
          return RepaintBoundary(
            child: Image.memory(
              bytes!,
              key: ValueKey(imageKey ?? bytes!.length),
              fit: BoxFit.cover,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey.shade600),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// Visualização em tela cheia (contain).
class OsFotoContainImage extends StatelessWidget {
  final String? url;
  final Uint8List? bytes;
  final Object? imageKey;

  const OsFotoContainImage({
    super.key,
    required this.url,
    required this.bytes,
    this.imageKey,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final cw = (constraints.maxWidth * dpr).round().clamp(1, 8192);
        final ch = (constraints.maxHeight * dpr).round().clamp(1, 8192);

        if (url != null && url!.isNotEmpty) {
          return RepaintBoundary(
            child: Image.network(
              url!,
              key: ValueKey(imageKey ?? url),
              fit: BoxFit.contain,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
              cacheWidth: cw,
              cacheHeight: ch,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.broken_image_outlined, size: 64, color: Colors.grey.shade600),
            ),
          );
        }
        if (bytes != null && bytes!.isNotEmpty) {
          return RepaintBoundary(
            child: Image.memory(
              bytes!,
              key: ValueKey(imageKey ?? bytes!.length),
              fit: BoxFit.contain,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.broken_image_outlined, size: 64, color: Colors.grey.shade600),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
