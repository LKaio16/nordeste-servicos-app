import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../domain/entities/ordem_servico.dart';
import '../../../../domain/repositories/os_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/providers/repository_providers.dart';

// 1. O Estado da tela
class MinhasOsListState extends Equatable {
  final List<OrdemServico> ordensServico;
  final bool isLoading;
  final String? errorMessage;
  final String searchTerm; // Adicionado

  const MinhasOsListState({
    this.ordensServico = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchTerm = '', // Adicionado
  });

  MinhasOsListState copyWith({
    List<OrdemServico>? ordensServico,
    bool? isLoading,
    String? errorMessage,
    String? searchTerm, // Adicionado
    bool clearError = false,
  }) {
    return MinhasOsListState(
      ordensServico: ordensServico ?? this.ordensServico,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      searchTerm: searchTerm ?? this.searchTerm, // Adicionado
    );
  }

  @override
  List<Object?> get props => [ordensServico, isLoading, errorMessage, searchTerm];
}

// 2. O Notifier que gerencia o estado
class MinhasOsListNotifier extends StateNotifier<MinhasOsListState> {
  final OsRepository _osRepository;
  final int? _tecnicoId; // ID do técnico logado
  Timer? _debounceTimer; // Timer para debounce da busca

  MinhasOsListNotifier(this._osRepository, this._tecnicoId) : super(const MinhasOsListState()) {
    // Carrega as OS do técnico ao iniciar, se o ID estiver disponível
    if (_tecnicoId != null) {
      loadMinhasOrdensServico();
    } else {
      // Define um estado de erro se não for possível identificar o técnico
      state = state.copyWith(isLoading: false, errorMessage: "Não foi possível identificar o técnico logado.");
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> loadMinhasOrdensServico({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;
    if (_tecnicoId == null) return; // Não faz nada se não houver ID

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Passa o ID do técnico e o termo de busca para o repositório
      final ordens = await _osRepository.getOrdensServico(
        tecnicoId: _tecnicoId,
        searchTerm: state.searchTerm,
      );
      state = state.copyWith(ordensServico: ordens, isLoading: false);

    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado: ${e.toString()}', isLoading: false);
    }
  }

  void updateSearchTerm(String searchTerm) {
    state = state.copyWith(searchTerm: searchTerm);
    
    // Cancela o timer anterior se existir
    _debounceTimer?.cancel();
    
    // Cria um novo timer para fazer a busca após 500ms de inatividade
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      loadMinhasOrdensServico();
    });
  }

  Future<void> searchOrdensServico(String searchTerm) async {
    // Cancela o timer de debounce se existir
    _debounceTimer?.cancel();
    
    state = state.copyWith(searchTerm: searchTerm);
    await loadMinhasOrdensServico();
  }

  Future<void> clearSearch() async {
    state = state.copyWith(searchTerm: '');
    await loadMinhasOrdensServico();
  }

  Future<void> refreshOrdensServico() async {
    await loadMinhasOrdensServico(refresh: true);
  }
}

// 3. O Provider que a UI irá consumir
final minhasOsListProvider = StateNotifierProvider.autoDispose<MinhasOsListNotifier, MinhasOsListState>((ref) {
  final osRepository = ref.watch(osRepositoryProvider);
  // Pega o ID do usuário logado diretamente do authProvider
  final tecnicoId = ref.watch(authProvider).authenticatedUser?.id;
  return MinhasOsListNotifier(osRepository, tecnicoId);
});
