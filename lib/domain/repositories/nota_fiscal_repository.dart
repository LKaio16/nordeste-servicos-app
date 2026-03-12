// lib/domain/repositories/nota_fiscal_repository.dart

import '../entities/nota_fiscal.dart';

abstract class NotaFiscalRepository {
  Future<List<NotaFiscal>> getNotasFiscais({
    int? fornecedorId,
    int? clienteId,
    String? tipo,
  });
  Future<NotaFiscal> getNotaFiscalById(int id);
  Future<NotaFiscal> createNotaFiscal(NotaFiscal notaFiscal);
  Future<void> deleteNotaFiscal(int id);
}
