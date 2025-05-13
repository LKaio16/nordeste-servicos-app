// lib/core/network/api_client.dart

import 'package:dio/dio.dart';


import '../../config/app_config.dart';
import '../error/exceptions.dart'; // Precisaremos desta exceção

class ApiClient {
  // Instância única do Dio
  late Dio _dio;

  // Construtor
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl, // Usa a URL base do seu arquivo de configuração
        connectTimeout: const Duration(seconds: AppConfig.apiTimeoutSeconds), // Tempo limite de conexão
        receiveTimeout: const Duration(seconds: AppConfig.apiTimeoutSeconds), // Tempo limite para receber a resposta
        headers: {
          'Content-Type': 'application/json', // Tipo de conteúdo padrão
          'Accept': 'application/json',       // Aceita JSON na resposta
          // TODO: Adicionar headers de autenticação aqui quando implementar login (ex: 'Authorization': 'Bearer token')
        },
      ),
    );

    // Opcional: Adicionar Interceptors para logging, autenticação, etc.
    _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true)); // Para ver logs das requisições/respostas
  }

  // Método genérico para requisição GET
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      // TODO: Implementar tratamento de erros mais detalhado aqui (status codes 401, 403, 404, 500, etc.)
      throw _handleError(e); // Lança uma exceção customizada
    } catch (e) {
       // Lida com outros tipos de erros
      throw ApiException("Ocorreu um erro inesperado: ${e.toString()}");
    }
  }

  // Método genérico para requisição POST
  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException("Ocorreu um erro inesperado: ${e.toString()}");
    }
  }

  // Método genérico para requisição PUT
  Future<Response> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException("Ocorreu um erro inesperado: ${e.toString()}");
    }
  }

  // Método genérico para requisição DELETE
  Future<Response> delete(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException("Ocorreu um erro inesperado: ${e.toString()}");
    }
  }

  // Método para tratar erros específicos do Dio
  ApiException _handleError(DioException error) {
    String message;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = "Tempo limite excedido ao conectar com o servidor.";
        break;
      case DioExceptionType.badResponse:
         // O servidor respondeu com um status code != 2xx
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data; // Pode conter detalhes do erro da API
        message = "Erro na resposta do servidor: Status $statusCode";
        // TODO: Parsear responseData para obter mensagens de erro mais detalhadas da API Java (BusinessException, etc.)
        if (responseData is Map && responseData.containsKey('message')) {
             message += " - ${responseData['message']}"; // Exemplo se a API retornar { "message": "..." }
        }
        // Você pode criar exceções específicas para 401 (Unauthorized), 403 (Forbidden), 404 (Not Found) etc.
        if (statusCode == 404) {
             throw NotFoundException("Recurso não encontrado.");
        }
        // Outros casos...
        break;
      case DioExceptionType.cancel:
        message = "Requisição cancelada.";
        break;
      case DioExceptionType.connectionError:
        message = "Falha na conexão com o servidor. Verifique sua internet ou a URL da API.";
        break;
       case DioExceptionType.badCertificate:
         message = "Erro de certificado SSL.";
         break;
       case DioExceptionType.unknown:
        message = "Ocorreu um erro inesperado: ${error.message}";
        break;
    }
    return ApiException(message); // Lança uma exceção de API customizada
  }
}

// Precisamos de classes de exceção customizadas
// Crie um novo arquivo: lib/core/error/exceptions.dart