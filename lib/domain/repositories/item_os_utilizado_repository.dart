// lib/domain/repositories/item_os_utilizado_repository.dart


import '../entities/item_os_utilizado.dart';
import '/core/error/exceptions.dart';

abstract class ItemOSUtilizadoRepository {
  /// Obtém a lista de itens utilizados para uma OS específica.
  Future<List<ItemOSUtilizado>> getItensUtilizadosByOsId(int osId);

  /// Obtém um item utilizado pelo seu ID.
  Future<ItemOSUtilizado> getItemOSUtilizadoById(int id);

  /// Adiciona um novo item utilizado a uma OS.
  Future<ItemOSUtilizado> createItemOSUtilizado(ItemOSUtilizado item); // Pode precisar de DTO

  /// Atualiza um item utilizado existente.
  Future<ItemOSUtilizado> updateItemOSUtilizado(ItemOSUtilizado item); // Pode precisar de DTO

  /// Deleta um item utilizado pelo seu ID.
  Future<void> deleteItemOSUtilizado(int id);
}