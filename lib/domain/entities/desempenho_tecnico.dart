// lib/domain/entities/desempenho_tecnico.dart
class DesempenhoTecnico {
  final int id;
  final String nome;
  final String? fotoPerfil;
  final int totalOS;
  final double desempenho;

  DesempenhoTecnico({
    required this.id,
    required this.nome,
    this.fotoPerfil,
    required this.totalOS,
    required this.desempenho,
  });
}