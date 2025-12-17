import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../core/utils.dart';

/// Drawer lateral do app
class AppDrawer extends StatelessWidget {
  final String currentPage;
  final Function(String) onNavigate;

  const AppDrawer({
    super.key,
    required this.currentPage,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem(id: 'home', label: 'Me Leva Noronha', icon: Icons.home_rounded),
      _MenuItem(id: 'articles', label: 'Dicas e Artigos', icon: Icons.menu_book_rounded),
      _MenuItem(id: 'tours', label: 'Passeios', icon: Icons.sailing_rounded),
      _MenuItem(id: 'map', label: 'Mapa da Ilha', icon: Icons.map_rounded),
      _MenuItem(id: 'tide', label: 'Tábua de Maré', icon: Icons.waves_rounded),
      _MenuItem(id: 'weather', label: 'Previsão do Tempo', icon: Icons.cloud_rounded),
      _MenuItem(id: 'transport', label: 'Transporte', icon: Icons.directions_bus_rounded),
      _MenuItem(id: 'services', label: 'Telefones Úteis', icon: Icons.phone_rounded),
      _MenuItem(id: 'nightlife', label: 'Vida Noturna', icon: Icons.music_note_rounded),
      _MenuItem(id: 'calculator', label: 'Calculadora de Viagem', icon: Icons.calculate_rounded),
    ];

    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/Logo Logomarca Me Leva Noronha.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback para ícone se a imagem não carregar
                      return const Icon(
                        Icons.flight_rounded,
                        color: AppColors.primary,
                        size: 28,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Me Leva Noronha',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seu guia completo',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Menu items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = currentPage == item.id;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Material(
                    color: isSelected ? AppColors.secondaryBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        onNavigate(item.id);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected ? AppColors.primary : AppColors.gray500,
                              size: 22,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  color: isSelected ? AppColors.primary : AppColors.gray700,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Footer - WhatsApp button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              top: false,
              child: Material(
                color: AppColors.whatsappGreen,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    AppUtils.openWhatsApp();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Fale Conosco',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final String id;
  final String label;
  final IconData icon;

  _MenuItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}

