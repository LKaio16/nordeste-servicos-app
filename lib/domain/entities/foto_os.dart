class FotoOS {
  final int? id;
  final int ordemServicoId;
  final String fotoBase64; // Alterado
  final String? descricao; // Adicionado
  final String? nomeArquivoOriginal;
  final String? tipoConteudo;
  final int? tamanhoArquivo;
  final DateTime dataUpload;

  FotoOS({
    this.id,
    required this.ordemServicoId,
    required this.fotoBase64,
    this.descricao,
    this.nomeArquivoOriginal,
    this.tipoConteudo,
    this.tamanhoArquivo,
    required this.dataUpload,
  });
}