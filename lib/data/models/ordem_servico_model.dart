// lib/data/models/ordem_servico_model.dart

import 'package:json_annotation/json_annotation.dart';
// Importe os enums do MODELO (camada de dados)
import 'package:nordeste_servicos_app/data/models/prioridade_os_model.dart';
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';

// Importe a ENTIDADE (camada de domínio) e seus enums
import '../../domain/entities/ordem_servico.dart';

part 'ordem_servico_model.g.dart';

@JsonSerializable(
  // Explicitamente mapeia os enums para String ao serializar/desserializar JSON
  // Isso garante que a API receba/envie os nomes corretos dos enums
    converters: [StatusOSModelConverter(), PrioridadeOSModelConverter()]
)
class OrdemServicoModel {
  final int? id;
  final String numeroOS;
  final StatusOSModel status; // Enum do Model
  final DateTime? dataAbertura;
  final DateTime? dataAgendamento;
  final DateTime? dataFechamento;
  final DateTime? dataHoraEmissao;

  final int clienteId;
  final String? nomeCliente;
  final int equipamentoId;
  final String? descricaoEquipamento;
  final int? tecnicoAtribuidoId;
  final String? nomeTecnicoAtribuido;

  final String? problemaRelatado;
  final String? analiseFalha;
  final String? solucaoAplicada;

  final PrioridadeOSModel? prioridade; // Enum do Model (opcional)

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
    this.tecnicoAtribuidoId,
    this.nomeTecnicoAtribuido,
    this.problemaRelatado,
    this.analiseFalha,
    this.solucaoAplicada,
    this.prioridade,
  });

  factory OrdemServicoModel.fromJson(Map<String, dynamic> json) =>
      _$OrdemServicoModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrdemServicoModelToJson(this);

  // Método para converter Model para Entity
  OrdemServico toEntity() {
    // Converte StatusOSModel (Model) para StatusOS (Entity)
    StatusOSModel statusEntity;
    try {
      statusEntity = StatusOSModel.values.firstWhere(
            (e) => e.name == status.name, // Compara pelo nome
      );
    } catch (e) {
      print("WARN: Falha ao mapear StatusOSModel.${status.name} para StatusOS. Usando EM_ABERTO como fallback.");
      statusEntity = StatusOSModel.EM_ABERTO; // Fallback seguro
    }

    // Converte PrioridadeOSModel? (Model) para PrioridadeOS? (Entity)
    PrioridadeOSModel? prioridadeEntity;
    if (prioridade != null) {
      try {
        prioridadeEntity = PrioridadeOSModel.values.firstWhere(
              (e) => e.name == prioridade!.name, // Compara pelo nome
        );
      } catch (e) {
        print("WARN: Falha ao mapear PrioridadeOSModel.${prioridade!.name} para PrioridadeOS. Usando null como fallback.");
        prioridadeEntity = null; // Fallback seguro para prioridade opcional
      }
    }

    return OrdemServico(
      id: id,
      numeroOS: numeroOS,
      status: statusEntity, // Usa o enum da Entity convertido
      dataAbertura: dataAbertura,
      dataAgendamento: dataAgendamento,
      dataFechamento: dataFechamento,
      dataHoraEmissao: dataHoraEmissao,
      clienteId: clienteId,
      nomeCliente: nomeCliente,
      equipamentoId: equipamentoId,
      descricaoEquipamento: descricaoEquipamento,
      tecnicoAtribuidoId: tecnicoAtribuidoId,
      nomeTecnicoAtribuido: nomeTecnicoAtribuido,
      problemaRelatado: problemaRelatado,
      analiseFalha: analiseFalha,
      solucaoAplicada: solucaoAplicada,
      prioridade: prioridadeEntity, // Usa o enum da Entity convertido (ou null)
    );
  }

  // Método para converter Entity para Model
  factory OrdemServicoModel.fromEntity(OrdemServico entity) {
    // Converte StatusOS (Entity) para StatusOSModel (Model)
    StatusOSModel statusModel;
    try {
      statusModel = StatusOSModel.values.firstWhere(
            (m) => m.name == entity.status.name, // Compara pelo nome
      );
    } catch (e) {
      print("WARN: Falha ao mapear StatusOS.${entity.status.name} para StatusOSModel. Usando EM_ABERTO como fallback.");
      statusModel = StatusOSModel.EM_ABERTO; // Fallback seguro
    }

    // Converte PrioridadeOS? (Entity) para PrioridadeOSModel? (Model)
    PrioridadeOSModel? prioridadeModel;
    if (entity.prioridade != null) {
      try {
        prioridadeModel = PrioridadeOSModel.values.firstWhere(
              (m) => m.name == entity.prioridade!.name, // Compara pelo nome
        );
      } catch (e) {
        print("WARN: Falha ao mapear PrioridadeOS.${entity.prioridade!.name} para PrioridadeOSModel. Usando null como fallback.");
        prioridadeModel = null; // Fallback seguro
      }
    }

    return OrdemServicoModel(
      id: entity.id,
      numeroOS: entity.numeroOS,
      status: statusModel, // Usa o enum do Model convertido
      dataAbertura: entity.dataAbertura,
      dataAgendamento: entity.dataAgendamento,
      dataFechamento: entity.dataFechamento,
      dataHoraEmissao: entity.dataHoraEmissao,
      clienteId: entity.clienteId,
      // Campos de nome/descrição não são enviados na criação/atualização geralmente
      // nomeCliente: entity.nomeCliente,
      equipamentoId: entity.equipamentoId,
      // descricaoEquipamento: entity.descricaoEquipamento,
      tecnicoAtribuidoId: entity.tecnicoAtribuidoId,
      // nomeTecnicoAtribuido: entity.nomeTecnicoAtribuido,
      problemaRelatado: entity.problemaRelatado,
      analiseFalha: entity.analiseFalha,
      solucaoAplicada: entity.solucaoAplicada,
      prioridade: prioridadeModel, // Usa o enum do Model convertido (ou null)
    );
  }
}

// --- Json Converters para Enums ---
// Necessário para o build_runner gerar o código corretamente

class StatusOSModelConverter implements JsonConverter<StatusOSModel, String> {
  const StatusOSModelConverter();

  @override
  StatusOSModel fromJson(String json) {
    try {
      return StatusOSModel.values.firstWhere((e) => e.name == json);
    } catch (e) {
      print("WARN: StatusOSModel inválido recebido do JSON: '$json'. Usando EM_ABERTO.");
      return StatusOSModel.EM_ABERTO; // Fallback seguro
    }
  }

  @override
  String toJson(StatusOSModel object) => object.name;
}

class PrioridadeOSModelConverter implements JsonConverter<PrioridadeOSModel?, String?> {
  const PrioridadeOSModelConverter();

  @override
  PrioridadeOSModel? fromJson(String? json) {
    if (json == null) return null;
    try {
      return PrioridadeOSModel.values.firstWhere((e) => e.name == json);
    } catch (e) {
      print("WARN: PrioridadeOSModel inválida recebida do JSON: '$json'. Usando null.");
      return null; // Fallback seguro para prioridade opcional
    }
  }

  @override
  String? toJson(PrioridadeOSModel? object) => object?.name;
}

