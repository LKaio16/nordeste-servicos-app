import 'dart:convert';
import 'dart:typed_data';

class FotoOS {
  final int? id;
  final int ordemServicoId;
  final String? fotoBase64; // Legado (OS antigas sem GCloud)
  final String? fotoUrl; // URL no Google Cloud Storage
  final String? descricao;
  final String? nomeArquivoOriginal;
  final String? tipoConteudo;
  final int? tamanhoArquivo;
  final DateTime dataUpload;

  FotoOS({
    this.id,
    required this.ordemServicoId,
    this.fotoBase64,
    this.fotoUrl,
    this.descricao,
    this.nomeArquivoOriginal,
    this.tipoConteudo,
    this.tamanhoArquivo,
    required this.dataUpload,
  });

  /// URL da imagem (GCloud). Use Image.network quando não for null.
  String? get networkUrl => (fotoUrl != null && fotoUrl!.trim().isNotEmpty) ? fotoUrl : null;

  /// Bytes decodificados para base64 (legado). Use Image.memory no mobile.
  Uint8List? get imageBytes {
    if (fotoBase64 == null || fotoBase64!.trim().isEmpty) return null;
    final raw = fotoBase64!.startsWith('data:') ? fotoBase64!.split(',').last : fotoBase64!;
    try {
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }
}