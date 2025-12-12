// lib/features/ordem_servico/presentation/providers/os_list_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nordeste_servicos_app/domain/entities/ordem_servico.dart';
import 'package:nordeste_servicos_app/domain/repositories/os_repository.dart';
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';

import '../../../shared/providers/repository_providers.dart';

// Definição do estado da lista de Ordens de Serviço

class OsListState {
  final List<OrdemServico> ordensServico;
  final bool isLoading;
  final bool isLoadingMore; // Para indicar carregamento de mais itens
  final String? errorMessage;
  final String searchTerm;
  final StatusOSModel? selectedStatus;
  final int currentPage;
  final bool hasMore; // Indica se há mais páginas para carregar
  final int pageSize;

  OsListState({
    required this.ordensServico,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.searchTerm = '',
    this.selectedStatus,
    this.currentPage = 0,
    this.hasMore = true,
    this.pageSize = 20,
  });

  factory OsListState.initial() => OsListState(ordensServico: []);

  OsListState copyWith({
    List<OrdemServico>? ordensServico,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    String? searchTerm,
    StatusOSModel? selectedStatus,
    int? currentPage,
    bool? hasMore,
    bool clearStatus = false,
    bool append = false, // Se true, adiciona à lista existente
  }) {
    return OsListState(
      ordensServico: append && ordensServico != null
          ? [...this.ordensServico, ...ordensServico]
          : (ordensServico ?? this.ordensServico),
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      searchTerm: searchTerm ?? this.searchTerm,
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      pageSize: this.pageSize,
    );
  }
}

// O Notifier que gerencia o estado da lista de OS

class OsListNotifier extends StateNotifier<OsListState> {
  final OsRepository _osRepository;
  Timer? _debounceTimer; // Timer para debounce da busca

  OsListNotifier(this._osRepository) : super(OsListState.initial()) {
    loadOrdensServico(refresh: true);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> loadOrdensServico({
    bool refresh = false,
    String? searchTerm,
    StatusOSModel? statusFilter,
    bool clearStatus = false,
    bool loadMore = false, // Novo parâmetro para carregar mais
  }) async {
    if (state.isLoading && !refresh && !loadMore) {
      return;
    }
    if (loadMore && (state.isLoadingMore || !state.hasMore)) {
      return;
    }

    final currentSearchTerm = searchTerm ?? state.searchTerm;
    final currentStatusFilter = clearStatus ? null : (statusFilter ?? state.selectedStatus);
    final page = loadMore ? state.currentPage + 1 : 0;

    if (loadMore) {
      state = state.copyWith(isLoadingMore: true);
    } else {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        searchTerm: currentSearchTerm,
        selectedStatus: currentStatusFilter,
        clearStatus: clearStatus,
        currentPage: 0,
        hasMore: true,
      );
    }

    try {
      final ordens = await _osRepository.getOrdensServico(
        searchTerm: currentSearchTerm.isNotEmpty ? currentSearchTerm : null,
        status: currentStatusFilter,
        page: page,
        size: state.pageSize,
      );

      // Aplica filtro por status se necessário (caso o backend não faça)
      List<OrdemServico> filteredOrdens = ordens;
      if (currentStatusFilter != null && ordens.any((os) => os.status != currentStatusFilter)) {
        filteredOrdens = ordens.where((os) => os.status == currentStatusFilter).toList();
      }

      final hasMore = filteredOrdens.length == state.pageSize;

      if (mounted) {
        if (loadMore) {
          // Adiciona os novos itens à lista existente
          state = state.copyWith(
            isLoadingMore: false,
            ordensServico: filteredOrdens,
            currentPage: page,
            hasMore: hasMore,
            append: true, // Indica que deve adicionar à lista existente
          );
        } else {
          // Substitui a lista completa
          state = state.copyWith(
            isLoading: false,
            ordensServico: filteredOrdens,
            searchTerm: currentSearchTerm,
            selectedStatus: currentStatusFilter,
            clearStatus: clearStatus,
            currentPage: page,
            hasMore: hasMore,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: 'Erro ao carregar Ordens de Serviço: ${e.toString()}',
          searchTerm: currentSearchTerm,
          selectedStatus: currentStatusFilter,
          clearStatus: clearStatus,
        );
      }
    }
  }

  // Método para carregar mais itens (infinite scroll)
  Future<void> loadMoreOrdensServico() async {
    await loadOrdensServico(loadMore: true);
  }

// Método específico para pesquisa

  Future<void> searchOrdensServico(String searchTerm) async {
    // Cancela o timer de debounce se existir
    _debounceTimer?.cancel();
    
    await loadOrdensServico(refresh: true, searchTerm: searchTerm);
  }

  Future<void> refreshOrdensServico() async {
    await loadOrdensServico(refresh: true, searchTerm: state.searchTerm);
  }

// Método para limpar a pesquisa

  Future<void> clearSearch() async {
    await loadOrdensServico(refresh: true, searchTerm: '', statusFilter: null, clearStatus: true);
  }

// Método para limpar todos os filtros

  Future<void> clearAllFilters() async {
    await loadOrdensServico(refresh: true, searchTerm: '', statusFilter: null, clearStatus: true);
  }

// Método para aplicar filtro por status

  Future<void> filterByStatus(StatusOSModel? status) async {
    await loadOrdensServico(refresh: true, searchTerm: state.searchTerm, statusFilter: status, clearStatus: status == null);
  }

// Método para atualizar apenas o termo de pesquisa sem fazer a busca

  void updateSearchTerm(String searchTerm) {
    state = state.copyWith(searchTerm: searchTerm);
    
    // Cancela o timer anterior se existir
    _debounceTimer?.cancel();
    
    // Cria um novo timer para fazer a busca após 500ms de inatividade
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      loadOrdensServico();
    });
  }
}

// O provedor

final osListProvider =
    StateNotifierProvider.autoDispose<OsListNotifier, OsListState>((ref) {
  final osRepository = ref.read(osRepositoryProvider);

  return OsListNotifier(osRepository);
});
