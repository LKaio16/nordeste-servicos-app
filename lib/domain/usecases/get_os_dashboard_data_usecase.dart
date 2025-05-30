// lib/domain/usecases/get_os_dashboard_data_usecase.dart

import '../entities/ordem_servico.dart';
import '../repositories/os_repository.dart';
import '../../data/models/status_os_model.dart'; // Importe o enum de status
import '../../core/error/exceptions.dart'; // Importe a ApiException

class GetOsDashboardDataUseCase {
  final OsRepository repository;

  GetOsDashboardDataUseCase(this.repository);

  // Define um DTO para os dados resumidos do dashboard
  // Poderíamos usar a classe DashboardData que você já tem no admin_home_screen.dart
  // Mas para o UseCase, podemos criar uma própria ou reutilizar DashboardData.
  // Vamos reutilizar o DashboardData que já está na sua tela.

  Future<Map<String, int>> call() async {
    try {
      // 1. Busca todas as ordens de serviço (ou as que são relevantes para o dashboard)
      // Idealmente, você buscaria apenas um subconjunto ou teria um endpoint de resumo.
      // Por enquanto, pegamos todas para calcular no cliente.
      final List<OrdemServico> allOs = await repository.getOrdensServico();

      int totalOs = allOs.length;
      int osEmAndamento = 0;
      int osPendentes = 0;

      // 2. Itera sobre a lista para contar os status
      for (var os in allOs) {
        if (os.status == StatusOSModel.EM_ANDAMENTO) { // Use o valor correto do seu enum
          osEmAndamento++;
        }
        if (os.status == StatusOSModel.AGUARDANDO_APROVACAO) { // Use o valor correto do seu enum
          osPendentes++;
        }
      }

      return {
        'totalOs': totalOs,
        'osEmAndamento': osEmAndamento,
        'osPendentes': osPendentes,
      };
    } on ApiException {
      rethrow; // Re-lança a exceção para ser tratada na camada de apresentação (Provider)
    } catch (e) {
      throw ApiException('Erro inesperado ao obter dados do dashboard de OS: ${e.toString()}');
    }
  }
}