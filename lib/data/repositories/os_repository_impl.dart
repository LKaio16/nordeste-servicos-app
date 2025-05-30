// lib/data/repositories/os_repository_impl.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Import for kDebugMode
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';
import '../models/ordem_servico_model.dart'; // Importe o modelo de dados
import '../../domain/entities/ordem_servico.dart'; // Importe a entidade de domínio
import '../../domain/repositories/os_repository.dart'; // Importe a interface do repositório
import '../../data/models/status_os_model.dart'; // Para usar o enum como parâmetro


class OsRepositoryImpl implements OsRepository {
  final ApiClient apiClient;

  OsRepositoryImpl(this.apiClient);

  @override
  Future<List<OrdemServico>> getOrdensServico({
    int? clienteId,
    int? tecnicoId,
    StatusOSModel? status,
  }) async {
    try {
      // Prepara os parâmetros de query (opcionais)
      final Map<String, dynamic> queryParameters = {};
      if (clienteId != null) {
        queryParameters['clienteId'] = clienteId;
      }
      if (tecnicoId != null) {
        queryParameters['tecnicoId'] = tecnicoId;
      }
      if (status != null) {
        queryParameters['status'] = status.name; // Envia o nome do enum como String
      }

      // Assume que apiClient.get lida com a decodificação JSON por padrão
      final response = await apiClient.get('/ordens-servico', queryParameters: queryParameters); // Endpoint da sua API

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        final List<OrdemServicoModel> osModels = jsonList.map((json) => OrdemServicoModel.fromJson(json)).toList();
        final List<OrdemServico> ordensServico = osModels.map((model) => model.toEntity()).toList();
        return ordensServico;
      } else {
        throw ApiException('Falha ao carregar ordens de serviço: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar ordens de serviço: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar ordens de serviço: ${e.toString()}');
    }
  }

  @override
  Future<OrdemServico> getOrdemServicoById(int id) async {
    try {
      final response = await apiClient.get('/ordens-servico/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final OrdemServicoModel osModel = OrdemServicoModel.fromJson(json);
        return osModel.toEntity();
      } else {
        throw ApiException('Falha ao carregar ordem de serviço $id: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar ordem de serviço $id: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar ordem de serviço $id: ${e.toString()}');
    }
  }

  @override
  Future<OrdemServico> createOrdemServico(OrdemServico os) async {
    try {
      final OrdemServicoModel osModel = OrdemServicoModel.fromEntity(os);
      // *** CORREÇÃO: Removido o parâmetro 'options' ***
      final response = await apiClient.post(
        '/ordens-servico',
        data: osModel.toJson(),
        // options: Options(responseType: ResponseType.json), // REMOVIDO
      );

      if (response.statusCode == 201) {
        // Se o status for 201, tenta fazer o parse do JSON
        final Map<String, dynamic> json = response.data;
        final OrdemServicoModel createdOsModel = OrdemServicoModel.fromJson(json);
        return createdOsModel.toEntity();
      } else {
        // Trata outros códigos de sucesso inesperados
        throw ApiException('Falha ao criar ordem de serviço: Status inesperado ${response.statusCode}');
      }
    } on DioException catch (e, stackTrace) { // Adicionado stackTrace
      // Trata erros do Dio (rede, timeout, status != 2xx)
      String errorMessage = 'Erro de rede ao criar ordem de serviço.';
      if (e.response != null) {
        // Tenta extrair uma mensagem de erro mais específica do corpo da resposta
        errorMessage = 'Falha ao criar OS (Status ${e.response?.statusCode}): ';
        if (e.response?.data != null) {
          // Verifica se a resposta é uma string simples (provável erro em texto plano)
          if (e.response?.data is String) {
            errorMessage += e.response!.data;
          }
          // Verifica se é um JSON com campo 'message' ou 'error'
          else if (e.response?.data is Map<String, dynamic>) {
            final responseData = e.response!.data as Map<String, dynamic>;
            errorMessage += responseData['message'] ?? responseData['error'] ?? responseData.toString();
          } else {
            // Fallback para a representação em string dos dados
            errorMessage += e.response!.data.toString();
          }
        } else {
          errorMessage += e.message ?? 'Erro desconhecido da API.';
        }
      } else {
        // Erro sem resposta (ex: problema de rede)
        errorMessage = 'Erro de conexão ao criar OS: ${e.message}';
      }
      // *** LOG DETALHADO NO CONSOLE ***
      if (kDebugMode) {
        print('*******************************************');
        print('*** ERRO DioException em createOrdemServico ***');
        print('Mensagem: $errorMessage');
        print('Erro Original: ${e.error}');
        print('Tipo do Erro: ${e.type}');
        print('Resposta da API (data): ${e.response?.data}');
        print('Stack Trace:');
        print(stackTrace);
        print('*******************************************');
      }
      throw ApiException(errorMessage); // Lança exceção personalizada com a mensagem detalhada
    } on ApiException {
      rethrow; // Relança exceções personalizadas já tratadas
    } catch (e, stackTrace) { // Adicionado stackTrace
      // Captura outros erros inesperados (ex: erro de parse se a API retornar JSON malformado no sucesso)
      // *** LOG DETALHADO NO CONSOLE ***
      if (kDebugMode) {
        print('*******************************************');
        print('*** ERRO Geral em createOrdemServico ***');
        print('Erro: ${e.toString()}');
        print('Tipo do Erro: ${e.runtimeType}');
        print('Stack Trace:');
        print(stackTrace);
        print('*******************************************');
      }
      throw ApiException('Erro inesperado ao criar ordem de serviço: ${e.toString()}');
    }
  }


  @override
  Future<OrdemServico> updateOrdemServico(OrdemServico os) async {
    try {
      final OrdemServicoModel osModel = OrdemServicoModel.fromEntity(os);

      final response = await apiClient.put('/ordens-servico/${os.id}', data: osModel.toJson());

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final OrdemServicoModel updatedOsModel = OrdemServicoModel.fromJson(json);
        return updatedOsModel.toEntity();
      } else {
        throw ApiException('Falha ao atualizar ordem de serviço ${os.id}: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      // Tratamento de erro similar ao createOrdemServico pode ser adicionado aqui
      throw ApiException('Erro de rede ao atualizar ordem de serviço ${os.id}: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao atualizar ordem de serviço ${os.id}: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteOrdemServico(int id) async {
    try {
      final response = await apiClient.delete('/ordens-servico/$id');

      if (response.statusCode == 204) {
        return;
      } else {
        throw ApiException('Falha ao deletar ordem de serviço $id: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao deletar ordem de serviço $id: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao deletar ordem de serviço $id: ${e.toString()}');
    }
  }

  @override
  Future<String?> getNextOsNumber() async {
    try {
      // *** CORREÇÃO: Removido o parâmetro 'options' ***
      final response = await apiClient.get(
        '/ordens-servico/next-number',
        // options: Options(responseType: ResponseType.plain), // REMOVIDO
      );

      if (response.statusCode == 200) {
        // A API retorna texto simples, então tratamos a resposta como String
        // Se o seu ApiClient já faz parse JSON por padrão, pode precisar ajustar
        // ou garantir que a API retorne JSON como { "nextNumber": "#1" }
        if (response.data is String) {
          return response.data as String?;
        } else {
          // Se não for string, tenta converter para string
          if (kDebugMode) {
            print("WARN: getNextOsNumber recebeu tipo inesperado (${response.data.runtimeType}), tentando converter para String.");
          }
          return response.data?.toString();
        }
      } else {
        if (kDebugMode) {
          print("WARN: Falha ao obter próximo número da OS: Status ${response.statusCode}, Resposta: ${response.data}");
        }
        return null;
      }
    } on DioException catch (e, stackTrace) { // Adicionado stackTrace
      if (kDebugMode) {
        print('*******************************************');
        print('*** ERRO DioException em getNextOsNumber ***');
        print('Mensagem: ${e.message}');
        print('Erro Original: ${e.error}');
        print('Tipo do Erro: ${e.type}');
        print('Resposta da API (data): ${e.response?.data}');
        print('Stack Trace:');
        print(stackTrace);
        print('*******************************************');
      }
      return null;
    } catch (e, stackTrace) { // Adicionado stackTrace
      if (kDebugMode) {
        print('*******************************************');
        print('*** ERRO Geral em getNextOsNumber ***');
        print('Erro: ${e.toString()}');
        print('Tipo do Erro: ${e.runtimeType}');
        print('Stack Trace:');
        print(stackTrace);
        print('*******************************************');
      }
      return null;
    }
  }
}

// Adicione/verifique o método fromEntity no OrdemServicoModel se necessário
// Exemplo:
/*
  factory OrdemServicoModel.fromEntity(OrdemServico entity) {
    return OrdemServicoModel(
      id: entity.id,
      numeroOS: entity.numeroOS,
      status: entity.status,
      dataAbertura: entity.dataAbertura,
      dataAgendamento: entity.dataAgendamento,
      dataFechamento: entity.dataFechamento,
      dataHoraEmissao: entity.dataHoraEmissao,
      clienteId: entity.clienteId,
      equipamentoId: entity.equipamentoId,
      tecnicoAtribuidoId: entity.tecnicoAtribuidoId,
      problemaRelatado: entity.problemaRelatado,
      analiseFalha: entity.analiseFalha,
      solucaoAplicada: entity.solucaoAplicada,
      prioridade: entity.prioridade,
      // Não incluir campos que são apenas do DTO de resposta (nomeCliente, etc.)
    );
  }
*/

