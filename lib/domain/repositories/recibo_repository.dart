// lib/domain/repositories/recibo_repository.dart

import 'dart:typed_data';
import '../entities/recibo.dart';

abstract class ReciboRepository {
  /// Obtém a lista de recibos.
  Future<List<Recibo>> getRecibos();

  /// Obtém um recibo pelo seu ID.
  Future<Recibo> getReciboById(int id);

  /// Cria um novo recibo.
  Future<Recibo> createRecibo(Recibo recibo);

  /// Deleta um recibo pelo seu ID.
  Future<void> deleteRecibo(int id);

  /// Gera o PDF de um recibo.
  Future<Uint8List> generateReciboPdf(Recibo recibo);

  /// Baixa o PDF de um recibo existente.
  Future<Uint8List> downloadReciboPdf(int id);
}


