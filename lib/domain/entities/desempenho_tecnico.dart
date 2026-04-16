// lib/domain/entities/desempenho_tecnico.dart
class DesempenhoTecnico {
  final int id;
  final String nome;
  final String? fotoPerfil;
  /// URL da foto (ex.: GCS), priorizada no avatar em relação ao base64.
  final String? fotoUrl;
  final int totalOS;
  final double desempenho;

  DesempenhoTecnico({
    required this.id,
    required this.nome,
    this.fotoPerfil,
    this.fotoUrl,
    required this.totalOS,
    required this.desempenho,
  });
}