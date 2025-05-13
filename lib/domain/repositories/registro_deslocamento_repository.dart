// lib/domain/repositories/registro_deslocamento_repository.dart


import '../entities/registro_deslocamento.dart';
import '/core/error/exceptions.dart';

abstract class RegistroDeslocamentoRepository {
  /// Obtém a lista de registros de deslocamento para uma OS específica.
  Future<List<RegistroDeslocamento>> getRegistrosDeslocamentoByOsId(int osId);

  /// Obtém um registro de deslocamento pelo seu ID.
  Future<RegistroDeslocamento> getRegistroDeslocamentoById(int id);

  /// Cria um novo registro de deslocamento.
  Future<RegistroDeslocamento> createRegistroDeslocamento(RegistroDeslocamento registro); // Pode precisar de DTO

  /// Atualiza um registro de deslocamento existente.
  Future<RegistroDeslocamento> updateRegistroDeslocamento(RegistroDeslocamento registro); // Pode precisar de DTO

  /// Deleta um registro de deslocamento pelo seu ID.
  Future<void> deleteRegistroDeslocamento(int id);
}