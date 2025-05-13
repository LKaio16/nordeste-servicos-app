// lib/domain/repositories/equipamento_repository.dart

import '../entities/equipamento.dart';
import '/core/error/exceptions.dart';

abstract class EquipamentoRepository {
  /// Obtém a lista de todos os equipamentos, opcionalmente filtrando por cliente.
  Future<List<Equipamento>> getEquipamentos({int? clienteId});

  /// Obtém um equipamento pelo seu ID.
  Future<Equipamento> getEquipamentoById(int id);

  /// Cria um novo equipamento.
  Future<Equipamento> createEquipamento(Equipamento equipamento);

  /// Atualiza um equipamento existente.
  Future<Equipamento> updateEquipamento(Equipamento equipamento);

  /// Deleta um equipamento pelo seu ID.
  Future<void> deleteEquipamento(int id);
}