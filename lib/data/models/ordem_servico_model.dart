// lib/data/models/ordem_servico_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:nordeste_servicos_app/data/models/cliente_model.dart';
import 'package:nordeste_servicos_app/data/models/equipamento_model.dart'; // <<< 1. IMPORTAR
import 'package:nordeste_servicos_app/data/models/prioridade_os_model.dart';
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';
import 'package:nordeste_servicos_app/data/models/usuario_model.dart';
import '../../domain/entities/ordem_servico.dart';
import '../../domain/entities/usuario.dart';

part 'ordem_servico_model.g.dart';

@JsonSerializable(explicitToJson: true)
class OrdemServicoModel {
  final int? id;
  final String numeroOS;
  final StatusOSModel status;
  final DateTime? dataAbertura;
  final DateTime? dataAgendamento;
  final DateTime? dataFechamento;
  final DateTime? dataHoraEmissao;

  @JsonKey(name: 'cliente')
  final ClienteModel cliente;

  // --- 2. SUBSTITUIR OS CAMPOS DE EQUIPAMENTO ---
  // final int equipamentoId;
  // final String? descricaoEquipamento;
  @JsonKey(name: 'equipamento')
  final EquipamentoModel equipamento; // <<< NOVO CAMPO

  @JsonKey(name: 'tecnicoAtribuido')
  final UsuarioModel? tecnicoAtribuidoModel;

  final String? problemaRelatado;
  final String? analiseFalha;
  final String? solucaoAplicada;
  final PrioridadeOSModel? prioridade;

  OrdemServicoModel({
    this.id,
    required this.numeroOS,
    required this.status,
    this.dataAbertura,
    this.dataAgendamento,
    this.dataFechamento,
    this.dataHoraEmissao,
    required this.cliente,
    required this.equipamento, // <<< 3. ATUALIZAR CONSTRUTOR
    this.tecnicoAtribuidoModel,
    this.problemaRelatado,
    this.analiseFalha,
    this.solucaoAplicada,
    this.prioridade,
  });

  factory OrdemServicoModel.fromJson(Map<String, dynamic> json) =>
      _$OrdemServicoModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrdemServicoModelToJson(this);

  OrdemServico toEntity() {
    // ...
    return OrdemServico(
      id: id,
      numeroOS: numeroOS,
      status: status,
      prioridade: prioridade,
      dataAbertura: dataAbertura,
      dataAgendamento: dataAgendamento,
      dataFechamento: dataFechamento,
      dataHoraEmissao: dataHoraEmissao,
      cliente: cliente.toEntity(),
      equipamento: equipamento.toEntity(), // <<< 4. ATUALIZAR MAPEAMENTO
      tecnicoAtribuido: tecnicoAtribuidoModel?.toEntity(),
      problemaRelatado: problemaRelatado,
      analiseFalha: analiseFalha,
      solucaoAplicada: solucaoAplicada,
    );
  }

  factory OrdemServicoModel.fromEntity(OrdemServico entity) {
    return OrdemServicoModel(
      id: entity.id,
      numeroOS: entity.numeroOS,
      status: entity.status,
      prioridade: entity.prioridade,
      dataAbertura: entity.dataAbertura,
      dataAgendamento: entity.dataAgendamento,
      dataFechamento: entity.dataFechamento,
      dataHoraEmissao: entity.dataHoraEmissao,
      cliente: ClienteModel.fromEntity(entity.cliente),
      equipamento: EquipamentoModel.fromEntity(entity.equipamento),
      tecnicoAtribuidoModel: entity.tecnicoAtribuido != null
          ? UsuarioModel.fromEntity(entity.tecnicoAtribuido!)
          : null,
      problemaRelatado: entity.problemaRelatado,
      analiseFalha: entity.analiseFalha,
      solucaoAplicada: entity.solucaoAplicada,
    );
  }
}