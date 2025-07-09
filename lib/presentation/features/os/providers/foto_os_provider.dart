import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nordeste_servicos_app/core/error/exceptions.dart';
import 'package:nordeste_servicos_app/domain/entities/foto_os.dart';
import 'package:nordeste_servicos_app/domain/repositories/foto_os_repository.dart';
import 'package:nordeste_servicos_app/presentation/shared/providers/repository_providers.dart';

// 1. O Estado
class FotoOsState extends Equatable {
  final List<FotoOS> fotos;
  final bool isLoading;
  final String? errorMessage;
  final bool isUploading; // Para controlar o loading do upload

  const FotoOsState({
    this.fotos = const [],
    this.isLoading = true,
    this.errorMessage,
    this.isUploading = false,
  });

  FotoOsState copyWith({
    List<FotoOS>? fotos,
    bool? isLoading,
    String? errorMessage,
    bool? isUploading,
    bool clearError = false,
  }) {
    return FotoOsState(
      fotos: fotos ?? this.fotos,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isUploading: isUploading ?? this.isUploading,
    );
  }

  @override
  List<Object?> get props => [fotos, isLoading, errorMessage, isUploading];
}

// 2. O Notifier
class FotoOsNotifier extends StateNotifier<FotoOsState> {
  final FotoOsRepository _repository;
  final int _osId;

  FotoOsNotifier(this._repository, this._osId) : super(const FotoOsState()) {
    fetchFotos();
  }

  Future<void> fetchFotos() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final fotos = await _repository.getFotosByOsId(_osId);
      state = state.copyWith(isLoading: false, fotos: fotos);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Erro inesperado ao buscar fotos.");
    }
  }

  Future<void> uploadFoto(XFile imageFile, String? description) async {
    state = state.copyWith(isUploading: true, clearError: true);
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);

      await _repository.uploadFoto(
        _osId,
        base64: base64String,
        description: description,
        fileName: imageFile.name,
        mimeType: imageFile.mimeType,
        fileSize: bytes.length,
      );

      await fetchFotos();
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(errorMessage: "Erro inesperado durante o upload.");
    } finally {
      state = state.copyWith(isUploading: false);
    }
  }

  Future<void> deleteFoto(int fotoId) async {
    final currentFotos = List<FotoOS>.from(state.fotos);
    try {
      state = state.copyWith(fotos: state.fotos..removeWhere((f) => f.id == fotoId));

      // **CORREÇÃO APLICADA AQUI**
      // Passa o _osId que o notifier já conhece, junto com o fotoId.
      await _repository.deleteFoto(_osId, fotoId);
    } catch (e) {
      // Se der erro, restaura a lista.
      state = state.copyWith(fotos: currentFotos);
      // Opcional: Mostrar uma mensagem de erro na UI.
      // state = state.copyWith(errorMessage: "Falha ao excluir a foto.");
    }
  }
}

// 3. O Provider (Family)
final fotoOsProvider = StateNotifierProvider.autoDispose.family<FotoOsNotifier, FotoOsState, int>((ref, osId) {
  final repository = ref.watch(fotoOsRepositoryProvider);
  return FotoOsNotifier(repository, osId);
});