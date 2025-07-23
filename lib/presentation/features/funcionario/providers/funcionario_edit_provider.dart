import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordeste_servicos_app/core/error/exceptions.dart';
import 'package:nordeste_servicos_app/data/models/perfil_usuario_model.dart';
import 'package:nordeste_servicos_app/domain/entities/usuario.dart';
import 'package:nordeste_servicos_app/domain/repositories/usuario_repository.dart';
import 'package:nordeste_servicos_app/presentation/shared/providers/repository_providers.dart';

// 1. O Estado
class FuncionarioEditState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final Usuario? originalFuncionario;
  final bool isSubmitting;
  final String? submissionError;

  const FuncionarioEditState({
    this.isLoading = false,
    this.errorMessage,
    this.originalFuncionario,
    this.isSubmitting = false,
    this.submissionError,
  });

  FuncionarioEditState copyWith({
    bool? isLoading,
    String? errorMessage,
    Usuario? originalFuncionario,
    bool? isSubmitting,
    String? submissionError,
    bool clearErrors = false,
  }) {
    return FuncionarioEditState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrors ? null : errorMessage ?? this.errorMessage,
      originalFuncionario: originalFuncionario ?? this.originalFuncionario,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: clearErrors ? null : submissionError ?? this.submissionError,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, originalFuncionario, isSubmitting, submissionError];
}

// 2. O Notifier
class FuncionarioEditNotifier extends StateNotifier<FuncionarioEditState> {
  final UsuarioRepository _repository;

  FuncionarioEditNotifier(this._repository) : super(const FuncionarioEditState());

  Future<void> loadFuncionario(int funcionarioId) async {
    state = state.copyWith(isLoading: true, clearErrors: true);
    try {
      final funcionario = await _repository.getUserById(funcionarioId);
      state = state.copyWith(isLoading: false, originalFuncionario: funcionario);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Erro ao carregar dados: ${e.toString()}");
    }
  }

  Future<bool> updateFuncionario({
    required int id,
    required String nome,
    required String cracha,
    required String email,
    required PerfilUsuarioModel perfil,
    String? fotoPerfil,
  }) async {
    state = state.copyWith(isSubmitting: true, clearErrors: true);
    try {
      final funcionarioAtualizado = Usuario(
        id: id,
        nome: nome,
        cracha: cracha,
        email: email,
        perfil: perfil,
        fotoPerfil: fotoPerfil,
      );
      await _repository.updateUser(funcionarioAtualizado);
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

  Future<bool> updatePassword(int funcionarioId, String newPassword) async {
    state = state.copyWith(isSubmitting: true, clearErrors: true);
    try {
      await _repository.updatePassword(funcionarioId, newPassword);
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
final funcionarioEditProvider = StateNotifierProvider.family<FuncionarioEditNotifier, FuncionarioEditState, int>((ref, funcionarioId) {
  return FuncionarioEditNotifier(ref.watch(usuarioRepositoryProvider));
});