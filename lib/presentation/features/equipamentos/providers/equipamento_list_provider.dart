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
  final String searchTerm;

  const EquipamentoListState({
    this.equipamentos = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchTerm = '',
  });

  EquipamentoListState copyWith({
    List<Equipamento>? equipamentos,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? searchTerm,
  }) {
    return EquipamentoListState(
      equipamentos: equipamentos ?? this.equipamentos,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }

  @override
  List<Object?> get props => [equipamentos, isLoading, errorMessage, searchTerm];

  List<Equipamento> get filteredEquipamentos {
    if (searchTerm.isEmpty) return equipamentos;
    final lower = searchTerm.toLowerCase();
    return equipamentos.where((e) =>
      (e.marcaModelo.toLowerCase().contains(lower)) ||
      (e.numeroSerieChassi.toLowerCase().contains(lower)) ||
      (e.tipo.toLowerCase().contains(lower))
    ).toList();
  }
}

// 2. O Notifier que gerencia o estado
class EquipamentoListNotifier extends StateNotifier<EquipamentoListState> {
  final EquipamentoRepository _equipamentoRepository;

  EquipamentoListNotifier(this._equipamentoRepository) : super(const EquipamentoListState()) {
    loadEquipamentos();
  }

  Future<void> loadEquipamentos({String? searchTerm, bool refresh = false}) async {
    if (state.isLoading && !refresh) return;
    state = state.copyWith(isLoading: true, clearError: true, searchTerm: searchTerm ?? state.searchTerm);
    try {
      final equipamentos = await _equipamentoRepository.getEquipamentos();
      state = state.copyWith(equipamentos: equipamentos, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  void updateSearchTerm(String searchTerm) {
    state = state.copyWith(searchTerm: searchTerm);
  }
}

// 3. O Provider que expõe o Notifier para a UI
final equipamentoListProvider = StateNotifierProvider<EquipamentoListNotifier, EquipamentoListState>((ref) {
  final equipamentoRepository = ref.watch(equipamentoRepositoryProvider);
  return EquipamentoListNotifier(equipamentoRepository);
});