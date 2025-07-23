// lib/domain/repositories/os_repository.dart

import 'dart:typed_data';

import '../../data/models/prioridade_os_model.dart';
import '../../domain/entities/ordem_servico.dart';
import '../../data/models/status_os_model.dart';


abstract class OsRepository {
  /// Obtém a lista de ordens de serviço, com opções de filtro.
  Future<List<OrdemServico>> getOrdensServico({
    String? searchTerm,
    int? clienteId,
    int? tecnicoId,
    StatusOSModel? status,
    DateTime? dataAgendamento,
  });

  /// Obtém uma ordem de serviço pelo seu ID.
  Future<OrdemServico> getOrdemServicoById(int id);

  /// Cria uma nova ordem de serviço.
  Future<OrdemServico> createOrdemServico(
      OrdemServico os); // Pode precisar de um DTO de criação

  /// Atualiza uma ordem de serviço existente.
  Future<void> updateOrdemServico({
    required int osId, // ID da OS a ser atualizada
    required int clienteId,
    required int equipamentoId,
    int? tecnicoAtribuidoId,
    required String problemaRelatado,
    String? analiseFalha,
    String? solucaoAplicada,
    required StatusOSModel status,
    PrioridadeOSModel? prioridade,
    DateTime? dataAgendamento,
  });

  /// Deleta uma ordem de serviço pelo seu ID.
  Future<void> deleteOrdemServico(int id);

  /// Baixa o relatório em PDF de uma OS específica.
  /// Retorna os bytes do arquivo.
  Future<Uint8List> downloadOsPdf(int osId);

  /// Atualiza o status de uma ordem de serviço.
  Future<void> updateOrdemServicoStatus(int id, StatusOSModel status);

// Métodos para gerenciar detalhes da OS (alternativa a repositórios separados para detalhes)
// Future<List<RegistroTempo>> getRegistrosTempoByOsId(int osId);
// Future<RegistroTempo> createRegistroTempo(RegistroTempo registro); // Pode precisar de DTO
// Future<void> deleteRegistroTempo(int id);

// Future<List<ItemOSUtilizado>> getItensUtilizadosByOsId(int osId);
// Future<ItemOSUtilizado> createItemOSUtilizado(ItemOSUtilizado item); // Pode precisar de DTO
// Future<void> deleteItemOSUtilizado(int id);

// Future<List<RegistroDeslocamento>> getRegistrosDeslocamentoByOsId(int osId);
// Future<RegistroDeslocamento> createRegistroDeslocamento(RegistroDeslocamento registro); // Pode precisar de DTO
// Future<void> deleteRegistroDeslocamento(int id);

// Future<List<FotoOS>> getFotosByOsId(int osId);
// Future<FotoOS> uploadFoto(int osId, File fotoFile); // Lidar com File em camada superior ou DTO
// Future<void> deleteFoto(int fotoId);

// Future<AssinaturaOS?> getAssinaturaByOsId(int osId);
// Future<AssinaturaOS> uploadAssinatura(int osId, File signatureFile); // Lidar com File em camada superior ou DTO
// Future<void> deleteAssinatura(int osId); // Deleta pelo ID da OS ou da Assinatura?

  /// Obtém o próximo número de OS disponível (ex: #2550).
  /// Retorna null se não conseguir obter.
  Future<String?> getNextOsNumber();
}
