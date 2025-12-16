import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../config/app_colors.dart';

/// Widget para visualizar imagens com zoom e navegação intuitiva
class ImageViewer extends StatelessWidget {
  final String imagePath;
  final String? title;

  const ImageViewer({
    super.key,
    required this.imagePath,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: title != null
            ? Text(
                title!,
                style: const TextStyle(color: Colors.white),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: PhotoView(
        imageProvider: AssetImage(imagePath),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
        initialScale: PhotoViewComputedScale.contained,
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        loadingBuilder: (context, event) {
          if (event == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(
              value: event.cumulativeBytesLoaded / event.expectedTotalBytes!,
              color: Colors.white,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Erro ao carregar imagem',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


