import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Tela Mais (opções extras)
class MoreScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const MoreScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final sections = [
      _Section(
        title: 'Serviços',
        items: [
          _MenuItem(
            icon: Icons.phone_rounded,
            label: 'Telefones Úteis',
            description: 'Emergências e contatos importantes',
            page: 'services',
          ),
        ],
      ),
      _Section(
        title: 'Transporte',
        items: [
          _MenuItem(
            icon: Icons.directions_bus_rounded,
            label: 'Transporte',
            description: 'Táxi, ônibus e horários',
            page: 'transport',
          ),
        ],
      ),
      _Section(
        title: 'Entretenimento',
        items: [
          _MenuItem(
            icon: Icons.music_note_rounded,
            label: 'Vida Noturna',
            description: 'Bares e eventos noturnos',
            page: 'nightlife',
          ),
        ],
      ),
      _Section(
        title: 'Informações',
        items: [
          _MenuItem(
            icon: Icons.waves_rounded,
            label: 'Tábua de Maré',
            description: 'Horários das marés',
            page: 'tide',
          ),
          _MenuItem(
            icon: Icons.wb_sunny_rounded,
            label: 'Previsão do Tempo',
            description: 'Clima e temperatura',
            page: 'weather',
          ),
        ],
      ),
      _Section(
        title: 'Ferramentas',
        items: [
          _MenuItem(
            icon: Icons.calculate_rounded,
            label: 'Calculadora de Viagem',
            description: 'Estime os custos da sua viagem',
            page: 'calculator',
          ),
        ],
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mais Opções',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Acesse mais funcionalidades do app',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Sections
          ...sections.map((section) => _buildSection(context, section)),

          // Info Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ℹ️', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 12),
                  const Text(
                    'Me Leva Noronha',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seu guia completo para explorar Fernando de Noronha! Encontre informações úteis, serviços e ferramentas para aproveitar ao máximo sua viagem ao paraíso.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, _Section section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text(
            section.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ...section.items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => onNavigate(item.page),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gray100),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: const TextStyle(
                              color: AppColors.gray800,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.description,
                            style: const TextStyle(
                              color: AppColors.gray500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.gray400),
                  ],
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }
}

class _Section {
  final String title;
  final List<_MenuItem> items;

  _Section({required this.title, required this.items});
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String description;
  final String page;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.page,
  });
}







