// lib/domain/repositories/fornecedor_repository.dart

import '../entities/fornecedor.dart';

abstract class FornecedorRepository {
  Future<List<Fornecedor>> getFornecedores({String? searchTerm, String? status});
  Future<Fornecedor> getFornecedorById(int id);
  Future<Fornecedor> createFornecedor(Fornecedor fornecedor);
  Future<void> deleteFornecedor(int id);
}
