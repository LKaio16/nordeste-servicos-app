// lib/presentation/features/orcamentos/providers/orcamento_dashboard_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordeste_servicos_app/core/error/exceptions.dart';
import 'package:nordeste_servicos_app/domain/repositories/orcamento_repository.dart';
import 'package:nordeste_servicos_app/presentation/features/auth/providers/auth_provider.dart';
import 'package:nordeste_servicos_app/presentation/features/auth/providers/auth_state.dart';
import 'package:nordeste_servicos_app/presentation/shared/providers/repository_providers.dart';
import 'package:nordeste_servicos_app/presentation/features/orcamentos/providers/orcamento_dashboard_state.dart';

import '../../dashboard/models/dashboard_data.dart';

final orcamentoDashboardProvider = StateNotifierProvider<OrcamentoDashboardNotifier, OrcamentoDashboardState>((ref) {
  final orcamentoRepository = ref.read(orcamentoRepositoryProvider);
  final notifier = OrcamentoDashboardNotifier(orcamentoRepository);

  void scheduleIfReady(AuthState auth) {
    if (auth.isLoading || !auth.isAuthenticated) return;
    Future.microtask(() => notifier.fetchOrcamentoDashboardData());
  }

  ref.listen<AuthState>(authProvider, (previous, next) {
    scheduleIfReady(next);
  });

  scheduleIfReady(ref.read(authProvider));

  return notifier;
});

class OrcamentoDashboardNotifier extends StateNotifier<OrcamentoDashboardState> {
  final OrcamentoRepository _orcamentoRepository;

  OrcamentoDashboardNotifier(this._orcamentoRepository) : super(OrcamentoDashboardState());

  Future<void> refresh() async {
    await fetchOrcamentoDashboardData();
  }

  Future<void> fetchOrcamentoDashboardData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final stats = await _orcamentoRepository.getDashboardStats();

      final DashboardData dashboardData = DashboardData(
        totalOS: 0,
        osEmAndamento: 0,
        osPendentes: 0,
        totalOrcamentos: stats['totalOrcamentos'] ?? 0,
        orcamentosAprovados: stats['orcamentosAprovados'] ?? 0,
        orcamentosRejeitados: stats['orcamentosRejeitados'] ?? 0,
      );

      state = state.copyWith(data: dashboardData, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado: ${e.toString()}', isLoading: false);
    }
  }
}
