// lib/domain/entities/registro_deslocamento.dart

// Importar Usuario se quiser o objeto completo na entidade RegistroDeslocamento
// import 'usuario.dart';

class RegistroDeslocamento {
  final int? id;
  final int ordemServicoId; // Referência ao ID da OS pai
  final int tecnicoId; // Referência ao ID do técnico
  final String? nomeTecnico; // Mantido se o Model já o traz

  final DateTime data;
  final String placaVeiculo;
  final double? kmInicial;
  final double? kmFinal;
  final double? totalKm;

  final String? saidaDe;
  final String? chegadaEm;

  RegistroDeslocamento({
    this.id,
    required this.ordemServicoId,
    required this.tecnicoId,
    this.nomeTecnico,
    required this.data,
    required this.placaVeiculo,
    this.kmInicial,
    this.kmFinal,
    this.totalKm,
    this.saidaDe,
    this.chegadaEm,
  });
}