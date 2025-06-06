// admin_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nordeste_servicos_app/presentation/features/dashboard/screens/dashboard_page_adm.dart';
import 'package:nordeste_servicos_app/presentation/features/gestao/screens/gestao_screen.dart';
import 'package:nordeste_servicos_app/presentation/features/orcamentos/screens/orcamento_list_screen.dart';
import 'package:nordeste_servicos_app/presentation/features/os/screens/os_list_screen.dart';

// Importe seus providers, entidades, cores, etc.
import '../../../../domain/entities/usuario.dart';
import '../../../shared/providers/navigation_providers.dart';
import '../../auth/providers/auth_provider.dart';
// Importe o provider da lista de OS para poder disparar o carregamento
import '../../os/providers/os_list_provider.dart';


// Definição de AppColors (mantenha como está no seu projeto)
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

// Tela Principal Refatorada - AGORA É UM ConsumerWidget
class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  // Lista das páginas correspondentes a cada aba do menu
  final List<Widget> _pages = const [
    DashboardPageAdm(),      // Índice 0
    OsListScreen(),           // Índice 1
    OrcamentosListScreen(),   // Índice 2
    GestaoScreen(),           // Índice 3
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lê o índice atual do provider de navegação
    final selectedIndex = ref.watch(mainNavigationIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      // A AppBar agora é construída por um método separado que recebe ref
      appBar: _buildAppBar(context, ref),
      body: SafeArea(
        child: Stack(
          children: [
            // Elementos decorativos de fundo (mantidos do original)
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

            // *** ALTERAÇÃO PRINCIPAL: IndexedStack ***
            // Exibe a página correspondente ao índice selecionado,
            // mantendo o estado das outras páginas.
            IndexedStack(
              index: selectedIndex, // Usa o índice do provider
              children: _pages,      // Lista das suas páginas
            ),
          ],
        ),
      ),
      // O BottomNavigationBar agora é construído por um método que recebe ref
      bottomNavigationBar: _buildBottomNavigationBar(context, ref),
    );
  }

  // Método para construir a AppBar (adaptado do original)
  AppBar _buildAppBar(BuildContext context, WidgetRef ref) {
    // Acessa o estado de autenticação para obter dados do usuário
    final authState = ref.watch(authProvider);
    final Usuario? adminUser = authState.authenticatedUser;

    return AppBar(
      title: Text(
        'Admin Portal',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
      ),
      backgroundColor: AppColors.primaryBlue,
      elevation: 2,
      automaticallyImplyLeading: false, // Remove botão voltar se for tela principal
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Sair',
          onPressed: () {
            // Chama a função de logout do authProvider
            ref.read(authProvider.notifier).logout();
            // Adicione a navegação para a tela de login após o logout
            // Ex: Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withOpacity(0.9),
            child: CircleAvatar(
              radius: 16,
              // Usa uma imagem padrão ou baseada em dados do usuário
              backgroundImage: NetworkImage(
                adminUser?.cracha != null
                    ? 'https://i.pravatar.cc/150?img=${adminUser!.cracha.hashCode % 20}' // Exemplo
                    : 'https://i.pravatar.cc/150?u=admin', // Fallback
              ),
              onBackgroundImageError: (_, __) {}, // Tratamento de erro básico
            ),
          ),
        ),
      ],
    );
  }

  // Método para construir o BottomNavigationBar (adaptado do original)
  Widget _buildBottomNavigationBar(BuildContext context, WidgetRef ref) {
    // Lê o índice atual do provider de navegação
    final selectedIndex = ref.watch(mainNavigationIndexProvider);

    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_outlined),
          activeIcon: Icon(Icons.list_alt),
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
      currentIndex: selectedIndex, // Define a aba ativa com base no provider
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.textLight,
      backgroundColor: AppColors.cardBackground,
      type: BottomNavigationBarType.fixed, // Garante que todos os labels apareçam
      elevation: 8.0,
      selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
      onTap: (index) {
        // Atualiza o estado do provider quando uma aba é tocada
        ref.read(mainNavigationIndexProvider.notifier).state = index;

        // Se a aba de 'OS' (índice 1) for selecionada, recarrega as Ordens de Serviço
        if (index == 1) {
          ref.read(osListProvider.notifier).loadOrdensServico(refresh: true);
        }
      },
    );
  }
}