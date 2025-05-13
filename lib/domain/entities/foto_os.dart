// lib/domain/entities/foto_os.dart

class FotoOS {
  final int? id;
  final int ordemServicoId; // Referência ao ID da OS pai
  final String urlAcesso;
  final String nomeArquivoOriginal;
  final String tipoConteudo;
  final int? tamanhoArquivo;
  final DateTime dataUpload;

  FotoOS({
    this.id,
    required this.ordemServicoId,
    required this.urlAcesso,
    required this.nomeArquivoOriginal,
    required this.tipoConteudo,
    this.tamanhoArquivo,
    required this.dataUpload,
  });
}