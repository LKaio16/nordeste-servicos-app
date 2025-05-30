// lib/presentation/features/auth/presentation/screens/admin_home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; // Importando Google Fonts para fontes modernas

import '../../../../domain/entities/usuario.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/auth_state.dart';
import '../providers/os_dashboard_data_provider.dart';
import 'package:nordeste_servicos_app/presentation/features/orcamentos/providers/orcamento_dashboard_provider.dart';
import 'package:nordeste_servicos_app/presentation/features/dashboard/models/dashboard_data.dart';

// Definição de cores modernizadas
class AppColors {
  // Cores principais
  static const Color primaryBlue = Color(0xFF1A73E8); // Azul principal mais vibrante
  static const Color secondaryBlue = Color(0xFF4285F4); // Azul secundário
  static const Color accentBlue = Color(0xFF8AB4F8); // Azul claro para acentos
  static const Color darkBlue = Color(0xFF0D47A1); // Azul escuro para detalhes

  // Cores de status
  static const Color successGreen = Color(0xFF34A853); // Verde mais moderno
  static const Color warningOrange = Color(0xFFFFA000); // Laranja mais vibrante
  static const Color errorRed = Color(0xFFEA4335); // Vermelho mais moderno

  // Cores de fundo e texto
  static const Color backgroundGray = Color(0xFFF8F9FA); // Fundo cinza claro
  static const Color cardBackground = Colors.white; // Fundo dos cards
  static const Color textDark = Color(0xFF202124); // Texto escuro
  static const Color textLight = Color(0xFF5F6368); // Texto cinza
  static const Color dividerColor = Color(0xFFEEEEEE); // Cor para divisores
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

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _initialDataLoaded = false;

  // Adicionando animação para melhorar a experiência do usuário
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    // Configuração da animação
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.1, 1.0, curve: Curves.easeOut),
      ),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.authenticatedUser != null && !_initialDataLoaded) {
        ref.read(osDashboardProvider.notifier).fetchOsDashboardData();
        ref.read(orcamentoDashboardProvider.notifier).fetchOrcamentoDashboardData();
        _initialDataLoaded = true;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      // Navigator.of(context).pushNamed('/lista-os');
        break;
      case 2:
      // Navigator.of(context).pushNamed('/lista-orcamentos');
        break;
      case 3:
      // Navigator.of(context).pushNamed('/gestao');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final osDashboardState = ref.watch(osDashboardProvider);
    final orcamentoDashboardState = ref.watch(orcamentoDashboardProvider);
    final size = MediaQuery.of(context).size;

    if (osDashboardState.isLoading || orcamentoDashboardState.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundGray,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Carregando dados...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (osDashboardState.errorMessage != null || orcamentoDashboardState.errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundGray,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: AppColors.errorRed,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              if (osDashboardState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                  child: Text(
                    'Erro OS: ${osDashboardState.errorMessage}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppColors.errorRed,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (orcamentoDashboardState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                  child: Text(
                    'Erro Orçamentos: ${orcamentoDashboardState.errorMessage}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppColors.errorRed,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(osDashboardProvider.notifier).fetchOsDashboardData();
                  ref.read(orcamentoDashboardProvider.notifier).fetchOrcamentoDashboardData();
                },
                icon: Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  'Tentar Novamente',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final DashboardData displayOsData = osDashboardState.data!;
    final DashboardData displayOrcamentoData = orcamentoDashboardState.data!;

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: Stack(
            children: [
              // Elementos decorativos de fundo
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -80,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Conteúdo principal
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabeçalho de boas-vindas
                    _buildWelcomeHeader(),
                    const SizedBox(height: 24),

                    // Cards de estatísticas
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

                    // Ações rápidas
                    QuickActionsWidget(actions: mockQuickActions),
                    const SizedBox(height: 24),

                    // Desempenho de técnicos
                    TechnicianPerformanceWidget(technicians: mockTechnicians),
                    const SizedBox(height: 24),

                    // Atividades recentes
                    RecentActivitiesWidget(activities: mockRecentActivities),

                    // Espaço extra no final para evitar que o conteúdo fique sob a barra de navegação
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildWelcomeHeader() {
    final authState = ref.watch(authProvider);
    final Usuario? adminUser = authState.authenticatedUser;
    final String nome = adminUser?.nome?.split(' ').first ?? 'Usuário';

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(
                adminUser?.cracha != null
                    ? 'https://i.pravatar.cc/150?img=${adminUser!.cracha.hashCode % 20}'
                    : 'https://i.pravatar.cc/150?img=3',
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo, $nome',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Painel de Controle - Nordeste Serviços',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      elevation: 0,
      title: Row(
        children: [
          Image.asset(
            '../assets/images/logo.png', // Caminho da logo
            height: 32,
            color: Colors.white,
          ),
          SizedBox(width: 8),
          Text(
            'OS Manager',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // Ação de notificações
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () {
            // Ação de configurações
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout_outlined, color: Colors.white),
          onPressed: () {
            ref.read(authProvider.notifier).logout();
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'OS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_quote_outlined),
            activeIcon: Icon(Icons.request_quote),
            label: 'Orçamentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Gestão',
          ),
        ],
      ),
    );
  }
}

// Widgets Customizados Redesenhados

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
      elevation: 4,
      shadowColor: AppColors.primaryBlue.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              count.toString(),
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.dividerColor),
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
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.value.toString(),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: item.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionsWidget extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionsWidget({Key? key, required this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.primaryBlue.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações Rápidas',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: actions
                  .map((action) => QuickActionButtonWidget(action: action))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionButtonWidget extends StatelessWidget {
  final QuickAction action;

  const QuickActionButtonWidget({Key? key, required this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(action.rota);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    action.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  action.titulo,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TechnicianPerformanceWidget extends StatelessWidget {
  final List<Technician> technicians;

  const TechnicianPerformanceWidget({Key? key, required this.technicians}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.primaryBlue.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Desempenho por Técnico',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.people_alt_outlined,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...technicians.map((tech) => TechnicianItemWidget(technician: tech)),
          ],
        ),
      ),
    );
  }
}

class TechnicianItemWidget extends StatelessWidget {
  final Technician technician;

  const TechnicianItemWidget({Key? key, required this.technician}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determinar a cor com base no desempenho
    Color performanceColor;
    if (technician.desempenho >= 0.8) {
      performanceColor = AppColors.successGreen;
    } else if (technician.desempenho >= 0.6) {
      performanceColor = AppColors.warningOrange;
    } else {
      performanceColor = AppColors.errorRed;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(technician.avatarUrl),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  technician.nome,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${technician.totalOS} OS atribuídas',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: performanceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(technician.desempenho * 100).toInt()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: performanceColor,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Desempenho',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
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
    return Card(
      elevation: 4,
      shadowColor: AppColors.primaryBlue.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Atividades Recentes',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.history,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...activities.map((activity) => ActivityItemWidget(activity: activity)),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  // Navegar para a página de todas as atividades
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                ),
                child: Text(
                  'Ver todas as atividades',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityItemWidget extends StatelessWidget {
  final Activity activity;

  const ActivityItemWidget({Key? key, required this.activity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData activityIcon;
    Color activityColor;

    // Definir ícone e cor com base no tipo de atividade
    switch (activity.tipo) {
      case 'os_concluida':
        activityIcon = Icons.check_circle_outline;
        activityColor = AppColors.successGreen;
        break;
      case 'cliente_cadastrado':
        activityIcon = Icons.person_add_alt_1;
        activityColor = AppColors.primaryBlue;
        break;
      default:
        activityIcon = Icons.info_outline;
        activityColor = AppColors.textLight;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: activityColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activityColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              activityIcon,
              color: activityColor,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.descricao,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  activity.tempoDecorrido,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textLight,
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
