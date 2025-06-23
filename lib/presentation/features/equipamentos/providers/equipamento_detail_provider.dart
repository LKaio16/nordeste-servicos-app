import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordeste_servicos_app/domain/entities/equipamento.dart';
import 'package:nordeste_servicos_app/domain/repositories/equipamento_repository.dart';
import 'package:nordeste_servicos_app/presentation/shared/providers/repository_providers.dart';

// Este provider busca um equipamento específico pelo seu ID,
// usando o método getEquipamentoById que você já definiu.
final equipamentoDetailProvider = FutureProvider.family<Equipamento, int>((ref, equipamentoId) async {
  final repository = ref.watch(equipamentoRepositoryProvider);
  return repository.getEquipamentoById(equipamentoId);
});