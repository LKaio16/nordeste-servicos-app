import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:nordeste_servicos_app/data/models/tipo_cliente.dart';

import '../../../../domain/entities/cliente.dart';
import '../../../../domain/repositories/cliente_repository.dart';
import '../../../shared/providers/repository_providers.dart';


class ClienteListState extends Equatable {
  final List<Cliente> clientes;
  final bool isLoading;
  final String? errorMessage;
  final String searchTerm;
  final TipoCliente? tipoClienteFiltro;

  const ClienteListState({
    this.clientes = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchTerm = '',
    this.tipoClienteFiltro,
  });

  ClienteListState copyWith({
    List<Cliente>? clientes,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? searchTerm,
    TipoCliente? tipoClienteFiltro,
    bool clearTipoCliente = false,
  }) {
    return ClienteListState(
      clientes: clientes ?? this.clientes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      searchTerm: searchTerm ?? this.searchTerm,
      tipoClienteFiltro: clearTipoCliente ? null : tipoClienteFiltro ?? this.tipoClienteFiltro,
    );
  }

  @override
  List<Object?> get props => [clientes, isLoading, errorMessage, searchTerm, tipoClienteFiltro];
}


class ClienteListNotifier extends StateNotifier<ClienteListState> {
  final ClienteRepository _clienteRepository;

  ClienteListNotifier(this._clienteRepository) : super(const ClienteListState()) {
    loadClientes();
  }

  Future<void> loadClientes({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final clientes = await _clienteRepository.getClientes(
        searchTerm: state.searchTerm,
        tipoCliente: state.tipoClienteFiltro,
      );
      state = state.copyWith(clientes: clientes, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Falha ao carregar clientes: ${e.toString()}', isLoading: false);
    }
  }

  void search(String searchTerm) {
    state = state.copyWith(searchTerm: searchTerm);
    loadClientes();
  }

  void filterByTipo(TipoCliente? tipo) {
    // Se o filtro selecionado for o mesmo que já está ativo, remove o filtro.
    if (state.tipoClienteFiltro == tipo) {
      state = state.copyWith(clearTipoCliente: true);
    } else {
      state = state.copyWith(tipoClienteFiltro: tipo);
    }
    loadClientes();
  }

  void clearFilters() {
    state = state.copyWith(searchTerm: '', clearTipoCliente: true);
    loadClientes();
  }

  Future<void> refresh() async {
    await loadClientes(refresh: true);
  }
}


final clienteListProvider = StateNotifierProvider.autoDispose<ClienteListNotifier, ClienteListState>((ref) {
  final clienteRepository = ref.watch(clienteRepositoryProvider);
  return ClienteListNotifier(clienteRepository);
});