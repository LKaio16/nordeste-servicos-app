// lib/domain/entities/ordem_servico.dart

import '../../data/models/prioridade_os_model.dart';
import '../../data/models/status_os_model.dart'; // Reutilizando o enum model
// Importar as entidades de detalhe se você quiser que elas estejam diretamente na entidade OS
// import 'registro_tempo.dart';
// import 'registro_deslocamento.dart';
// import 'item_os_utilizado.dart';
// import 'foto_os.dart';
// import 'assinatura_os.dart';

class OrdemServico {
  final int? id;
  final String numeroOS;
  final StatusOSModel status;
  final DateTime? dataAbertura;
  final DateTime? dataAgendamento;
  final DateTime? dataFechamento;
  final DateTime? dataHoraEmissao;

  final int clienteId;
  final String? nomeCliente; // Mantido aqui se o Model já o traz
  final int equipamentoId;
  final String? descricaoEquipamento; // Mantido aqui se o Model já o traz
  final int? tecnicoAtribuidoId;
  final String? nomeTecnicoAtribuido; // Mantido aqui se o Model já o traz

  final String? problemaRelatado;
  final String? analiseFalha;
  final String? solucaoAplicada;

  final PrioridadeOSModel? prioridade;

  // Se quiser as listas de detalhes aqui, adicione os campos (mas geralmente não na entidade principal para evitar carregar tudo)
  // final List<RegistroTempo>? registrosTempo;
  // final List<ItemOSUtilizado>? itensUtilizados;
  // ...

  OrdemServico({
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
}