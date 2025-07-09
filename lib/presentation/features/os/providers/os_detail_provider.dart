import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // Para kDebugMode

import 'package:nordeste_servicos_app/domain/repositories/os_repository.dart';
import 'package:nordeste_servicos_app/presentation/shared/providers/repository_providers.dart';

import '../../../../domain/entities/ordem_servico.dart';
import 'os_detail_state.dart';

final osDetailProvider = FutureProvider.family<OrdemServico, int>((ref, osId) async {
  final repository = ref.watch(osRepositoryProvider); // Se você tem um provider para o repositório
  return repository.getOrdemServicoById(osId);
});

class OsDetailNotifier extends StateNotifier<OsDetailState> {
  final OsRepository _osRepository;
  final int _osId; // Armazena o ID da OS a ser buscada

  OsDetailNotifier(this._osRepository, this._osId) : super(const OsDetailState());

  // Carrega os detalhes da Ordem de Serviço específica
  Future<void> loadOsDetails({bool refresh = false}) async {
    // Se não for refresh e já estiver carregando ou já tiver os dados, evita chamadas múltiplas
    if (state.isLoading && !refresh) return;
    if (state.ordemServico != null && state.ordemServico!.id == _osId && !refresh) return;

    state = state.copyWith(isLoading: true, clearError: refresh, clearData: refresh);

    try {
      if (kDebugMode) {
        print('--- loadOsDetails: Iniciando busca para OS ID: $_osId ---');
      }

      // Chama o método do repositório REAL para buscar por ID
      final ordemServico = await _osRepository.getOrdemServicoById(_osId);

      if (kDebugMode) {
        print('--- loadOsDetails: Busca concluída com sucesso para OS ID: $_osId ---');
      }

      // Verifica se o notifier ainda está montado antes de atualizar o estado
      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        ordemServico: ordemServico, // Atualiza o estado com a OS encontrada
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('*******************************************');
        print('*** ERRO em loadOsDetails (Notifier) para OS ID: $_osId ***');
        print('Erro: ${e.toString()}');
        print('Stack Trace:');
        print(stackTrace);
        print('*******************************************');
      }

      // Verifica se o notifier ainda está montado antes de atualizar o estado
      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar detalhes da OS: ${e.toString()}',
      );
    }
  }

  // Método para recarregar os detalhes (útil para pull-to-refresh na tela)
  Future<void> refreshOsDetails() async {
    await loadOsDetails(refresh: true);
  }
}

