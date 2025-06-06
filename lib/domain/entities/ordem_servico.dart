import 'package:equatable/equatable.dart';
import 'package:nordeste_servicos_app/data/models/prioridade_os_model.dart';
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';


// Modelo de dados para Ordem de Serviço, baseado no OrdemServicoResponseDTO da API
class OrdemServico extends Equatable {
  final int? id; // Tornando ID opcional para criação, mas presente na edição/visualização
  final String numeroOS;
  final StatusOSModel status;
  final PrioridadeOSModel? prioridade; // Tornando prioridade opcional
  final DateTime? dataAbertura;
  final DateTime? dataAgendamento;
  final DateTime? dataFechamento;
  final DateTime? dataHoraEmissao; // Adicionado campo que estava no model mas não aqui
  final int clienteId;
  final String? nomeCliente; // Opcional, pode vir da API ou ser buscado separadamente
  final int equipamentoId;
  final String? descricaoEquipamento; // Opcional
  final int? tecnicoAtribuidoId;
  final String? nomeTecnicoAtribuido; // Opcional
  final String? problemaRelatado;
  final String? analiseFalha; // Adicionado campo que estava no model mas não aqui
  final String? solucaoAplicada; // Adicionado campo que estava no model mas não aqui

  const OrdemServico({
    this.id,
    required this.numeroOS,
    required this.status,
    this.prioridade,
    this.dataAbertura,
    this.dataAgendamento,
    this.dataFechamento,
    this.dataHoraEmissao, // Adicionado
    required this.clienteId,
    this.nomeCliente,
    required this.equipamentoId,
    this.descricaoEquipamento,
    this.tecnicoAtribuidoId,
    this.nomeTecnicoAtribuido,
    this.problemaRelatado,
    this.analiseFalha, // Adicionado
    this.solucaoAplicada, // Adicionado
  });

  // Fábrica para criar instância a partir de um JSON (mapa)
  factory OrdemServico.fromJson(Map<String, dynamic> json) {
    return OrdemServico(
      id: json['id'] as int?,
      numeroOS: json['numeroOS'] as String? ?? '',
      status: _parseStatusOS(json['status'] as String?),
      prioridade: _parsePrioridadeOS(json['prioridade'] as String?),
      dataAbertura: json['dataAbertura'] != null ? DateTime.tryParse(json['dataAbertura'] as String) : null,
      dataAgendamento: json['dataAgendamento'] != null ? DateTime.tryParse(json['dataAgendamento'] as String) : null,
      dataFechamento: json['dataFechamento'] != null ? DateTime.tryParse(json['dataFechamento'] as String) : null,
      dataHoraEmissao: json['dataHoraEmissao'] != null ? DateTime.tryParse(json['dataHoraEmissao'] as String) : null,
      clienteId: json['clienteId'] as int? ?? 0,
      nomeCliente: json['nomeCliente'] as String?,
      equipamentoId: json['equipamentoId'] as int? ?? 0,
      descricaoEquipamento: json['descricaoEquipamento'] as String?,
      tecnicoAtribuidoId: json['tecnicoAtribuidoId'] as int?,
      nomeTecnicoAtribuido: json['nomeTecnicoAtribuido'] as String?,
      problemaRelatado: json['problemaRelatado'] as String?,
      analiseFalha: json['analiseFalha'] as String?,
      solucaoAplicada: json['solucaoAplicada'] as String?,
    );
  }

  // Funções auxiliares para parsear Enums de String (case-insensitive)
  // CORREÇÃO: Removido fallback para UNKNOWN. Usando um default ou lançando erro.
  static StatusOSModel _parseStatusOS(String? statusString) {
    if (statusString == null) return StatusOSModel.EM_ABERTO; // Default
    try {
      return StatusOSModel.values.firstWhere(
            (e) => e.name.toUpperCase() == statusString.toUpperCase(),
        // orElse: () => throw FormatException('StatusOS inválido: $statusString'), // Alternativa: lançar erro
      );
    } catch (e) {
      print("Erro ao parsear StatusOS: $statusString. Usando EM_ABERTO como padrão.");
      return StatusOSModel.EM_ABERTO; // Default em caso de erro no firstWhere
    }
  }

  static PrioridadeOSModel? _parsePrioridadeOS(String? prioridadeString) {
    if (prioridadeString == null) return null; // Prioridade pode ser nula
    try {
      return PrioridadeOSModel.values.firstWhere(
            (e) => e.name.toUpperCase() == prioridadeString.toUpperCase(),
        // orElse: () => throw FormatException('PrioridadeOS inválida: $prioridadeString'), // Alternativa
      );
    } catch (e) {
      print("Erro ao parsear PrioridadeOS: $prioridadeString. Retornando null.");
      return null; // Retorna null se não encontrar ou der erro
    }
  }

  // *** MÉTODO copyWith ADICIONADO ***
  OrdemServico copyWith({
    int? id,
    String? numeroOS,
    StatusOSModel? status,
    PrioridadeOSModel? prioridade,
    DateTime? dataAbertura,
    DateTime? dataAgendamento,
    DateTime? dataFechamento,
    DateTime? dataHoraEmissao,
    int? clienteId,
    String? nomeCliente,
    int? equipamentoId,
    String? descricaoEquipamento,
    int? tecnicoAtribuidoId,
    String? nomeTecnicoAtribuido,
    String? problemaRelatado,
    String? analiseFalha,
    String? solucaoAplicada,
  }) {
    return OrdemServico(
      id: id ?? this.id,
      numeroOS: numeroOS ?? this.numeroOS,
      status: status ?? this.status,
      // Para prioridade, permite definir como null explicitamente se necessário
      prioridade: prioridade ?? this.prioridade,
      dataAbertura: dataAbertura ?? this.dataAbertura,
      // Para datas, permite definir como null explicitamente
      dataAgendamento: dataAgendamento ?? this.dataAgendamento,
      dataFechamento: dataFechamento ?? this.dataFechamento,
      dataHoraEmissao: dataHoraEmissao ?? this.dataHoraEmissao,
      clienteId: clienteId ?? this.clienteId,
      nomeCliente: nomeCliente ?? this.nomeCliente,
      equipamentoId: equipamentoId ?? this.equipamentoId,
      descricaoEquipamento: descricaoEquipamento ?? this.descricaoEquipamento,
      // Permite definir tecnicoAtribuidoId como null
      tecnicoAtribuidoId: tecnicoAtribuidoId ?? this.tecnicoAtribuidoId,
      nomeTecnicoAtribuido: nomeTecnicoAtribuido ?? this.nomeTecnicoAtribuido,
      problemaRelatado: problemaRelatado ?? this.problemaRelatado,
      analiseFalha: analiseFalha ?? this.analiseFalha,
      solucaoAplicada: solucaoAplicada ?? this.solucaoAplicada,
    );
  }


  @override
  List<Object?> get props => [
    id,
    numeroOS,
    status,
    prioridade,
    dataAbertura,
    dataAgendamento,
    dataFechamento,
    dataHoraEmissao,
    clienteId,
    nomeCliente,
    equipamentoId,
    descricaoEquipamento,
    tecnicoAtribuidoId,
    nomeTecnicoAtribuido,
    problemaRelatado,
    analiseFalha,
    solucaoAplicada,
  ];
}

