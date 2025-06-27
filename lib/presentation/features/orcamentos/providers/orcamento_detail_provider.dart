import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/item_orcamento.dart';
import '../../../../domain/entities/orcamento.dart';
import '../../../shared/providers/repository_providers.dart';

// Provider para buscar os dados de um único orçamento pelo ID
final orcamentoDetailProvider = FutureProvider.family<Orcamento, int>((ref, orcamentoId) async {
  final repository = ref.watch(orcamentoRepositoryProvider);
  return repository.getOrcamentoById(orcamentoId);
});

// Provider para buscar a lista de itens de um orçamento específico
final itemOrcamentoListProvider = FutureProvider.family<List<ItemOrcamento>, int>((ref, orcamentoId) async {
  final repository = ref.watch(itemOrcamentoRepositoryProvider);
  return repository.getItemOrcamentosByOrcamentoId(orcamentoId);
});