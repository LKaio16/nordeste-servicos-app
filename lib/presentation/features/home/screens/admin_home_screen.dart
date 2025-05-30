// lib/presentation/features/auth/presentation/screens/admin_home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/usuario.dart';
import '../../auth/providers/auth_provider.dart'; // Seu AuthProvider
import '../../auth/providers/auth_state.dart';
import '../providers/os_dashboard_data_provider.dart'; // O que você já tem para OS
import 'package:nordeste_servicos_app/presentation/features/orcamentos/providers/orcamento_dashboard_provider.dart'; // O NOVO para Orçamentos
import 'package:nordeste_servicos_app/presentation/features/dashboard/models/dashboard_data.dart'; // Importe DashboardData

// Definição de cores
class AppColors {
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFE53935);
  static const Color lightGrey = Color(0xFFF5F5F5);
}

// Modelos de Dados (mantidos aqui, mas considere mover para arquivos próprios em 'models')
class AdminInfo {
  final String avatarUrl;
  final String tituloPortal;
  final String subtituloPortal;

  AdminInfo({
    required this.avatarUrl,
    required this.tituloPortal,
    required this.subtituloPortal,
  });
}

class StatusItem {
  final String label;
  final int value;
  final Color color;

  StatusItem({
    required this.label,
    required this.value,
    required this.color,
  });
}

class QuickAction {
  final String titulo;
  final IconData icon;
  final String rota;

  QuickAction({
    required this.titulo,
    required this.icon,
    required this.rota,
  });
}

class Technician {
  final String id;
  final String nome;
  final String avatarUrl;
  final int totalOS;
  final double desempenho;

  Technician({
    required this.id,
    required this.nome,
    required this.avatarUrl,
    required this.totalOS,
    required this.desempenho,
  });
}

class Activity {
  final String tipo;
  final String descricao;
  final String tempoDecorrido;

  Activity({
    required this.tipo,
    required this.descricao,
    required this.tempoDecorrido,
  });
}

// Dados Mocados (mantidos para quick actions, technicians, activities)
final AdminInfo mockAdminData = AdminInfo(
  avatarUrl: 'https://i.pravatar.cc/150?img=3',
  tituloPortal: 'Admin Portal',
  subtituloPortal: 'Nordeste Serviços',
);

final DashboardData mockDashboardData = DashboardData(
  totalOS: 247,
  osEmAndamento: 45,
  osPendentes: 12,
  totalOrcamentos: 89,
  orcamentosAprovados: 65,
  orcamentosRejeitados: 24,
);

final List<QuickAction> mockQuickActions = [
  QuickAction(
    titulo: 'Nova OS',
    icon: Icons.add_chart,
    rota: '/nova-os',
  ),
  QuickAction(
    titulo: 'Add Cliente',
    icon: Icons.person_add_outlined,
    rota: '/novo-cliente',
  ),
  QuickAction(
    titulo: 'Add Técnico',
    icon: Icons.engineering,
    rota: '/add-tecnico',
  ),
];

final List<Technician> mockTechnicians = [
  Technician(
    id: '1',
    nome: 'Carlos Silva',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
    totalOS: 32,
    desempenho: 0.8,
  ),
  Technician(
    id: '2',
    nome: 'Pedro Santos',
    avatarUrl: 'https://i.pravatar.cc/150?img=11',
    totalOS: 28,
    desempenho: 0.7,
  ),
];

final List<Activity> mockRecentActivities = [
  Activity(
    tipo: 'os_concluida',
    descricao: 'OS #2547 concluída',
    tempoDecorrido: 'Há 2 horas',
  ),
  Activity(
    tipo: 'cliente_cadastrado',
    descricao: 'Novo cliente cadastrado',
    tempoDecorrido: 'Há 4 horas',
  ),
];

// Tela Principal
class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  int _selectedIndex = 0;
  bool _initialDataLoaded = false; // Flag para garantir que o carregamento inicial ocorra apenas uma vez

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.authenticatedUser != null && !_initialDataLoaded) {
        ref.read(osDashboardProvider.notifier).fetchOsDashboardData();
        ref.read(orcamentoDashboardProvider.notifier).fetchOrcamentoDashboardData();
        _initialDataLoaded = true;
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Lógica de navegação para a BottomNavigationBar.
    switch (index) {
      case 0:
      // Já está na Home/Dashboard
        break;
      case 1:
      // Navigator.of(context).pushNamed('/lista-os'); // Exemplo
        break;
      case 2:
      // Navigator.of(context).pushNamed('/lista-orcamentos'); // Exemplo
        break;
      case 3:
      // Navigator.of(context).pushNamed('/gestao'); // Exemplo
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final osDashboardState = ref.watch(osDashboardProvider);
    final orcamentoDashboardState = ref.watch(orcamentoDashboardProvider);

    if (osDashboardState.isLoading || orcamentoDashboardState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (osDashboardState.errorMessage != null || orcamentoDashboardState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.errorRed, size: 48),
            const SizedBox(height: 16),
            if (osDashboardState.errorMessage != null)
              Text(
                'Erro OS: ${osDashboardState.errorMessage}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.errorRed, fontSize: 16),
              ),
            if (orcamentoDashboardState.errorMessage != null)
              Text(
                'Erro Orçamentos: ${orcamentoDashboardState.errorMessage}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.errorRed, fontSize: 16),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(osDashboardProvider.notifier).fetchOsDashboardData();
                ref.read(orcamentoDashboardProvider.notifier).fetchOrcamentoDashboardData();
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    final DashboardData displayOsData = osDashboardState.data!;
    final DashboardData displayOrcamentoData = orcamentoDashboardState.data!;

    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DashboardCardWidget(
                    title: 'OS',
                    count: displayOsData.totalOS,
                    icon: Icons.description_outlined,
                    statusItems: [
                      StatusItem(
                        label: 'Em andamento',
                        value: displayOsData.osEmAndamento,
                        color: AppColors.successGreen,
                      ),
                      StatusItem(
                        label: 'Pendentes',
                        value: displayOsData.osPendentes,
                        color: AppColors.warningOrange,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardCardWidget(
                    title: 'Orçamentos',
                    count: displayOrcamentoData.totalOrcamentos,
                    icon: Icons.request_quote_outlined,
                    statusItems: [
                      StatusItem(
                        label: 'Aprovados',
                        value: displayOrcamentoData.orcamentosAprovados,
                        color: AppColors.successGreen,
                      ),
                      StatusItem(
                        label: 'Rejeitados',
                        value: displayOrcamentoData.orcamentosRejeitados,
                        color: AppColors.errorRed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            QuickActionsWidget(actions: mockQuickActions), // MODIFICADO
            const SizedBox(height: 24),
            TechnicianPerformanceWidget(technicians: mockTechnicians),
            const SizedBox(height: 24),
            RecentActivitiesWidget(activities: mockRecentActivities),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      title: const AdminHeaderWidget(),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            // Ação de configurações
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () {
            ref.read(authProvider.notifier).logout();
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description_outlined),
          label: 'OS',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.request_quote_outlined),
          label: 'Orçamentos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Gestão',
        ),
      ],
    );
  }
}

// Widgets Customizados (AdminHeaderWidget, DashboardCardWidget, StatusItemWidget, QuickActionsWidget,
// QuickActionButtonWidget, TechnicianPerformanceWidget, TechnicianItemWidget,
// RecentActivitiesWidget, ActivityItemWidget) permanecem inalterados.
// Apenas garanta que eles estão no mesmo arquivo ou importados corretamente.

class AdminHeaderWidget extends ConsumerWidget {
  const AdminHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final Usuario? adminUser = authState.authenticatedUser;

    final String avatarUrl = adminUser?.cracha != null
        ? 'https://i.pravatar.cc/150?img=${adminUser!.cracha.hashCode % 20}'
        : 'https://i.pravatar.cc/150?img=3';

    final String tituloPortal = adminUser?.nome ?? 'Carregando...';
    final String subtituloPortal = adminUser?.perfil.name ?? 'Carregando...';

    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(avatarUrl),
          radius: 18,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tituloPortal,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              subtituloPortal,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DashboardCardWidget extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final List<StatusItem> statusItems;

  const DashboardCardWidget({
    Key? key,
    required this.title,
    required this.count,
    required this.icon,
    required this.statusItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(icon, color: AppColors.primaryBlue),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            ...statusItems.map((item) => StatusItemWidget(item: item)),
          ],
        ),
      ),
    );
  }
}

class StatusItemWidget extends StatelessWidget {
  final StatusItem item;

  const StatusItemWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Text(
            '${item.label}: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            item.value.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: item.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================
// INÍCIO DAS MODIFICAÇÕES DE LAYOUT PARA AÇÕES RÁPIDAS
// ===============================================

class QuickActionsWidget extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionsWidget({Key? key, required this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ações Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround, // Ajusta o espaçamento dos botões
          children: actions
              .map((action) => QuickActionButtonWidget(action: action))
              .toList(),
        ),
      ],
    );
  }
}

class QuickActionButtonWidget extends StatelessWidget {
  final QuickAction action;

  const QuickActionButtonWidget({Key? key, required this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usamos Expanded para que o botão preencha o espaço horizontal disponível
    // e adicionamos um Padding para criar um espaçamento entre eles.
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0), // Espaçamento entre os botões
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed(action.rota);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            // Aumentar o padding vertical para deixar o botão mais "cheio"
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Deixar as bordas mais arredondadas
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ocupa o mínimo de espaço vertical necessário
            children: [
              Icon(action.icon, color: Colors.white, size: 28), // Ícone um pouco maior
              const SizedBox(height: 8),
              Text(
                action.titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14, // Fonte um pouco maior
                  fontWeight: FontWeight.w600, // Levemente mais negrito
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis, // Para lidar com textos longos
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================
// FIM DAS MODIFICAÇÕES DE LAYOUT PARA AÇÕES RÁPIDAS
// ===============================================


class TechnicianPerformanceWidget extends StatelessWidget {
  final List<Technician> technicians;

  const TechnicianPerformanceWidget({Key? key, required this.technicians}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Desempenho por Técnico',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...technicians.map((tech) => TechnicianItemWidget(technician: tech)),
      ],
    );
  }
}

class TechnicianItemWidget extends StatelessWidget {
  final Technician technician;

  const TechnicianItemWidget({Key? key, required this.technician}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(technician.avatarUrl),
            radius: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      technician.nome,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${technician.totalOS} OS',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: technician.desempenho,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.successGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecentActivitiesWidget extends StatelessWidget {
  final List<Activity> activities;

  const RecentActivitiesWidget({Key? key, required this.activities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Atividades Recentes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...activities.map((activity) => ActivityItemWidget(activity: activity)),
      ],
    );
  }
}

class ActivityItemWidget extends StatelessWidget {
  final Activity activity;

  const ActivityItemWidget({Key? key, required this.activity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getActivityColor(activity.tipo).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getActivityIcon(activity.tipo),
              color: _getActivityColor(activity.tipo),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.descricao,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  activity.tempoDecorrido,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String tipo) {
    if (tipo == 'os_concluida') return Colors.blue;
    if (tipo == 'cliente_cadastrado') return Colors.green;
    return Colors.grey;
  }

  IconData _getActivityIcon(String tipo) {
    if (tipo == 'os_concluida') return Icons.check_circle_outline;
    if (tipo == 'cliente_cadastrado') return Icons.person_add_outlined;
    return Icons.info_outline;
  }
}