// lib/features/ordem_servico/presentation/providers/os_list_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordeste_servicos_app/domain/entities/ordem_servico.dart';
import 'package:nordeste_servicos_app/domain/repositories/os_repository.dart'; // Adapte o caminho do seu repositório
import 'package:nordeste_servicos_app/data/models/status_os_model.dart';

import '../../../shared/providers/repository_providers.dart'; // Se for usar para filtros

// Definição do estado da lista de Ordens de Serviço
class OsListState {
  final List<OrdemServico> ordensServico;
  final bool isLoading;
  final String? errorMessage;
  // Você pode adicionar estados para filtros aqui, se houver

  OsListState({
    required this.ordensServico,
    this.isLoading = false,
    this.errorMessage,
  });

  factory OsListState.initial() => OsListState(ordensServico: []);

  OsListState copyWith({
    List<OrdemServico>? ordensServico,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OsListState(
      ordensServico: ordensServico ?? this.ordensServico,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // errorMessage null pode ser passado para limpar
    );
  }
}

// O Notifier que gerencia o estado da lista de OS
class OsListNotifier extends StateNotifier<OsListState> {
  final OsRepository _osRepository; // Injetar o repositório

  // CONSTRUTOR: ESSA É A PARTE CHAVE!
  // Ele é executado quando o provedor é criado ou RE-CRIADO (após invalidação)
  OsListNotifier(this._osRepository) : super(OsListState.initial()) {
    // Inicia o carregamento dos dados automaticamente
    // 'refresh: true' garante que sempre tentará buscar dados novos na inicialização
    loadOrdensServico(refresh: true);
  }

  Future<void> loadOrdensServico({
    bool refresh = false,
    String? searchTerm,
    // Adicione parâmetros de filtro aqui (ex: Long? tecnicoId, StatusOS? status)
  }) async {
    // Evita recargas desnecessárias se já estiver carregando e não for refresh forçado
    if (!refresh && state.isLoading) {
      return;
    }

    // Se já houver dados e não for um refresh forçado, podemos evitar recarregar
    // if (!refresh && state.ordensServico.isNotEmpty) {
    //   return;
    // }

    state = state.copyWith(isLoading: true, errorMessage: null); // Limpa erro anterior
    try {
      // Chama o método do repositório para obter as ordens de serviço
      final ordens = await _osRepository.getOrdensServico(
        // Passe os parâmetros de filtro aqui, se você os tiver
        // searchTerm: searchTerm,
      );
      state = state.copyWith(isLoading: false, ordensServico: ordens);
    } catch (e, stackTrace) {
      // Em caso de erro, atualiza o estado com a mensagem de erro
      print('Erro ao carregar Ordens de Serviço no Notifier: $e');
      print('Stack Trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar Ordens de Serviço: ${e.toString()}',
      );
    }
  }

// Exemplo de como você poderia ter um método para aplicar filtros
// void applyFilters({String? newSearchTerm, StatusOS? newStatus}) {
//   loadOrdensServico(searchTerm: newSearchTerm, status: newStatus, refresh: true);
// }
}

// O provedor real para a lista de Ordens de Serviço
// Certifique-se de que osRepositoryProvider esteja definido em algum lugar
// Ex: final osRepositoryProvider = Provider<OsRepository>((ref) => OsRepositoryImpl());
final osListProvider = StateNotifierProvider<OsListNotifier, OsListState>((ref) {
  // O Riverpod se encarrega de fornecer a dependência do repositório
  final osRepository = ref.read(osRepositoryProvider);
  return OsListNotifier(osRepository);
});