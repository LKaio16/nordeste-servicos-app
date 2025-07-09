class AssinaturaOS {
  final int? id;
  final int ordemServicoId;
  final String? assinaturaClienteBase64;
  final String? nomeClienteResponsavel;
  final String? documentoClienteResponsavel;
  final String? assinaturaTecnicoBase64;
  final String? nomeTecnicoResponsavel;
  final DateTime? dataHoraColeta;

  AssinaturaOS({
    this.id,
    required this.ordemServicoId,
    this.assinaturaClienteBase64,
    this.nomeClienteResponsavel,
    this.documentoClienteResponsavel,
    this.assinaturaTecnicoBase64,
    this.nomeTecnicoResponsavel,
    this.dataHoraColeta,
  });
}