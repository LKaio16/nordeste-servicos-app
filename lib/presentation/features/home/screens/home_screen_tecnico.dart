import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nordeste_servicos_app/presentation/features/os-tec/screens/minhas_os_list_screen.dart';

// Importe as telas que serão usadas nas abas
import 'package:nordeste_servicos_app/presentation/features/orcamentos/screens/orcamento_list_screen.dart';

// Importe os providers necessários
import '../../../perfil/screens/perfil_screen.dart';
import '../../../shared/providers/navigation_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../../domain/entities/usuario.dart';

class TecnicoHomeScreen extends ConsumerStatefulWidget {
  const TecnicoHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TecnicoHomeScreen> createState() => _TecnicoHomeScreenState();
}

class _TecnicoHomeScreenState extends ConsumerState<TecnicoHomeScreen> {
  late final PageController _pageController;

  // Lista de páginas para a navegação do técnico
  final List<Widget> _pages = const [
    MinhasOsListScreen(),       // Índice 0
    OrcamentosListScreen(),     // Índice 1
    PerfilScreen(),             // Índice 2
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: ref.read(tecnicoNavigationIndexProvider));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(tecnicoNavigationIndexProvider);

    ref.listen<int>(tecnicoNavigationIndexProvider, (previous, next) {
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
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          children: _pages,
          onPageChanged: (index) {
            ref.read(tecnicoNavigationIndexProvider.notifier).state = index;
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, selectedIndex),
    );
  }

  // **MODIFICADO** - Método para exibir o diálogo de confirmação de logout
  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // O usuário deve tocar em um botão
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
                Navigator.of(dialogContext).pop(); // Fecha o diálogo
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

  AppBar _buildAppBar(BuildContext context) {
    final authState = ref.watch(authProvider);
    final Usuario? tecnicoUser = authState.authenticatedUser;

    // **NOVO** - Lógica para decodificar a imagem em Base64
    Uint8List? imageBytes;
    if (tecnicoUser?.fotoPerfil != null && tecnicoUser!.fotoPerfil!.isNotEmpty) {
      try {
        imageBytes = base64Decode(tecnicoUser.fotoPerfil!);
      } catch (e) {
        print("Erro ao decodificar imagem do técnico na AppBar: $e");
        imageBytes = null;
      }
    }

    return AppBar(
      title: Text(
        'Portal do Técnico',
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
            // **MODIFICADO** - Chama o diálogo de confirmação
            _showLogoutConfirmationDialog(context);
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withOpacity(0.9),
            child: CircleAvatar(
              radius: 16,
              // **MODIFICADO** - Usa a imagem decodificada ou um ícone de fallback
              backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
              child: imageBytes == null
                  ? const Icon(Icons.engineering, size: 20, color: AppColors.primaryBlue)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, int selectedIndex) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_outlined),
          activeIcon: Icon(Icons.list_alt),
          label: 'Minhas OS',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.request_quote_outlined),
          activeIcon: Icon(Icons.request_quote),
          label: 'Orçamentos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
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
        // Apenas atualiza o estado. O listener cuidará da animação.
        ref.read(tecnicoNavigationIndexProvider.notifier).state = index;
      },
    );
  }
}