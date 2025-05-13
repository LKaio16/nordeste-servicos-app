// lib/domain/repositories/peca_material_repository.dart


import '../entities/peca_material.dart';
import '/core/error/exceptions.dart';

abstract class PecaMaterialRepository {
  /// Obtém a lista de todas as peças/materiais.
  Future<List<PecaMaterial>> getPecasMateriais();

  /// Obtém uma peça/material pelo seu ID.
  Future<PecaMaterial> getPecaMaterialById(int id);

  /// Cria uma nova peça/material.
  Future<PecaMaterial> createPecaMaterial(PecaMaterial pecaMaterial);

  /// Atualiza uma peça/material existente.
  Future<PecaMaterial> updatePecaMaterial(PecaMaterial pecaMaterial);

  /// Deleta uma peça/material pelo seu ID.
  Future<void> deletePecaMaterial(int id);
}