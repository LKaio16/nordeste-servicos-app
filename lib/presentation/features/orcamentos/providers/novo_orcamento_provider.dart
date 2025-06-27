import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordeste_servicos_app/data/models/status_orcamento_model.dart';
import '../../../../domain/entities/cliente.dart';
import 'package:nordeste_servicos_app/domain/entities/ordem_servico.dart'; // Corrigido o import
import 'package:nordeste_servicos_app/domain/entities/orcamento.dart';
import 'package:nordeste_servicos_app/domain/repositories/cliente_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/os_repository.dart'; // Corrigido o import
import 'package:nordeste_servicos_app/domain/repositories/orcamento_repository.dart';
import 'package:nordeste_servicos_app/presentation/shared/providers/repository_providers.dart';

// 1. O ESTADO (agora dentro do mesmo arquivo)
class NovoOrcamentoState extends Equatable {
  // Estado do carregamento inicial (clientes)
  final bool isLoading;
  final String? errorMessage;
  final List<Cliente> clientes;

  // Estado do carregamento das Ordens de Serviço
  final bool isLoadingOs;
  final List<OrdemServico> ordensDeServico;

  // Estado do processo de submissão (salvar o orçamento)
  final bool isSubmitting;
  final String? submissionError;


  const NovoOrcamentoState({
    this.isLoading = false,
    this.errorMessage,
    this.clientes = const [],
    this.isLoadingOs = false,
    this.ordensDeServico = const [],
    this.isSubmitting = false,
    this.submissionError,
  });

  NovoOrcamentoState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Cliente>? clientes,
    bool? isLoadingOs,
    List<OrdemServico>? ordensDeServico,
    bool? isSubmitting,
    String? submissionError,
    bool clearErrors = false,
  }) {
    return NovoOrcamentoState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrors ? null : errorMessage ?? this.errorMessage,
      clientes: clientes ?? this.clientes,
      isLoadingOs: isLoadingOs ?? this.isLoadingOs,
      ordensDeServico: ordensDeServico ?? this.ordensDeServico,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: clearErrors ? null : submissionError ?? this.submissionError,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, clientes, isLoadingOs, ordensDeServico, isSubmitting, submissionError];
}


// 2. O NOTIFIER
class NovoOrcamentoNotifier extends StateNotifier<NovoOrcamentoState> {
  final OrcamentoRepository _orcamentoRepository;
  final ClienteRepository _clienteRepository;
  final OsRepository _osRepository;

  NovoOrcamentoNotifier(
      this._orcamentoRepository,
      this._clienteRepository,
      this._osRepository
      ) : super(const NovoOrcamentoState()) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, clearErrors: true);
    try {
      final clientes = await _clienteRepository.getClientes();
      state = state.copyWith(isLoading: false, clientes: clientes);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Falha ao carregar clientes.');
    }
  }

  // --- FUNÇÃO CORRIGIDA ---
  // Busca as Ordens de Serviço para um cliente específico
  Future<void> fetchOrdensDeServico(int clienteId) async {
    state = state.copyWith(isLoadingOs: true, ordensDeServico: []);
    try {
      final ordens = await _osRepository.getOrdensServico(clienteId: clienteId);
      state = state.copyWith(isLoadingOs: false, ordensDeServico: ordens);
    } catch (e) {
      state = state.copyWith(isLoadingOs: false, errorMessage: 'Falha ao buscar Ordens de Serviço.');
    }
  }

  Future<bool> createOrcamento({
    required int clienteId,
    required DateTime dataValidade,
    required String observacoesCondicoes,
    int? osOrigemId,
  }) async {
    state = state.copyWith(isSubmitting: true, clearErrors: true);
    try {
      final novoOrcamento = Orcamento(
        numeroOrcamento: '',
        dataCriacao: DateTime.now(),
        dataValidade: dataValidade,
        status: StatusOrcamentoModel.PENDENTE,
        clienteId: clienteId,
        ordemServicoOrigemId: osOrigemId,
        observacoesCondicoes: observacoesCondicoes,
      );

      await _orcamentoRepository.createOrcamento(novoOrcamento);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, submissionError: 'Erro ao criar orçamento.');
      return false;
    }
  }
}

// 3. O PROVIDER
final novoOrcamentoProvider = StateNotifierProvider.autoDispose<NovoOrcamentoNotifier, NovoOrcamentoState>((ref) {
  return NovoOrcamentoNotifier(
    ref.watch(orcamentoRepositoryProvider),
    ref.watch(clienteRepositoryProvider),
    ref.watch(osRepositoryProvider),
  );
});