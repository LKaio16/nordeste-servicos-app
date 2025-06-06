// lib/domain/repositories/cliente_repository.dart

import 'package:nordeste_servicos_app/domain/entities/cliente.dart';

import '../../data/models/cliente_request_dto.dart'; // Ajuste o caminho se necessário
import '/core/error/exceptions.dart';

abstract class ClienteRepository {
  /// Obtém a lista de todos os clientes.
  /// Lança [ApiException] em caso de falha na comunicação.
  Future<List<Cliente>> getClientes();

  /// Obtém um cliente pelo seu ID.
  /// Lança [ApiException] ou [NotFoundException] se o cliente não for encontrado.
  Future<Cliente> getClienteById(int id);

  // *** CORREÇÃO: createCliente recebe ClienteRequestDTO ***
  /// Cria um novo cliente.
  /// Lança [ApiException] ou [BusinessException] em caso de validação da API.
  Future<Cliente> createCliente(ClienteRequestDTO dto);

  // *** CORREÇÃO: updateCliente recebe ID e ClienteRequestDTO ***
  /// Atualiza um cliente existente.
  /// Lança [ApiException], [BusinessException] ou [NotFoundException].
  Future<Cliente> updateCliente(int id, ClienteRequestDTO dto);

  /// Deleta um cliente pelo seu ID.
  /// Lança [ApiException] ou [NotFoundException].
  Future<void> deleteCliente(int id);
}

