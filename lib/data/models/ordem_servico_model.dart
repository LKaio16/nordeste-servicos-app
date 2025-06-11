// lib/data/models/ordem_servico_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:nordeste_servicos_app/data/models/perfil_usuario_model.dart';
import 'package:nordeste_servicos_app/data/models/prioridade_os_model.dart';
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';
import 'package:nordeste_servicos_app/data/models/usuario_model.dart';

// Importe a ENTIDADE (camada de domínio)
import '../../domain/entities/ordem_servico.dart';
import '../../domain/entities/usuario.dart';

// Importe seus conversores const aqui
// ASSUMINDO QUE VOCÊ TEM ESTES ARQUIVOS:


part 'ordem_servico_model.g.dart';

// *** CORREÇÃO AQUI: REATIVAR explicitToJson e adicionar conversores se usados a nível de classe ***
@JsonSerializable(
  explicitToJson: true, // <<< ISSO É CRÍTICO para objetos aninhados como UsuarioModel
)
class OrdemServicoModel {
  final int? id;
  final String numeroOS;
  final StatusOSModel status; // Este campo será tratado pelo StatusOSModelConverter
  final DateTime? dataAbertura;
  final DateTime? dataAgendamento;
  final DateTime? dataFechamento;
  final DateTime? dataHoraEmissao;

  final int clienteId;
  final String? nomeCliente;
  final int equipamentoId;
  final String? descricaoEquipamento;

  @JsonKey(name: 'tecnicoAtribuido')
  final UsuarioModel? tecnicoAtribuidoModel;

  final String? problemaRelatado;
  final String? analiseFalha;
  final String? solucaoAplicada;

  final PrioridadeOSModel? prioridade; // Este campo será tratado pelo PrioridadeOSModelConverter


  OrdemServicoModel({
    this.id,
    required this.numeroOS,
    required this.status,
    this.dataAbertura,
    this.dataAgendamento,
    this.dataFechamento,
    this.dataHoraEmissao,
    required this.clienteId,
    this.nomeCliente,
    required this.equipamentoId,
    this.descricaoEquipamento,
    this.tecnicoAtribuidoModel,
    this.problemaRelatado,
    this.analiseFalha,
    this.solucaoAplicada,
    this.prioridade,
  });

  factory OrdemServicoModel.fromJson(Map<String, dynamic> json) =>
      _$OrdemServicoModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrdemServicoModelToJson(this);

  // ... (seus métodos toEntity e fromEntity - eles já estão corretos com tecnicoAtribuidoModel) ...

  OrdemServico toEntity() {
    // ... (lógica de conversão de status e prioridade) ...

    Usuario? tecnicoAtribuidoEntity;
    if (tecnicoAtribuidoModel != null) {
      tecnicoAtribuidoEntity = tecnicoAtribuidoModel!.toEntity();
    }

    return OrdemServico(
      id: id,
      numeroOS: numeroOS,
      status: status, // Aqui já é o StatusOSModel, que é o mesmo da entidade
      prioridade: prioridade, // Aqui já é o PrioridadeOSModel, que é o mesmo da entidade
      dataAbertura: dataAbertura,
      dataAgendamento: dataAgendamento,
      dataFechamento: dataFechamento,
      dataHoraEmissao: dataHoraEmissao,
      clienteId: clienteId,
      nomeCliente: nomeCliente,
      equipamentoId: equipamentoId,
      descricaoEquipamento: descricaoEquipamento,
      tecnicoAtribuido: tecnicoAtribuidoEntity,
      problemaRelatado: problemaRelatado,
      analiseFalha: analiseFalha,
      solucaoAplicada: solucaoAplicada,
    );
  }

  factory OrdemServicoModel.fromEntity(OrdemServico entity) {
    // ... (lógica de conversão de status e prioridade) ...

    return OrdemServicoModel(
      id: entity.id,
      numeroOS: entity.numeroOS,
      status: entity.status, // Já é o StatusOSModel (enum)
      prioridade: entity.prioridade, // Já é o PrioridadeOSModel (enum)
      dataAbertura: entity.dataAbertura,
      dataAgendamento: entity.dataAgendamento,
      dataFechamento: entity.dataFechamento,
      dataHoraEmissao: entity.dataHoraEmissao,
      clienteId: entity.clienteId,
      nomeCliente: entity.nomeCliente,
      equipamentoId: entity.equipamentoId,
      descricaoEquipamento: entity.descricaoEquipamento,
      tecnicoAtribuidoModel: entity.tecnicoAtribuido != null
          ? UsuarioModel.fromEntity(entity.tecnicoAtribuido!)
          : null,
      problemaRelatado: entity.problemaRelatado,
      analiseFalha: entity.analiseFalha,
      solucaoAplicada: entity.solucaoAplicada,
    );
  }
}