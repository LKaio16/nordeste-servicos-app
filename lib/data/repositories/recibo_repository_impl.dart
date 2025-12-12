// lib/data/repositories/recibo_repository_impl.dart

import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';
import '../models/recibo_model.dart';
import '../../domain/entities/recibo.dart';
import '../../domain/repositories/recibo_repository.dart';

class ReciboRepositoryImpl implements ReciboRepository {
  final ApiClient apiClient;

  ReciboRepositoryImpl(this.apiClient);

  @override
  Future<List<Recibo>> getRecibos() async {
    try {
      final response = await apiClient.get('/recibos');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        final List<ReciboModel> reciboModels = jsonList.map((json) => ReciboModel.fromJson(json)).toList();
        final List<Recibo> recibos = reciboModels.map((model) => model.toEntity()).toList();
        return recibos;
      } else {
        throw ApiException('Falha ao carregar recibos: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar recibos: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar recibos: ${e.toString()}');
    }
  }

  @override
  Future<Recibo> getReciboById(int id) async {
    try {
      final response = await apiClient.get('/recibos/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        final ReciboModel reciboModel = ReciboModel.fromJson(json);
        return reciboModel.toEntity();
      } else {
        throw ApiException('Falha ao carregar recibo ${id}: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao carregar recibo ${id}: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao carregar recibo ${id}: ${e.toString()}');
    }
  }

  @override
  Future<Recibo> createRecibo(Recibo recibo) async {
    try {
      final Map<String, dynamic> data = {
        'valor': recibo.valor,
        'cliente': recibo.cliente,
        'referenteA': recibo.referenteA,
      };

      final response = await apiClient.post('/recibos', data: data);

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = response.data;
        final ReciboModel reciboModel = ReciboModel.fromJson(json);
        return reciboModel.toEntity();
      } else {
        throw ApiException('Falha ao criar recibo: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao criar recibo: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao criar recibo: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteRecibo(int id) async {
    try {
      final response = await apiClient.delete('/recibos/$id');

      if (response.statusCode != 204) {
        throw ApiException('Falha ao deletar recibo: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao deletar recibo: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao deletar recibo: ${e.toString()}');
    }
  }

  @override
  Future<Uint8List> generateReciboPdf(Recibo recibo) async {
    try {
      final Map<String, dynamic> data = {
        'valor': recibo.valor,
        'cliente': recibo.cliente,
        'referenteA': recibo.referenteA,
      };

      final response = await apiClient.post(
        '/recibos/pdf',
        data: data,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        return response.data as Uint8List;
      } else {
        throw ApiException('Falha ao gerar PDF do recibo: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao gerar PDF: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao gerar PDF: ${e.toString()}');
    }
  }

  @override
  Future<Uint8List> downloadReciboPdf(int id) async {
    try {
      final response = await apiClient.get(
        '/recibos/$id/pdf',
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        return response.data as Uint8List;
      } else {
        throw ApiException('Falha ao baixar PDF do recibo: Status ${response.statusCode}');
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException('Erro de rede ao baixar PDF: ${e.message}');
    } catch (e) {
      throw ApiException('Erro inesperado ao baixar PDF: ${e.toString()}');
    }
  }
}

