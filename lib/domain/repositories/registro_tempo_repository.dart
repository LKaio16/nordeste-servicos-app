// lib/domain/repositories/registro_tempo_repository.dart


import '../entities/registro_tempo.dart';
import '/core/error/exceptions.dart';

abstract class RegistroTempoRepository {
  /// Obtém a lista de registros de tempo para uma OS específica.
  Future<List<RegistroTempo>> getRegistrosTempoByOsId(int osId);

  /// Obtém um registro de tempo pelo seu ID.
  Future<RegistroTempo> getRegistroTempoById(int id);

  /// Cria um novo registro de tempo (inicia timer).
  Future<RegistroTempo> createRegistroTempo(RegistroTempo registro); // Pode precisar de DTO

  /// Finaliza um registro de tempo (para timer).
  Future<RegistroTempo> finalizarRegistroTempo(int id); // Ou talvez passar o registro completo

  /// Deleta um registro de tempo pelo seu ID.
  Future<void> deleteRegistroTempo(int id);
}