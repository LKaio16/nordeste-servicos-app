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
  final String? errorMessage;
  final String searchTerm; // Adicionado para armazenar o termo de pesquisa atual
  final StatusOSModel? selectedStatus; // Filtro por status

  OsListState({
    required this.ordensServico,
    this.isLoading = false,
    this.errorMessage,
    this.searchTerm = '', // Valor padrão vazio
    this.selectedStatus, // Valor padrão null (sem filtro)
  });

  factory OsListState.initial() => OsListState(ordensServico: []);

  OsListState copyWith({
    List<OrdemServico>? ordensServico,
    bool? isLoading,
    String? errorMessage,
    String? searchTerm,
    StatusOSModel? selectedStatus,
    bool clearStatus = false,
  }) {
    return OsListState(
      ordensServico: ordensServico ?? this.ordensServico,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchTerm: searchTerm ?? this.searchTerm,
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
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
  }) async {
    if (state.isLoading && !refresh) {
      return;
    }

    // Atualiza o termo de pesquisa e filtro de status no estado se fornecidos
    final currentSearchTerm = searchTerm ?? state.searchTerm;
    final currentStatusFilter = clearStatus ? null : (statusFilter ?? state.selectedStatus);

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      searchTerm: currentSearchTerm,
      selectedStatus: currentStatusFilter,
      clearStatus: clearStatus,
    );

    try {
      final ordens = await _osRepository.getOrdensServico(
        searchTerm: currentSearchTerm.isNotEmpty ? currentSearchTerm : null,
      );

      // Aplica filtro por status se necessário
      List<OrdemServico> filteredOrdens = ordens;
      if (currentStatusFilter != null) {
        filteredOrdens = ordens.where((os) => os.status == currentStatusFilter).toList();
      }

      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          ordensServico: filteredOrdens,
          searchTerm: currentSearchTerm,
          selectedStatus: currentStatusFilter,
          clearStatus: clearStatus,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao carregar Ordens de Serviço:  ${e.toString()}',
          searchTerm: currentSearchTerm,
          selectedStatus: currentStatusFilter,
          clearStatus: clearStatus,
        );
      }
    }
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
