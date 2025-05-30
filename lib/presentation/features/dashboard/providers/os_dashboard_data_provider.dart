// lib/presentation/features/dashboard/providers/os_dashboard_data_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordeste_servicos_app/core/error/exceptions.dart';
import 'package:nordeste_servicos_app/data/models/status_os_model.dart'; // Importe seu enum de Status OS
import 'package:nordeste_servicos_app/domain/repositories/os_repository.dart';
import 'package:nordeste_servicos_app/presentation/features/dashboard/models/dashboard_data.dart';
import 'package:nordeste_servicos_app/presentation/shared/providers/repository_providers.dart';

// 1. Estado do Dashboard de OS
class OsDashboardState {
  final DashboardData? data;
  final bool isLoading;
  final String? errorMessage;

  OsDashboardState({
    this.data,
    this.isLoading = true, // Inicia carregando
    this.errorMessage,
  });

  OsDashboardState copyWith({
    DashboardData? data,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OsDashboardState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Permite limpar o erro passando null
    );
  }
}

// 2. StateNotifier para gerenciar o estado
class OsDashboardNotifier extends StateNotifier<OsDashboardState> {
  final OsRepository _osRepository;

  OsDashboardNotifier(this._osRepository) : super(OsDashboardState()) {
    // Carrega os dados assim que o provider é criado
    fetchOsDashboardData();
  }

  Future<void> fetchOsDashboardData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final allOs = await _osRepository.getOrdensServico();
      final osEmAndamento = await _osRepository.getOrdensServico(status: StatusOSModel.EM_ANDAMENTO);
      final osPendentes = await _osRepository.getOrdensServico(status: StatusOSModel.AGUARDANDO_APROVACAO);

      final DashboardData dashboardData = DashboardData(
        totalOS: allOs.length,
        osEmAndamento: osEmAndamento.length,
        osPendentes: osPendentes.length,
        totalOrcamentos: 0, // Orçamentos não são foco aqui, pode ser zero ou buscar de outro provider
        orcamentosAprovados: 0,
        orcamentosRejeitados: 0,
      );

      state = state.copyWith(data: dashboardData, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado: ${e.toString()}', isLoading: false);
    }
  }
}

// 3. O StateNotifierProvider
final osDashboardProvider = StateNotifierProvider<OsDashboardNotifier, OsDashboardState>((ref) {
  final osRepository = ref.read(osRepositoryProvider);
  return OsDashboardNotifier(osRepository);
});