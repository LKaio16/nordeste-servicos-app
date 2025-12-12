// lib/domain/usecases/get_os_dashboard_data_usecase.dart

import '../repositories/os_repository.dart';
import '../../core/error/exceptions.dart'; // Importe a ApiException

class GetOsDashboardDataUseCase {
  final OsRepository repository;

  GetOsDashboardDataUseCase(this.repository);

  // Agora usa o método otimizado do repository que busca apenas estatísticas
  Future<Map<String, int>> call() async {
    try {
      // Usa o novo método que busca apenas estatísticas (sem buscar todas as OS)
      return await repository.getDashboardStats();
    } on ApiException {
      rethrow; // Re-lança a exceção para ser tratada na camada de apresentação (Provider)
    } catch (e) {
      throw ApiException('Erro inesperado ao obter dados do dashboard de OS: ${e.toString()}');
    }
  }
}