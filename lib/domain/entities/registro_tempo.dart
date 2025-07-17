// lib/domain/entities/registro_tempo.dart

// Importar Usuario e TipoServico se quiser os objetos completos na entidade RegistroTempo
// import 'usuario.dart';
// import 'tipo_servico.dart';

class RegistroTempo {
  final int? id;
  final int ordemServicoId; // Referência ao ID da OS pai
  final int tecnicoId; // Referência ao ID do técnico
  final String? nomeTecnico; // Mantido se o Model já o traz

  final DateTime horaInicio;
  final DateTime? horaTermino;
  final double? horasTrabalhadas;

  RegistroTempo({
    this.id,
    required this.ordemServicoId,
    required this.tecnicoId,
    this.nomeTecnico,
    required this.horaInicio,
    this.horaTermino,
    this.horasTrabalhadas,
  });
}