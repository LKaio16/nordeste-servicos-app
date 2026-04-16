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
  Future<Map<String, dynamic>> getContasListagem({
    int? clienteId,
    int? fornecedorId,
    String? tipo,
    String? status,
    int page = 0,
    int size = 20,
  });
  Future<void> deleteConta(int id);
  Future<Conta> marcarComoPaga(int id, {DateTime? dataPagamento, String? formaPagamento});
}
