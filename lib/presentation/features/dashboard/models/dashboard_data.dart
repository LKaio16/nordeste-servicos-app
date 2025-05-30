// lib/presentation/features/dashboard/models/dashboard_data.dart
// Este arquivo define o modelo de dados para o dashboard
class DashboardData {
  final int totalOS;
  final int osEmAndamento;
  final int osPendentes;
  final int totalOrcamentos;
  final int orcamentosAprovados;
  final int orcamentosRejeitados;

  DashboardData({
    required this.totalOS,
    required this.osEmAndamento,
    required this.osPendentes,
    required this.totalOrcamentos,
    required this.orcamentosAprovados,
    required this.orcamentosRejeitados,
  });
}