// lib/features/ordem_servico/presentation/providers/os_list_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nordeste_servicos_app/domain/entities/ordem_servico.dart';

import 'package:nordeste_servicos_app/domain/repositories/os_repository.dart';

import '../../../shared/providers/repository_providers.dart';

// Definição do estado da lista de Ordens de Serviço

class OsListState {
  final List<OrdemServico> ordensServico;

  final bool isLoading;

  final String? errorMessage;

  final String
      searchTerm; // Adicionado para armazenar o termo de pesquisa atual

  OsListState({
    required this.ordensServico,
    this.isLoading = false,
    this.errorMessage,
    this.searchTerm = '', // Valor padrão vazio
  });

  factory OsListState.initial() => OsListState(ordensServico: []);

  OsListState copyWith({
    List<OrdemServico>? ordensServico,
    bool? isLoading,
    String? errorMessage,
    String? searchTerm,
  }) {
    return OsListState(
      ordensServico: ordensServico ?? this.ordensServico,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }
}

// O Notifier que gerencia o estado da lista de OS

class OsListNotifier extends StateNotifier<OsListState> {
  final OsRepository _osRepository;

  OsListNotifier(this._osRepository) : super(OsListState.initial()) {
    loadOrdensServico(refresh: true);
  }

  Future<void> loadOrdensServico({
    bool refresh = false,
    String? searchTerm,
  }) async {
    if (state.isLoading && !refresh) {
      return;
    }

// Atualiza o termo de pesquisa no estado se fornecido

    final currentSearchTerm = searchTerm ?? state.searchTerm;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      searchTerm: currentSearchTerm,
    );

    try {
      final ordens = await _osRepository.getOrdensServico(
        searchTerm: currentSearchTerm.isNotEmpty ? currentSearchTerm : null,
      );

      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          ordensServico: ordens,
          searchTerm: currentSearchTerm,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao carregar Ordens de Serviço: ${e.toString()}',
          searchTerm: currentSearchTerm,
        );
      }
    }
  }

// Método específico para pesquisa

  Future<void> searchOrdensServico(String searchTerm) async {
    await loadOrdensServico(refresh: true, searchTerm: searchTerm);
  }

// Método para limpar a pesquisa

  Future<void> clearSearch() async {
    await loadOrdensServico(refresh: true, searchTerm: '');
  }

// Método para atualizar apenas o termo de pesquisa sem fazer a busca

  void updateSearchTerm(String searchTerm) {
    state = state.copyWith(searchTerm: searchTerm);
  }
}

// O provedor

final osListProvider =
    StateNotifierProvider.autoDispose<OsListNotifier, OsListState>((ref) {
  final osRepository = ref.read(osRepositoryProvider);

  return OsListNotifier(osRepository);
});
