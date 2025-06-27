import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordeste_servicos_app/domain/entities/cliente.dart';
import 'package:nordeste_servicos_app/domain/entities/ordem_servico.dart';
import 'package:nordeste_servicos_app/domain/entities/orcamento.dart';
import 'package:nordeste_servicos_app/domain/repositories/cliente_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/os_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/orcamento_repository.dart';
import 'package:nordeste_servicos_app/presentation/shared/providers/repository_providers.dart';

// 1. O Estado (com a correção)
class OrcamentoEditState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final Orcamento? originalOrcamento;
  final List<Cliente> clientes;
  final bool isLoadingOs; // <<< CAMPO ADICIONADO AQUI
  final List<OrdemServico> ordensDeServico;
  final bool isSubmitting;
  final String? submissionError;

  const OrcamentoEditState({
    this.isLoading = true,
    this.errorMessage,
    this.originalOrcamento,
    this.clientes = const [],
    this.isLoadingOs = false, // <<< CAMPO ADICIONADO AQUI
    this.ordensDeServico = const [],
    this.isSubmitting = false,
    this.submissionError,
  });

  OrcamentoEditState copyWith({
    bool? isLoading,
    String? errorMessage,
    Orcamento? originalOrcamento,
    List<Cliente>? clientes,
    bool? isLoadingOs, // <<< AGORA O PARÂMETRO É VÁLIDO
    List<OrdemServico>? ordensDeServico,
    bool? isSubmitting,
    String? submissionError,
    bool clearErrors = false,
  }) {
    return OrcamentoEditState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrors ? null : errorMessage ?? this.errorMessage,
      originalOrcamento: originalOrcamento ?? this.originalOrcamento,
      clientes: clientes ?? this.clientes,
      isLoadingOs: isLoadingOs ?? this.isLoadingOs, // <<< AGORA O PARÂMETRO É VÁLIDO
      ordensDeServico: ordensDeServico ?? this.ordensDeServico,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: clearErrors ? null : submissionError ?? this.submissionError,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, originalOrcamento, clientes, isLoadingOs, ordensDeServico, isSubmitting, submissionError];
}

// 2. O Notifier (sem alterações, mas incluído para o contexto completo)
class OrcamentoEditNotifier extends StateNotifier<OrcamentoEditState> {
  final OrcamentoRepository _orcamentoRepository;
  final ClienteRepository _clienteRepository;
  final OsRepository _osRepository;

  OrcamentoEditNotifier(this._orcamentoRepository, this._clienteRepository, this._osRepository) : super(const OrcamentoEditState());

  Future<void> loadInitialData(int orcamentoId) async {
    state = state.copyWith(isLoading: true, clearErrors: true);
    try {
      final results = await Future.wait([
        _orcamentoRepository.getOrcamentoById(orcamentoId),
        _clienteRepository.getClientes(),
      ]);

      final orcamento = results[0] as Orcamento;
      final clientes = results[1] as List<Cliente>;

      final ordensDoCliente = await _osRepository.getOrdensServico(clienteId: orcamento.clienteId);

      state = state.copyWith(
        isLoading: false,
        originalOrcamento: orcamento,
        clientes: clientes,
        ordensDeServico: ordensDoCliente,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Erro ao carregar dados: ${e.toString()}");
    }
  }

  Future<void> fetchOrdensDeServico(int clienteId) async {
    state = state.copyWith(isLoadingOs: true, ordensDeServico: []);
    try {
      final ordens = await _osRepository.getOrdensServico(clienteId: clienteId);
      state = state.copyWith(isLoadingOs: false, ordensDeServico: ordens);
    } catch (e) {
      // Lidar com o erro se necessário
    }
  }

  Future<bool> updateOrcamento(Orcamento orcamento) async {
    state = state.copyWith(isSubmitting: true, clearErrors: true);
    try {
      await _orcamentoRepository.updateOrcamento(orcamento);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, submissionError: "Erro ao atualizar: ${e.toString()}");
      return false;
    }
  }
}

// 3. O Provider de Família (sem alterações)
final orcamentoEditProvider = StateNotifierProvider.family.autoDispose<OrcamentoEditNotifier, OrcamentoEditState, int>((ref, orcamentoId) {
  return OrcamentoEditNotifier(
    ref.watch(orcamentoRepositoryProvider),
    ref.watch(clienteRepositoryProvider),
    ref.watch(osRepositoryProvider),
  );
});