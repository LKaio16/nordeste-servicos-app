// lib/data/repositories/cliente_repository_impl.dart

import 'package:dio/dio.dart'; // Importe Dio para tratar DioException
import '../../core/network/api_client.dart'; // Importe o ApiClient
import '../../core/error/exceptions.dart'; // Importe as exceções customizadas

// *** CORREÇÃO: Importar DTO e Model corretos ***
import '../models/cliente_model.dart'; // Modelo para receber dados da API (já atualizado)
import '../models/cliente_request_dto.dart'; // DTO para enviar dados para a API

import '../../domain/entities/cliente.dart'; // Importe a entidade de domínio (já atualizada)
import '../../domain/repositories/cliente_repository.dart'; // Importe a interface do repositório

// Implementação concreta da interface ClienteRepository
class ClienteRepositoryImpl implements ClienteRepository {
  final ApiClient apiClient; // Dependência do ApiClient

  // Construtor que recebe a dependência
  ClienteRepositoryImpl(this.apiClient);

  @override
  Future<List<Cliente>> getClientes() async {
    try {
      final response = await apiClient.get('/clientes');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        // Usa o ClienteModel atualizado para desserializar
        final List<ClienteModel> clienteModels = jsonList.map((json) => ClienteModel.fromJson(json)).toList();
        // Converte para a entidade Cliente atualizada
        final List<Cliente> clientes = clienteModels.map((model) => model.toEntity()).toList();
        return clientes;
      } else {
        throw ApiException('Falha ao carregar clientes: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar clientes: ${e.message}');
    } catch (e, stackTrace) {
      print("ERROR getClientes: ${e.toString()}");
      print(stackTrace);
      throw ApiException('Erro inesperado ao carregar clientes: ${e.toString()}');
    }
  }

  @override
  Future<Cliente> getClienteById(int id) async {
    try {
      final response = await apiClient.get('/clientes/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        // Usa o ClienteModel atualizado
        final ClienteModel clienteModel = ClienteModel.fromJson(json);
        // Converte para a entidade Cliente atualizada
        final Cliente cliente = clienteModel.toEntity();
        return cliente;
      } else {
        throw ApiException('Falha ao carregar cliente $id: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar cliente $id: ${e.message}');
    } catch (e, stackTrace) {
      print("ERROR getClienteById: ${e.toString()}");
      print(stackTrace);
      throw ApiException('Erro inesperado ao carregar cliente $id: ${e.toString()}');
    }
  }

  // *** CORREÇÃO: Método createCliente recebe ClienteRequestDTO ***
  @override
  Future<Cliente> createCliente(ClienteRequestDTO dto) async {
    try {
      // Envia o DTO diretamente para a API
      final response = await apiClient.post('/clientes', data: dto.toJson());

      if (response.statusCode == 201) { // Status 201 Created
        final Map<String, dynamic> json = response.data;
        // Recebe a resposta como ClienteModel (que já está atualizado)
        final ClienteModel createdClienteModel = ClienteModel.fromJson(json);
        // Converte para a entidade Cliente atualizada
        return createdClienteModel.toEntity();
      } else {
        throw ApiException('Falha ao criar cliente: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      // Adiciona log da resposta em caso de erro Dio
      print("ERROR createCliente DioException Response: ${e.response?.data}");
      throw ApiException('Erro de rede ao criar cliente: ${e.message}');
    } catch (e, stackTrace) {
      print("ERROR createCliente: ${e.toString()}");
      print(stackTrace);
      throw ApiException('Erro inesperado ao criar cliente: ${e.toString()}');
    }
  }

  // *** CORREÇÃO: Método updateCliente recebe ID e ClienteRequestDTO ***
  @override
  Future<Cliente> updateCliente(int id, ClienteRequestDTO dto) async {
    try {
      // Envia o DTO diretamente para a API
      final response = await apiClient.put('/clientes/$id', data: dto.toJson());

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        // Recebe a resposta como ClienteModel (atualizado)
        final ClienteModel updatedClienteModel = ClienteModel.fromJson(json);
        // Converte para a entidade Cliente atualizada
        return updatedClienteModel.toEntity();
      } else {
        throw ApiException('Falha ao atualizar cliente $id: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      print("ERROR updateCliente DioException Response: ${e.response?.data}");
      throw ApiException('Erro de rede ao atualizar cliente $id: ${e.message}');
    } catch (e, stackTrace) {
      print("ERROR updateCliente: ${e.toString()}");
      print(stackTrace);
      throw ApiException('Erro inesperado ao atualizar cliente $id: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCliente(int id) async {
    try {
      final response = await apiClient.delete('/clientes/$id');

      if (response.statusCode == 204) { // Status 204 No Content
        return; // Sucesso
      } else {
        throw ApiException('Falha ao deletar cliente $id: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      print("ERROR deleteCliente DioException Response: ${e.response?.data}");
      throw ApiException('Erro de rede ao deletar cliente $id: ${e.message}');
    } catch (e, stackTrace) {
      print("ERROR deleteCliente: ${e.toString()}");
      print(stackTrace);
      throw ApiException('Erro inesperado ao deletar cliente $id: ${e.toString()}');
    }
  }
}

