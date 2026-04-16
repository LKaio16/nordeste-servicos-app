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

DateTime? _lembreteDataAlvoFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    return DateTime.tryParse(value);
  }
  if (value is List && value.isNotEmpty) {
    final y = (value[0] as num).toInt();
    final m = value.length > 1 ? (value[1] as num).toInt() : 1;
    final d = value.length > 2 ? (value[2] as num).toInt() : 1;
    return DateTime.utc(y, m, d);
  }
  return null;
}

dynamic _lembreteDataAlvoToJson(DateTime? value) =>
    value?.toIso8601String().split('T').first;

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

  @JsonKey(defaultValue: false)
  final bool lembreteAtivo;
  final int? lembreteDiasAposFechamento;
  @JsonKey(fromJson: _lembreteDataAlvoFromJson, toJson: _lembreteDataAlvoToJson)
  final DateTime? lembreteDataAlvo;

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
    this.lembreteAtivo = false,
    this.lembreteDiasAposFechamento,
    this.lembreteDataAlvo,
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
      lembreteAtivo: lembreteAtivo,
      lembreteDiasAposFechamento: lembreteDiasAposFechamento,
      lembreteDataAlvo: lembreteDataAlvo,
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
      lembreteAtivo: entity.lembreteAtivo,
      lembreteDiasAposFechamento: entity.lembreteDiasAposFechamento,
      lembreteDataAlvo: entity.lembreteDataAlvo,
    );
  }

    OrdemServicoModel copyWith({
    int? id,
    String? numeroOS,
    StatusOSModel? status,
    DateTime? dataAbertura,
    DateTime? dataAgendamento,
    DateTime? dataFechamento,
    DateTime? dataHoraEmissao,
    ClienteModel? cliente,
    EquipamentoModel? equipamento,
    UsuarioModel? tecnicoAtribuidoModel,
    String? problemaRelatado,
    String? analiseFalha,
    String? solucaoAplicada,
    PrioridadeOSModel? prioridade,
    bool? lembreteAtivo,
    int? lembreteDiasAposFechamento,
    DateTime? lembreteDataAlvo,
  }) {
    return OrdemServicoModel(
      id: id ?? this.id,
      numeroOS: numeroOS ?? this.numeroOS,
      status: status ?? this.status,
      dataAbertura: dataAbertura ?? this.dataAbertura,
      dataAgendamento: dataAgendamento ?? this.dataAgendamento,
      dataFechamento: dataFechamento ?? this.dataFechamento,
      dataHoraEmissao: dataHoraEmissao ?? this.dataHoraEmissao,
      cliente: cliente ?? this.cliente,
      equipamento: equipamento ?? this.equipamento,
      tecnicoAtribuidoModel: tecnicoAtribuidoModel ?? this.tecnicoAtribuidoModel,
      problemaRelatado: problemaRelatado ?? this.problemaRelatado,
      analiseFalha: analiseFalha ?? this.analiseFalha,
      solucaoAplicada: solucaoAplicada ?? this.solucaoAplicada,
      prioridade: prioridade ?? this.prioridade,
      lembreteAtivo: lembreteAtivo ?? this.lembreteAtivo,
      lembreteDiasAposFechamento:
          lembreteDiasAposFechamento ?? this.lembreteDiasAposFechamento,
      lembreteDataAlvo: lembreteDataAlvo ?? this.lembreteDataAlvo,
    );
  }
}