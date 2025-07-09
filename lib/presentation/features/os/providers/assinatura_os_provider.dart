import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordeste_servicos_app/domain/entities/assinatura_os.dart';
import 'package:nordeste_servicos_app/domain/repositories/assinatura_os_repository.dart';
import 'package:nordeste_servicos_app/presentation/shared/providers/repository_providers.dart';

class AssinaturaState extends Equatable {
  final AssinaturaOS? assinatura;
  final bool isLoading;
  final String? errorMessage;

  const AssinaturaState({
    this.assinatura,
    this.isLoading = false,
    this.errorMessage,
  });

  AssinaturaState copyWith({
    AssinaturaOS? assinatura,
    bool? isLoading,
    String? errorMessage,
    bool clearAssinatura = false,
    bool clearError = false,
  }) {
    return AssinaturaState(
      assinatura: clearAssinatura ? null : assinatura ?? this.assinatura,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [assinatura, isLoading, errorMessage];
}

class AssinaturaNotifier extends StateNotifier<AssinaturaState> {
  final AssinaturaOsRepository _repository;
  final int _osId;

  AssinaturaNotifier(this._repository, this._osId) : super(const AssinaturaState()) {
    fetchAssinatura();
  }

  Future<void> fetchAssinatura() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final assinatura = await _repository.getAssinaturaByOsId(_osId);
      state = state.copyWith(
        assinatura: assinatura,
        isLoading: false,

        clearAssinatura: assinatura == null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<bool> saveAssinatura(AssinaturaOS assinatura) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final savedAssinatura = await _repository.uploadAssinatura(_osId, assinatura);
      state = state.copyWith(assinatura: savedAssinatura, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      return false;
    }
  }
}

final assinaturaProvider =
StateNotifierProvider.autoDispose.family<AssinaturaNotifier, AssinaturaState, int>((ref, osId) {
  final repository = ref.watch(assinaturaOsRepositoryProvider);
  return AssinaturaNotifier(repository, osId);
});