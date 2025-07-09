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

  const MinhasOsListState({
    this.ordensServico = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  MinhasOsListState copyWith({
    List<OrdemServico>? ordensServico,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MinhasOsListState(
      ordensServico: ordensServico ?? this.ordensServico,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [ordensServico, isLoading, errorMessage];
}

// 2. O Notifier que gerencia o estado
class MinhasOsListNotifier extends StateNotifier<MinhasOsListState> {
  final OsRepository _osRepository;
  final int? _tecnicoId; // ID do técnico logado

  MinhasOsListNotifier(this._osRepository, this._tecnicoId) : super(const MinhasOsListState()) {
    // Carrega as OS do técnico ao iniciar, se o ID estiver disponível
    if (_tecnicoId != null) {
      loadMinhasOrdensServico();
    } else {
      // Define um estado de erro se não for possível identificar o técnico
      state = state.copyWith(isLoading: false, errorMessage: "Não foi possível identificar o técnico logado.");
    }
  }

  Future<void> loadMinhasOrdensServico({String? searchTerm, bool refresh = false}) async {
    if (state.isLoading && !refresh) return;
    if (_tecnicoId == null) return; // Não faz nada se não houver ID

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Chama o repositório passando o ID do técnico para filtrar no backend
      final ordens = await _osRepository.getOrdensServico(tecnicoId: _tecnicoId!);

      List<OrdemServico> ordensFiltradas = ordens;
      if (searchTerm != null && searchTerm.isNotEmpty) {
        ordensFiltradas = ordens.where((os) =>
        os.numeroOS.toLowerCase().contains(searchTerm.toLowerCase()) ||
            os.cliente.nomeCompleto.toLowerCase().contains(searchTerm.toLowerCase())
        ).toList();
      }

      state = state.copyWith(ordensServico: ordensFiltradas, isLoading: false);

    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado: ${e.toString()}', isLoading: false);
    }
  }
}

// 3. O Provider que a UI irá consumir
final minhasOsListProvider = StateNotifierProvider.autoDispose<MinhasOsListNotifier, MinhasOsListState>((ref) {
  final osRepository = ref.watch(osRepositoryProvider);
  // Pega o ID do usuário logado diretamente do authProvider
  final tecnicoId = ref.watch(authProvider).authenticatedUser?.id;
  return MinhasOsListNotifier(osRepository, tecnicoId);
});
