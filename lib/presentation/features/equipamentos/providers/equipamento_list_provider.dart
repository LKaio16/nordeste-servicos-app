import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/entities/equipamento.dart';
import '../../../../domain/repositories/equipamento_repository.dart';
import '../../../shared/providers/repository_providers.dart';

// 1. O Estado da tela
class EquipamentoListState extends Equatable {
  final List<Equipamento> equipamentos;
  final bool isLoading;
  final String? errorMessage;

  const EquipamentoListState({
    this.equipamentos = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  EquipamentoListState copyWith({
    List<Equipamento>? equipamentos,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EquipamentoListState(
      equipamentos: equipamentos ?? this.equipamentos,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [equipamentos, isLoading, errorMessage];
}

// 2. O Notifier que gerencia o estado
class EquipamentoListNotifier extends StateNotifier<EquipamentoListState> {
  final EquipamentoRepository _equipamentoRepository;

  EquipamentoListNotifier(this._equipamentoRepository) : super(const EquipamentoListState()) {
    loadEquipamentos();
  }

  Future<void> loadEquipamentos({String? searchTerm, bool refresh = false}) async {
    if (state.isLoading && !refresh) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // O método getEquipamentos já existe no seu repositório
      final equipamentos = await _equipamentoRepository.getEquipamentos(/* Você pode adicionar filtros aqui no futuro */);
      state = state.copyWith(equipamentos: equipamentos, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }
}

// 3. O Provider que expõe o Notifier para a UI
final equipamentoListProvider = StateNotifierProvider<EquipamentoListNotifier, EquipamentoListState>((ref) {
  final equipamentoRepository = ref.watch(equipamentoRepositoryProvider);
  return EquipamentoListNotifier(equipamentoRepository);
});