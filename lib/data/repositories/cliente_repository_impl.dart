// lib/data/repositories/cliente_repository_impl.dart

import 'package:dio/dio.dart'; // Importe Dio para tratar DioException
import '../../core/network/api_client.dart'; // Importe o ApiClient
import '../../core/error/exceptions.dart'; // Importe as exceções customizadas
import '../models/cliente_model.dart'; // Importe o modelo de dados
import '../../domain/entities/cliente.dart'; // Importe a entidade de domínio
import '../../domain/repositories/cliente_repository.dart'; // Importe a interface do repositório


// Implementação concreta da interface ClienteRepository
class ClienteRepositoryImpl implements ClienteRepository {
  final ApiClient apiClient; // Dependência do ApiClient

  // Construtor que recebe a dependência
  ClienteRepositoryImpl(this.apiClient);

  @override
  Future<List<Cliente>> getClientes() async {
    try {
      // Faz a chamada GET usando o ApiClient
      final response = await apiClient.get('/clientes');

      // Verifica se a resposta foi bem sucedida (status code 2xx)
      if (response.statusCode == 200) {
        // Converte a lista de JSONs para lista de ClienteModel
        final List<dynamic> jsonList = response.data;
        final List<ClienteModel> clienteModels = jsonList.map((json) => ClienteModel.fromJson(json)).toList();

        // Converte a lista de ClienteModel para lista de Cliente Entity
        final List<Cliente> clientes = clienteModels.map((model) => model.toEntity()).toList();

        return clientes;
      } else {
        // Se o status code não for 2xx, o ApiClient já deve ter lançado uma ApiException no _handleError
        // Mas esta parte é um fallback caso _handleError não cubra algum caso
         throw ApiException('Falha ao carregar clientes: Status ${response.statusCode}');
      }
    } on ApiException {
        // Relança a exceção de API tratada pelo ApiClient
       rethrow;
    } on DioException catch (e) {
      // Em alguns casos, o _handleError do ApiClient pode não ter sido invocado,
      // ou você pode querer um tratamento extra aqui.
       throw ApiException('Erro de rede ao carregar clientes: ${e.message}'); // Exemplo
    } catch (e) {
      // Captura outros erros inesperados
       throw ApiException('Erro inesperado ao carregar clientes: ${e.toString()}');
    }
  }

  @override
  Future<Cliente> getClienteById(int id) async {
     try {
      final response = await apiClient.get('/clientes/$id');

      if (response.statusCode == 200) {
        // Converte o JSON único para ClienteModel
        final Map<String, dynamic> json = response.data;
        final ClienteModel clienteModel = ClienteModel.fromJson(json);

        // Converte ClienteModel para Cliente Entity
        final Cliente cliente = clienteModel.toEntity();

        return cliente;
      } else {
         throw ApiException('Falha ao carregar cliente ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao carregar cliente ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao carregar cliente ${id}: ${e.toString()}');
    }
  }

  @override
  Future<Cliente> createCliente(Cliente cliente) async {
     try {
        // Converte Cliente Entity para ClienteModel (se necessário para serialização)
        // Ou crie um DTO de requisição específico se a API espera um formato diferente para POST
        // Por enquanto, vamos assumir que o Model pode ser usado para o corpo da requisição
        final ClienteModel clienteModel = ClienteModel(
           nomeRazaoSocial: cliente.nomeRazaoSocial,
           endereco: cliente.endereco,
           telefone: cliente.telefone,
           email: cliente.email,
           cnpjCpf: cliente.cnpjCpf,
           // ID não é enviado na criação
        );


      final response = await apiClient.post('/clientes', data: clienteModel.toJson()); // Envia o JSON do modelo

      if (response.statusCode == 201) { // Status 201 Created
        final Map<String, dynamic> json = response.data;
        final ClienteModel createdClienteModel = ClienteModel.fromJson(json);
        return createdClienteModel.toEntity();
      } else {
         throw ApiException('Falha ao criar cliente: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao criar cliente: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao criar cliente: ${e.toString()}');
    }
  }

  @override
  Future<Cliente> updateCliente(Cliente cliente) async {
      try {
        // Converte Cliente Entity para ClienteModel para serialização
        // Inclua o ID na atualização
         final ClienteModel clienteModel = ClienteModel(
            id: cliente.id, // Incluir ID
           nomeRazaoSocial: cliente.nomeRazaoSocial,
           endereco: cliente.endereco,
           telefone: cliente.telefone,
           email: cliente.email,
           cnpjCpf: cliente.cnpjCpf,
        );

      final response = await apiClient.put('/clientes/${cliente.id}', data: clienteModel.toJson());

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final ClienteModel updatedClienteModel = ClienteModel.fromJson(json);
        return updatedClienteModel.toEntity();
      } else {
         throw ApiException('Falha ao atualizar cliente ${cliente.id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao atualizar cliente ${cliente.id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao atualizar cliente ${cliente.id}: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCliente(int id) async {
     try {
      final response = await apiClient.delete('/clientes/$id');

      if (response.statusCode == 204) { // Status 204 No Content para sucesso na deleção
        return; // Sucesso, não há corpo na resposta
      } else {
          // TODO: Lidar com BusinessException da API se houver regras de deleção (ex: cliente com OS ativa)
         throw ApiException('Falha ao deletar cliente ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao deletar cliente ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao deletar cliente ${id}: ${e.toString()}');
    }
  }

  // Adicione um método toEntity() no seu ClienteModel se ainda não o fez,
  // para converter o Model (do JSON) para a Entity (do Domain).
  // Exemplo no arquivo cliente_model.dart:
  /*
  Cliente toEntity() {
    return Cliente(
      id: id,
      nomeRazaoSocial: nomeRazaoSocial,
      endereco: endereco,
      telefone: telefone,
      email: email,
      cnpjCpf: cnpjCpf,
    );
  }
  */
}