import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Importe seus providers, entidades, cores, etc.
import '../../../../domain/entities/usuario.dart';
import '../../auth/providers/auth_provider.dart';
import '../../orcamentos/providers/orcamento_dashboard_provider.dart';
import '../models/dashboard_data.dart';
import '../providers/os_dashboard_data_provider.dart';

// Definição de AppColors (Copie do seu arquivo original ou importe)
class AppColors {
  static const Color primaryBlue = Color(0xFF1A73E8);
  static const Color secondaryBlue = Color(0xFF4285F4);
  static const Color accentBlue = Color(0xFF8AB4F8);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color successGreen = Color(0xFF34A853);
  static const Color warningOrange = Color(0xFFFFA000);
  static const Color errorRed = Color(0xFFEA4335);
  static const Color backgroundGray = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;
  static const Color textDark = Color(0xFF202124);
  static const Color textLight = Color(0xFF5F6368);
  static const Color dividerColor = Color(0xFFEEEEEE);
}

// Modelos de Dados (Copie do seu arquivo original ou importe)
class StatusItem { /* ... Definição ... */
  final String label;
  final int value;
  final Color color;
  StatusItem({required this.label, required this.value, required this.color});
}
class QuickAction { /* ... Definição ... */
  final String titulo;
  final IconData icon;
  final String rota;
  QuickAction({required this.titulo, required this.icon, required this.rota});
}
class Technician { /* ... Definição ... */
  final String id;
  final String nome;
  final String avatarUrl;
  final int totalOS;
  final double desempenho;
  Technician({required this.id, required this.nome, required this.avatarUrl, required this.totalOS, required this.desempenho});
}
class Activity { /* ... Definição ... */
  final String tipo;
  final String descricao;
  final String tempoDecorrido;
  Activity({required this.tipo, required this.descricao, required this.tempoDecorrido});
}

// Dados Mocados (Copie do seu arquivo original ou importe)
final List<QuickAction> mockQuickActions = [ /* ... Definição ... */
  QuickAction(titulo: 'Nova OS', icon: Icons.add_chart, rota: '/nova-os'),
  QuickAction(titulo: 'Add Cliente', icon: Icons.person_add_outlined, rota: '/novo-cliente'),
  QuickAction(titulo: 'Add Técnico', icon: Icons.engineering, rota: '/novo-tec'),
];
final List<Technician> mockTechnicians = [ /* ... Definição ... */
  Technician(id: '1', nome: 'Carlos Silva', avatarUrl: 'https://i.pravatar.cc/150?img=12', totalOS: 32, desempenho: 0.8),
  Technician(id: '2', nome: 'Pedro Santos', avatarUrl: 'https://i.pravatar.cc/150?img=11', totalOS: 28, desempenho: 0.7),
];
final List<Activity> mockRecentActivities = [ /* ... Definição ... */
  Activity(tipo: 'os_concluida', descricao: 'OS #2547 concluída', tempoDecorrido: 'Há 2 horas'),
  Activity(tipo: 'cliente_cadastrado', descricao: 'Novo cliente cadastrado', tempoDecorrido: 'Há 4 horas'),
];

// Página do Dashboard - AGORA COM O CONTEÚDO REAL
class DashboardPageAdm extends ConsumerWidget {
  const DashboardPageAdm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lê os providers necessários para os dados do dashboard
    final osDashboardState = ref.watch(osDashboardProvider);
    final orcamentoDashboardState = ref.watch(orcamentoDashboardProvider);

    // Lógica de Loading e Error (mantida da AdminHomeScreen original)
    if (osDashboardState.isLoading || orcamentoDashboardState.isLoading) {
      return const Center(
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
              style: TextStyle(fontSize: 16, color: AppColors.textDark),
            ),
          ],
        ),
      );
    }

    if (osDashboardState.errorMessage != null || orcamentoDashboardState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
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
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                'Tentar Novamente',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      );
    }

    // Se chegou aqui, os dados foram carregados com sucesso
    final DashboardData displayOsData = osDashboardState.data!;
    final DashboardData displayOrcamentoData = orcamentoDashboardState.data!;

    // Conteúdo principal do dashboard (movido da AdminHomeScreen original)
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho de boas-vindas
          _buildWelcomeHeader(ref),
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

          // Espaço extra no final
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Método auxiliar para o cabeçalho (movido da AdminHomeScreen original)
  Widget _buildWelcomeHeader(WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final Usuario? adminUser = authState.authenticatedUser;
    final String nome = adminUser?.nome?.split(' ').first ?? 'Admin'; // Usar 'Admin' como fallback

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                    ? 'https://i.pravatar.cc/150?img=${adminUser!.cracha.hashCode % 20}' // Exemplo
                    : 'https://i.pravatar.cc/150?u=admin', // Fallback
              ),
              onBackgroundImageError: (_, __) {}, // Tratamento de erro básico
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo, $nome!',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Painel Administrativo Nordeste Serviços',
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
}

// ----- Widgets Internos (Copie as definições do seu arquivo original ou importe) -----
// É ALTAMENTE RECOMENDADO MOVER ESTES WIDGETS PARA ARQUIVOS SEPARADOS

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
      elevation: 3,
      shadowColor: AppColors.primaryBlue.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Icon(icon, color: AppColors.primaryBlue, size: 28),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.dividerColor, height: 1),
            const SizedBox(height: 12),
            Column(
              children: statusItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.label}:',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textLight,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.value.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionsWidget extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionsWidget({Key? key, required this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1, // Ajuste para melhor visualização
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(action.rota);
              },
              borderRadius: BorderRadius.circular(12),
              child: Card(
                elevation: 2,
                color: AppColors.primaryBlue,
                shadowColor: AppColors.primaryBlue.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(action.icon, size: 32, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      action.titulo,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
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

