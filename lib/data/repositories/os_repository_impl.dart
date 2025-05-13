// lib/data/repositories/os_repository_impl.dart

import 'package:dio/dio.dart';
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
         throw ApiException('Falha ao carregar ordem de serviço ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao carregar ordem de serviço ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao carregar ordem de serviço ${id}: ${e.toString()}');
    }
  }

  @override
  Future<OrdemServico> createOrdemServico(OrdemServico os) async {
      try {
        // Converte a entidade para um modelo ou DTO de criação
         final OrdemServicoModel osModel = OrdemServicoModel(
            // ID não é enviado
            numeroOS: os.numeroOS, // Pode ser gerado pela API
            status: os.status,
            dataAbertura: os.dataAbertura,
            dataAgendamento: os.dataAgendamento,
            dataFechamento: os.dataFechamento,
            dataHoraEmissao: os.dataHoraEmissao, // Pode ser gerado pela API
            clienteId: os.clienteId,
            equipamentoId: os.equipamentoId,
            tecnicoAtribuidoId: os.tecnicoAtribuidoId,
            problemaRelatado: os.problemaRelatado,
            analiseFalha: os.analiseFalha,
            solucaoAplicada: os.solucaoAplicada,
            prioridade: os.prioridade,
            // Detalhes (listas) não são enviados no POST da OS principal
         );

      final response = await apiClient.post('/ordens-servico', data: osModel.toJson());

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = response.data;
        final OrdemServicoModel createdOsModel = OrdemServicoModel.fromJson(json);
        return createdOsModel.toEntity();
      } else {
         throw ApiException('Falha ao criar ordem de serviço: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao criar ordem de serviço: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao criar ordem de serviço: ${e.toString()}');
    }
  }

  @override
  Future<OrdemServico> updateOrdemServico(OrdemServico os) async {
       try {
         final OrdemServicoModel osModel = OrdemServicoModel(
            id: os.id, // Incluir ID
            numeroOS: os.numeroOS,
            status: os.status,
            dataAbertura: os.dataAbertura,
            dataAgendamento: os.dataAgendamento,
            dataFechamento: os.dataFechamento,
            dataHoraEmissao: os.dataHoraEmissao,
            clienteId: os.clienteId,
            equipamentoId: os.equipamentoId,
            tecnicoAtribuidoId: os.tecnicoAtribuidoId,
            problemaRelatado: os.problemaRelatado,
            analiseFalha: os.analiseFalha,
            solucaoAplicada: os.solucaoAplicada,
            prioridade: os.prioridade,
            // Detalhes (listas) não são enviados no PUT da OS principal
         );

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
         throw ApiException('Falha ao deletar ordem de serviço ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
       rethrow;
    } on DioException catch (e) {
        throw ApiException('Erro de rede ao deletar ordem de serviço ${id}: ${e.message}');
    } catch (e) {
       throw ApiException('Erro inesperado ao deletar ordem de serviço ${id}: ${e.toString()}');
    }
  }

   // Adicione um método toEntity() no seu OrdemServicoModel se ainda não o fez.
     /*
    OrdemServico toEntity() {
      return OrdemServico(
         id: id,
         numeroOS: numeroOS,
         status: status, // Já é o enum model
         dataAbertura: dataAbertura,
         dataAgendamento: dataAgendamento,
         dataFechamento: dataFechamento,
         dataHoraEmissao: dataHoraEmissao,
         clienteId: clienteId,
         nomeCliente: nomeCliente,
         equipamentoId: equipamentoId,
         descricaoEquipamento: descricaoEquipamento,
         tecnicoAtribuidoId: tecnicoAtribuidoId,
         nomeTecnicoAtribuido: nomeTecnicoAtribuido,
         problemaRelatado: problemaRelatado,
         analiseFalha: analiseFalha,
         solucaoAplicada: solucaoAplicada,
         prioridade: prioridade, // Já é o enum model
      );
    }
    */
}