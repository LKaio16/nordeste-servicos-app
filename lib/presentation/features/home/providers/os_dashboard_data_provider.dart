// lib/presentation/features/home/providers/os_dashboard_data_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../domain/usecases/get_os_dashboard_data_usecase.dart';
import '../../../shared/providers/repository_providers.dart'; // Para o osRepositoryProvider
import '../../dashboard/models/dashboard_data.dart';
import '../screens/admin_home_screen.dart'; // Para a classe DashboardData

// Define o estado para os dados do dashboard (incluindo loading e erro)
class OsDashboardState {
  final bool isLoading;
  final String? errorMessage;
  final DashboardData? data; // Reutilizando a classe DashboardData

  OsDashboardState({
    this.isLoading = false,
    this.errorMessage,
    this.data,
  });

  OsDashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    DashboardData? data,
  }) {
    return OsDashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      data: data ?? this.data,
    );
  }
}

// Define o StateNotifierProvider para o estado do dashboard de OS
final osDashboardProvider = StateNotifierProvider<OsDashboardNotifier, OsDashboardState>((ref) {
  final osRepository = ref.watch(osRepositoryProvider); // Obtém o repositório
  final getOsDashboardDataUseCase = GetOsDashboardDataUseCase(osRepository); // Cria o Use Case
  return OsDashboardNotifier(getOsDashboardDataUseCase);
});

class OsDashboardNotifier extends StateNotifier<OsDashboardState> {
  final GetOsDashboardDataUseCase _getOsDashboardDataUseCase;

  OsDashboardNotifier(this._getOsDashboardDataUseCase) : super(OsDashboardState()) {
    // Carrega os dados assim que o provider é inicializado
    fetchOsDashboardData();
  }

  Future<void> fetchOsDashboardData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final Map<String, int> result = await _getOsDashboardDataUseCase.call();

      // Mapeia o Map<String, int> retornado para o seu DashboardData
      final DashboardData dashboardData = DashboardData(
        totalOS: result['totalOs'] ?? 0,
        osEmAndamento: result['osEmAndamento'] ?? 0,
        osPendentes: result['osPendentes'] ?? 0,
        // Os orçamentos virão de outro lugar, ou de um dashboard use case combinado
        totalOrcamentos: 0,
        orcamentosAprovados: 0,
        orcamentosRejeitados: 0,
      );

      state = state.copyWith(isLoading: false, data: dashboardData);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro inesperado: ${e.toString()}');
    }
  }

  // Método para "atualizar" os dados, se necessário
  Future<void> refreshOsDashboardData() async {
    await fetchOsDashboardData();
  }
}