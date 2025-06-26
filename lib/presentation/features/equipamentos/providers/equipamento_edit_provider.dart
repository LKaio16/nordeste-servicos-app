import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../domain/entities/cliente.dart';
import '../../../../domain/entities/equipamento.dart';
import '../../../../domain/repositories/cliente_repository.dart';
import '../../../../domain/repositories/equipamento_repository.dart';
import '../../../shared/providers/repository_providers.dart';

// 1. O Estado
class EquipamentoEditState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final Equipamento? originalEquipamento;
  final List<Cliente> clientes;
  final bool isSubmitting;
  final String? submissionError;

  const EquipamentoEditState({
    this.isLoading = true,
    this.errorMessage,
    this.originalEquipamento,
    this.clientes = const [],
    this.isSubmitting = false,
    this.submissionError,
  });

  EquipamentoEditState copyWith({
    bool? isLoading,
    String? errorMessage,
    Equipamento? originalEquipamento,
    List<Cliente>? clientes,
    bool? isSubmitting,
    String? submissionError,
    bool clearErrors = false,
  }) {
    return EquipamentoEditState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrors ? null : errorMessage ?? this.errorMessage,
      originalEquipamento: originalEquipamento ?? this.originalEquipamento,
      clientes: clientes ?? this.clientes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: clearErrors ? null : submissionError ?? this.submissionError,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, originalEquipamento, clientes, isSubmitting, submissionError];
}

// 2. O Notifier
class EquipamentoEditNotifier extends StateNotifier<EquipamentoEditState> {
  final EquipamentoRepository _equipamentoRepository;
  final ClienteRepository _clienteRepository;

  EquipamentoEditNotifier(this._equipamentoRepository, this._clienteRepository) : super(const EquipamentoEditState());

  Future<void> loadInitialData(int equipamentoId) async {
    state = state.copyWith(isLoading: true, clearErrors: true);
    try {
      // Busca os dados do equipamento e a lista de clientes em paralelo
      final results = await Future.wait([
        _equipamentoRepository.getEquipamentoById(equipamentoId),
        _clienteRepository.getClientes(),
      ]);

      final equipamento = results[0] as Equipamento;
      final clientes = results[1] as List<Cliente>;

      state = state.copyWith(isLoading: false, originalEquipamento: equipamento, clientes: clientes);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Erro ao carregar dados: ${e.toString()}");
    }
  }

  Future<bool> updateEquipamento(Equipamento equipamento) async {
    state = state.copyWith(isSubmitting: true, clearErrors: true);
    try {
      await _equipamentoRepository.updateEquipamento(equipamento);
      state = state.copyWith(isSubmitting: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, submissionError: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, submissionError: "Erro inesperado: ${e.toString()}");
      return false;
    }
  }
}

// 3. O Provider de Família
final equipamentoEditProvider = StateNotifierProvider.autoDispose.family<EquipamentoEditNotifier, EquipamentoEditState, int>((ref, equipamentoId) {
  return EquipamentoEditNotifier(
    ref.watch(equipamentoRepositoryProvider),
    ref.watch(clienteRepositoryProvider),
  );
});