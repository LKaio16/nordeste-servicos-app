// lib/data/models/tipo_servico_model.dart

import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/tipo_servico.dart';

// Importar a entidade TipoServico se usar a camada domain
// import 'package:nordeste_servicos/domain/entities/tipo_servico.dart';

part 'tipo_servico_model.g.dart';

@JsonSerializable()
class TipoServicoModel {
  final int? id;
  final String descricao;

  TipoServicoModel({
    this.id,
    required this.descricao,
  });

  factory TipoServicoModel.fromJson(Map<String, dynamic> json) =>
      _$TipoServicoModelFromJson(json);

  Map<String, dynamic> toJson() => _$TipoServicoModelToJson(this);

// Método para converter para Entity (se usar camada domain) - COMENTADO
  TipoServico toEntity() {
    return TipoServico(
      id: id,
      descricao: descricao,
    );
  }
}
