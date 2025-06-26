import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../data/models/cliente_request_dto.dart';
import '../../../../data/models/tipo_cliente.dart';
import '../../../../domain/entities/cliente.dart';
import '../../../../domain/repositories/cliente_repository.dart';
import '../../../shared/providers/repository_providers.dart';

// 1. O Estado
class ClienteEditState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final Cliente? originalCliente;
  final bool isSubmitting;
  final String? submissionError;

  const ClienteEditState({
    this.isLoading = false,
    this.errorMessage,
    this.originalCliente,
    this.isSubmitting = false,
    this.submissionError,
  });

  ClienteEditState copyWith({
    bool? isLoading,
    String? errorMessage,
    Cliente? originalCliente,
    bool? isSubmitting,
    String? submissionError,
    bool clearErrors = false,
  }) {
    return ClienteEditState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrors ? null : errorMessage ?? this.errorMessage,
      originalCliente: originalCliente ?? this.originalCliente,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: clearErrors ? null : submissionError ?? this.submissionError,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, originalCliente, isSubmitting, submissionError];
}

// 2. O Notifier
class ClienteEditNotifier extends StateNotifier<ClienteEditState> {
  final ClienteRepository _repository;

  ClienteEditNotifier(this._repository) : super(const ClienteEditState());

  Future<void> loadCliente(int clienteId) async {
    state = state.copyWith(isLoading: true, clearErrors: true);
    try {
      final cliente = await _repository.getClienteById(clienteId);
      state = state.copyWith(isLoading: false, originalCliente: cliente);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Erro ao carregar dados do cliente: ${e.toString()}");
    }
  }

  Future<bool> updateCliente({
    required int id,
    required TipoCliente tipoCliente,
    required String nomeCompleto,
    required String cpfCnpj,
    required String email,
    required String telefonePrincipal,
    String? telefoneAdicional,
    required String cep,
    required String rua,
    required String numero,
    String? complemento,
    required String bairro,
    required String cidade,
    required String estado,
  }) async {
    state = state.copyWith(isSubmitting: true, clearErrors: true);
    try {
      final dto = ClienteRequestDTO(
        tipoCliente: tipoCliente,
        nomeCompleto: nomeCompleto,
        cpfCnpj: cpfCnpj,
        email: email,
        telefonePrincipal: telefonePrincipal,
        telefoneAdicional: telefoneAdicional,
        cep: cep,
        rua: rua,
        numero: numero,
        complemento: complemento,
        bairro: bairro,
        cidade: cidade,
        estado: estado,
      );
      await _repository.updateCliente(id, dto);
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
final clienteEditProvider = StateNotifierProvider.autoDispose.family<ClienteEditNotifier, ClienteEditState, int>((ref, clienteId) {
  return ClienteEditNotifier(ref.watch(clienteRepositoryProvider));
});