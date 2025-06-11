// lib/domain/repositories/os_repository.dart

import '../../data/models/prioridade_os_model.dart';
import '../../domain/entities/ordem_servico.dart';
import '../../domain/entities/registro_tempo.dart'; // Se quiser retornar a lista aqui
import '../../domain/entities/item_os_utilizado.dart'; // Se quiser retornar a lista aqui
import '../../domain/entities/registro_deslocamento.dart'; // Se quiser retornar a lista aqui
import '../../domain/entities/foto_os.dart'; // Se quiser retornar a lista aqui
import '../../domain/entities/assinatura_os.dart'; // Se quiser retornar aqui
import '../../data/models/status_os_model.dart'; // Para usar o enum como parâmetro
import '../../data/models/status_os_model.dart';
import '../entities/ordem_servico.dart';
import '/core/error/exceptions.dart';

abstract class OsRepository {
  /// Obtém a lista de ordens de serviço, com opções de filtro.
  Future<List<OrdemServico>> getOrdensServico({
    int? clienteId,
    int? tecnicoId,
    StatusOSModel? status,
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
