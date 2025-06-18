import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/entities/cliente.dart';
import '../../../../domain/repositories/cliente_repository.dart';
import '../../../shared/providers/repository_providers.dart';


class ClienteListState extends Equatable {
  final List<Cliente> clientes;
  final bool isLoading;
  final String? errorMessage;

  const ClienteListState({
    this.clientes = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ClienteListState copyWith({
    List<Cliente>? clientes,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ClienteListState(
      clientes: clientes ?? this.clientes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [clientes, isLoading, errorMessage];
}


class ClienteListNotifier extends StateNotifier<ClienteListState> {
  final ClienteRepository _clienteRepository;

  ClienteListNotifier(this._clienteRepository) : super(const ClienteListState()) {
    loadClientes(); // Carrega os clientes ao iniciar
  }

  Future<void> loadClientes({String? searchTerm, bool refresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Aqui você pode adaptar o getClientes para aceitar um termo de busca se o repositório suportar
      final clientes = await _clienteRepository.getClientes(/* searchTerm: searchTerm */);
      state = state.copyWith(clientes: clientes, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }
}


final clienteListProvider = StateNotifierProvider<ClienteListNotifier, ClienteListState>((ref) {
  final clienteRepository = ref.watch(clienteRepositoryProvider);
  return ClienteListNotifier(clienteRepository);
});