// lib/data/models/desempenho_tecnico_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/desempenho_tecnico.dart';

part 'desempenho_tecnico_model.g.dart';

@JsonSerializable()
class DesempenhoTecnicoModel {
  final int id;
  final String nome;
  final String? fotoPerfil;
  final int totalOS;
  final double desempenho;

  DesempenhoTecnicoModel({
    required this.id,
    required this.nome,
    this.fotoPerfil,
    required this.totalOS,
    required this.desempenho,
  });

  factory DesempenhoTecnicoModel.fromJson(Map<String, dynamic> json) =>
      _$DesempenhoTecnicoModelFromJson(json);

  Map<String, dynamic> toJson() => _$DesempenhoTecnicoModelToJson(this);

  DesempenhoTecnico toEntity() {
    return DesempenhoTecnico(
      id: id,
      nome: nome,
      fotoPerfil: fotoPerfil,
      totalOS: totalOS,
      desempenho: desempenho,
    );
  }
}