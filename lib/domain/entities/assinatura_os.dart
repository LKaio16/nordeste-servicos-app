// lib/domain/entities/assinatura_os.dart

class AssinaturaOS {
  final int? id;
  final int ordemServicoId; // Referência ao ID da OS pai (poderia ser o mesmo ID da entidade Assinatura se fosse @MapsId)

  final String urlAcesso;
  final String tipoConteudo;
  final int? tamanhoArquivo;
  final DateTime dataHoraColeta;

  AssinaturaOS({
    this.id,
    required this.ordemServicoId,
    required this.urlAcesso,
    required this.tipoConteudo,
    this.tamanhoArquivo,
    required this.dataHoraColeta,
  });
}