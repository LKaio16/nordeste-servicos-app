// lib/domain/repositories/cliente_repository.dart

import '../entities/cliente.dart';
import '/core/error/exceptions.dart';

abstract class ClienteRepository {
  /// Obtém a lista de todos os clientes.
  /// Lança [ApiException] em caso de falha na comunicação.
  Future<List<Cliente>> getClientes();

  /// Obtém um cliente pelo seu ID.
  /// Lança [ApiException] ou [NotFoundException] se o cliente não for encontrado.
  Future<Cliente> getClienteById(int id);

  /// Cria um novo cliente.
  /// Lança [ApiException] ou [BusinessException] em caso de validação da API.
  Future<Cliente> createCliente(Cliente cliente);

  /// Atualiza um cliente existente.
  /// Lança [ApiException], [BusinessException] ou [NotFoundException].
  Future<Cliente> updateCliente(Cliente cliente);

  /// Deleta um cliente pelo seu ID.
  /// Lança [ApiException] ou [NotFoundException].
  Future<void> deleteCliente(int id);
}