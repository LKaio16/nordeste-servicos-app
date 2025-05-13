// lib/domain/repositories/tipo_servico_repository.dart


import '../entities/tipo_servico.dart';
import '/core/error/exceptions.dart';

abstract class TipoServicoRepository {
  /// Obtém a lista de todos os tipos de serviço.
  Future<List<TipoServico>> getTiposServico();

  /// Obtém um tipo de serviço pelo seu ID.
  Future<TipoServico> getTipoServicoById(int id);

  /// Cria um novo tipo de serviço.
  Future<TipoServico> createTipoServico(TipoServico tipoServico);

  /// Atualiza um tipo de serviço existente.
  Future<TipoServico> updateTipoServico(TipoServico tipoServico);

  /// Deleta um tipo de serviço pelo seu ID.
  Future<void> deleteTipoServico(int id);
}