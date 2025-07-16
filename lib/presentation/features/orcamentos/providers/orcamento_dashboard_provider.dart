// lib/presentation/features/orcamentos/providers/orcamento_dashboard_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordeste_servicos_app/core/error/exceptions.dart';
import 'package:nordeste_servicos_app/data/models/status_orcamento_model.dart';
import 'package:nordeste_servicos_app/domain/repositories/orcamento_repository.dart';
import 'package:nordeste_servicos_app/presentation/shared/providers/repository_providers.dart';
import 'package:nordeste_servicos_app/presentation/features/orcamentos/providers/orcamento_dashboard_state.dart';

import '../../dashboard/models/dashboard_data.dart';
import '../../home/screens/admin_home_screen.dart';


final orcamentoDashboardProvider = StateNotifierProvider<OrcamentoDashboardNotifier, OrcamentoDashboardState>((ref) {
  final orcamentoRepository = ref.read(orcamentoRepositoryProvider);
  return OrcamentoDashboardNotifier(orcamentoRepository);
});

class OrcamentoDashboardNotifier extends StateNotifier<OrcamentoDashboardState> {
  final OrcamentoRepository _orcamentoRepository;

  OrcamentoDashboardNotifier(this._orcamentoRepository) : super(OrcamentoDashboardState()) {
    // Carrega os dados assim que o provider é criado
    fetchOrcamentoDashboardData();
  }

  Future<void> refresh() async {
    await fetchOrcamentoDashboardData();
  }

  Future<void> fetchOrcamentoDashboardData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final allOrcamentos = await _orcamentoRepository.getOrcamentos();
      final approvedOrcamentos = await _orcamentoRepository.getOrcamentos(status: StatusOrcamentoModel.APROVADO);
      final rejectedOrcamentos = await _orcamentoRepository.getOrcamentos(status: StatusOrcamentoModel.REJEITADO);

      final DashboardData dashboardData = DashboardData(
        totalOS: 0, // OS não é foco aqui, pode ser zero ou buscar de outro provider
        osEmAndamento: 0,
        osPendentes: 0,
        totalOrcamentos: allOrcamentos.length,
        orcamentosAprovados: approvedOrcamentos.length,
        orcamentosRejeitados: rejectedOrcamentos.length,
      );

      state = state.copyWith(data: dashboardData, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado: ${e.toString()}', isLoading: false);
    }
  }
}