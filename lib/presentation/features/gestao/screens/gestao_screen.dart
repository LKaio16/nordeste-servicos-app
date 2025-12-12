import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nordeste_servicos_app/presentation/features/equipamentos/screens/equipamento_list_screen.dart';
import 'package:nordeste_servicos_app/presentation/features/funcionario/screens/funcionario_list_screen.dart';
import 'package:nordeste_servicos_app/presentation/features/funcionario/screens/novo_tecnico_screen.dart';
import 'package:nordeste_servicos_app/presentation/features/servicos/screens/novo_tipo_servico_screen.dart';
import 'package:nordeste_servicos_app/presentation/features/recibos/screens/recibo_list_screen.dart';
import 'package:nordeste_servicos_app/presentation/features/recibos/screens/novo_recibo_screen.dart';
import '../../clientes/screens/cliente_list_screen.dart';
import '../../clientes/screens/novo_cliente_screen.dart';
import '../../equipamentos/screens/novo_equipamento_screen.dart';
import '../../pecas/screens/nova_peca_material_screen.dart';
import '../../pecas/screens/peca_material_list_screen.dart';
import '../../servicos/screens/tipo_servico_list_screen.dart';
import '../../../shared/styles/app_colors.dart';

class GestaoScreen extends StatelessWidget {
  const GestaoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void navigateTo(Widget screen) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: Stack(
        children: [
          // Elementos decorativos de fundo
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.6,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.warningOrange.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Conteúdo principal
          SafeArea(
            child: Column(
              children: [
                // Cabeçalho da seção
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryBlue,
                              AppColors.secondaryBlue,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.dashboard_outlined,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Painel de Gestão',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Gerencie todos os recursos do sistema',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de cards
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    children: [
                      ManagementCard(
                        icon: Icons.people_outline,
                        title: 'Clientes',
                        subtitle: 'Gerenciar cadastros de clientes',
                        color: AppColors.primaryBlue,
                        onCardTap: () => navigateTo(const ClienteListScreen()),
                        onAddButtonTap: () => navigateTo(const NovoClienteScreen()),
                      ),
                      const SizedBox(height: 16),
                      ManagementCard(
                        icon: Icons.build_outlined,
                        title: 'Equipamentos',
                        subtitle: 'Gerenciar cadastros de equipamentos',
                        color: AppColors.secondaryBlue,
                        onCardTap: () => navigateTo(const EquipamentoListScreen()),
                        onAddButtonTap: () => navigateTo(const NovoEquipamentoScreen()),
                      ),
                      const SizedBox(height: 16),
                      ManagementCard(
                        icon: Icons.person_outline,
                        title: 'Funcionários',
                        subtitle: 'Gerenciar cadastros de técnicos',
                        color: AppColors.successGreen,
                        onCardTap: () => navigateTo(const FuncionarioListScreen()),
                        onAddButtonTap: () => navigateTo(const NovoTecnicoScreen()),
                      ),
                      const SizedBox(height: 16),
                      ManagementCard(
                        icon: Icons.construction_outlined,
                        title: 'Peças/Materiais',
                        subtitle: 'Gerenciar estoque de peças',
                        color: AppColors.warningOrange,
                        onCardTap: () => navigateTo(const PecasListScreen()),
                        onAddButtonTap: () => navigateTo(const NovaPecaScreen()),
                      ),
                      const SizedBox(height: 16),
                      ManagementCard(
                        icon: Icons.miscellaneous_services_outlined,
                        title: 'Serviços',
                        subtitle: 'Gerenciar tipos de serviços',
                        color: AppColors.darkBlue,
                        onCardTap: () => navigateTo(const ServicosListScreen()),
                        onAddButtonTap: () => navigateTo(const NovoTipoServicoScreen()),
                      ),
                      const SizedBox(height: 16),
                      ManagementCard(
                        icon: Icons.receipt_long_outlined,
                        title: 'Recibos',
                        subtitle: 'Gerenciar recibos de pagamento',
                        color: AppColors.successGreen,
                        onCardTap: () => navigateTo(const RecibosListScreen()),
                        onAddButtonTap: () => navigateTo(const NovoReciboScreen()),
                      ),
                      const SizedBox(height: 20),
                    ],
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

class ManagementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onCardTap;
  final VoidCallback onAddButtonTap;

  const ManagementCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onCardTap,
    required this.onAddButtonTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onCardTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: color.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: onAddButtonTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

