import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nordeste_servicos_app/presentation/features/dashboard/providers/desempenho_tecnico_provider.dart';
import 'package:nordeste_servicos_app/presentation/features/dashboard/screens/dashboard_page_adm.dart';
import 'package:nordeste_servicos_app/presentation/features/gestao/screens/gestao_screen.dart';
import 'package:nordeste_servicos_app/presentation/features/orcamentos/providers/orcamento_dashboard_provider.dart';
import 'package:nordeste_servicos_app/presentation/features/orcamentos/screens/orcamento_list_screen.dart';
import 'package:nordeste_servicos_app/presentation/features/os/screens/os_list_screen.dart';

import '../../../../domain/entities/usuario.dart';
import '../../../shared/providers/navigation_providers.dart';
import '../../../shared/styles/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/os_dashboard_data_provider.dart';
import '../../os/providers/os_list_provider.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  late final PageController _pageController;

  final List<Widget> _pages = const [
    DashboardPageAdm(),
    OsListScreen(),
    OrcamentosListScreen(),
    GestaoScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Inicializa o PageController com a página inicial do provider
    _pageController = PageController(initialPage: ref.read(mainNavigationIndexProvider));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context, WidgetRef ref) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.logout, color: AppColors.primaryBlue),
              const SizedBox(width: 10),
              Text(
                'Confirmar Saída',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Text(
            'Você tem certeza que deseja sair do aplicativo?',
            style: GoogleFonts.poppins(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(color: AppColors.textLight),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Sair',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Opcional: Redefinir para a primeira aba ao sair
                if (_pageController.hasClients) {
                  _pageController.jumpToPage(0);
                }
                ref.read(authProvider.notifier).logout();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(mainNavigationIndexProvider);

    // Escuta as mudanças no provider para animar o PageView
    ref.listen<int>(mainNavigationIndexProvider, (previous, next) {
      if (next != previous && _pageController.hasClients && _pageController.page?.round() != next) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(context, ref),
      body: SafeArea(
        child: Stack(
          children: [
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
            PageView(
              controller: _pageController,
              children: _pages,
              onPageChanged: (index) {
                // Ao deslizar, atualiza o provider.
                // Isso fará o BottomNavigationBar atualizar seu estado.
                ref.read(mainNavigationIndexProvider.notifier).state = index;
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, ref, selectedIndex),
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final Usuario? adminUser = authState.authenticatedUser;

    Uint8List? imageBytes;
    if (adminUser?.fotoPerfil != null && adminUser!.fotoPerfil!.isNotEmpty) {
      try {
        imageBytes = base64Decode(adminUser.fotoPerfil!);
      } catch (e) {
        print("Erro ao decodificar imagem do admin na AppBar: $e");
        imageBytes = null;
      }
    }

    return AppBar(
      title: Text(
        'Admin Portal',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
      ),
      backgroundColor: AppColors.primaryBlue,
      elevation: 2,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Sair',
          onPressed: () {
            _showLogoutConfirmationDialog(context, ref);
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withOpacity(0.9),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
              child: imageBytes == null
                  ? const Icon(Icons.admin_panel_settings, size: 20, color: AppColors.primaryBlue)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, WidgetRef ref, int selectedIndex) {
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
      currentIndex: selectedIndex,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.textLight,
      backgroundColor: AppColors.cardBackground,
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
      selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
      onTap: (index) {
        if (index == 0) {
          ref.invalidate(osDashboardProvider);
          ref.invalidate(orcamentoDashboardProvider);
          ref.invalidate(desempenhoTecnicoProvider);
        }
        // Apenas atualiza o estado. O listener cuidará da animação.
        ref.read(mainNavigationIndexProvider.notifier).state = index;
      },
    );
  }
}
