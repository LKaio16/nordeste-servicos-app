// lib/domain/repositories/conta_repository.dart

import '../entities/conta.dart';

abstract class ContaRepository {
  Future<List<Conta>> getContas({
    int? clienteId,
    int? fornecedorId,
    String? tipo,
    String? status,
  });
  Future<Conta> getContaById(int id);
  Future<Conta> createConta(Conta conta);
  Future<void> deleteConta(int id);
  Future<Conta> marcarComoPaga(int id, {DateTime? dataPagamento, String? formaPagamento});
}
