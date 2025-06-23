import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordeste_servicos_app/core/error/exceptions.dart';
import 'package:nordeste_servicos_app/domain/entities/cliente.dart';
import 'package:nordeste_servicos_app/domain/entities/equipamento.dart';
import 'package:nordeste_servicos_app/domain/repositories/cliente_repository.dart';
import 'package:nordeste_servicos_app/domain/repositories/equipamento_repository.dart';
import 'package:nordeste_servicos_app/presentation/shared/providers/repository_providers.dart';

// 1. O Estado da tela
class NovoEquipamentoState extends Equatable {
  final bool isLoading; // Para carregar dados iniciais (clientes)
  final String? errorMessage;
  final List<Cliente> clientes;
  final bool isSubmitting; // Para o processo de salvar
  final String? submissionError;

  const NovoEquipamentoState({
    this.isLoading = false,
    this.errorMessage,
    this.clientes = const [],
    this.isSubmitting = false,
    this.submissionError,
  });

  NovoEquipamentoState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Cliente>? clientes,
    bool? isSubmitting,
    String? submissionError,
    bool clearErrors = false,
  }) {
    return NovoEquipamentoState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrors ? null : errorMessage ?? this.errorMessage,
      clientes: clientes ?? this.clientes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: clearErrors ? null : submissionError ?? this.submissionError,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, clientes, isSubmitting, submissionError];
}

// 2. O Notifier que gerencia o estado
class NovoEquipamentoNotifier extends StateNotifier<NovoEquipamentoState> {
  final ClienteRepository _clienteRepository;
  final EquipamentoRepository _equipamentoRepository;

  NovoEquipamentoNotifier(this._clienteRepository, this._equipamentoRepository) : super(const NovoEquipamentoState());

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, clearErrors: true);
    try {
      final clientes = await _clienteRepository.getClientes();
      state = state.copyWith(isLoading: false, clientes: clientes);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Falha ao carregar clientes: ${e.toString()}');
    }
  }

  Future<bool> createEquipamento({
    required String tipo,
    required String marcaModelo,
    required String numeroSerieChassi,
    double? horimetro,
    required int clienteId,
  }) async {
    state = state.copyWith(isSubmitting: true, clearErrors: true);
    try {
      final novoEquipamento = Equipamento(
        tipo: tipo,
        marcaModelo: marcaModelo,
        numeroSerieChassi: numeroSerieChassi,
        horimetro: horimetro,
        clienteId: clienteId,
      );
      // Usando o método que você já tem no repositório
      await _equipamentoRepository.createEquipamento(novoEquipamento);
      state = state.copyWith(isSubmitting: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, submissionError: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, submissionError: 'Erro inesperado: ${e.toString()}');
      return false;
    }
  }
}

// 3. O Provider
final novoEquipamentoProvider = StateNotifierProvider<NovoEquipamentoNotifier, NovoEquipamentoState>((ref) {
  return NovoEquipamentoNotifier(
    ref.watch(clienteRepositoryProvider),
    ref.watch(equipamentoRepositoryProvider),
  );
});