import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../widgets/cached_image.dart';
import '../widgets/whatsapp_button.dart';

/// Tela inicial do app
class HomeScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo ao',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.gray800,
                  ),
                ),
                const Text(
                  'Me Leva Noronha',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Hero Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const CachedImage(
                      imageUrl: AppConstants.heroImageUrl,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Descubra o Paraíso',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fernando de Noronha com facilidade e conforto',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions
          _buildSectionTitle(context, 'Acesso Rápido'),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _QuickActionCard(
                  icon: Icons.flight_rounded,
                  label: 'Passeios',
                  onTap: () => onNavigate('tours'),
                ),
                _QuickActionCard(
                  icon: Icons.waves_rounded,
                  label: 'Tábua de Maré',
                  onTap: () => onNavigate('tide'),
                ),
                _QuickActionCard(
                  icon: Icons.wb_sunny_rounded,
                  label: 'Previsão',
                  onTap: () => onNavigate('weather'),
                ),
                _QuickActionCard(
                  icon: Icons.calculate_rounded,
                  label: 'Calculadora de Viagem',
                  onTap: () => onNavigate('calculator'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Dicas Section
          _buildSectionHeader(context, 'Dicas', () => onNavigate('articles')),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _ArticleCard(
                  imageUrl: 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05',
                  title: 'Como chegar em Fernando de Noronha',
                  subtitle: 'Descubra as melhores formas de chegar ao paraíso',
                  onTap: () => onNavigate('articles'),
                ),
                const SizedBox(height: 12),
                _ArticleCard(
                  imageUrl: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19',
                  title: 'Melhores praias de Noronha',
                  subtitle: 'Conheça as praias mais paradisíacas da ilha',
                  onTap: () => onNavigate('articles'),
                ),
                const SizedBox(height: 12),
                _ArticleCard(
                  imageUrl: 'https://images.unsplash.com/photo-1488646953014-85cb44e25828',
                  title: 'Dicas essenciais para sua viagem',
                  subtitle: 'Tudo que você precisa saber antes de viajar',
                  onTap: () => onNavigate('articles'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Todos os Serviços
          _buildSectionTitle(context, 'Todos os Serviços'),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _ServiceCard(
                  icon: Icons.menu_book_rounded,
                  label: 'Dicas',
                  description: 'Tudo sobre a ilha',
                  onTap: () => onNavigate('articles'),
                ),
                const SizedBox(height: 8),
                _ServiceCard(
                  icon: Icons.directions_car_rounded,
                  label: 'Aluguel de Veículos',
                  description: 'Carros, motos e buggies',
                  onTap: () => onNavigate('rental'),
                ),
                const SizedBox(height: 8),
                _ServiceCard(
                  icon: Icons.map_rounded,
                  label: 'Mapa da Ilha',
                  description: 'Pontos turísticos',
                  onTap: () => onNavigate('map'),
                ),
                const SizedBox(height: 8),
                _ServiceCard(
                  icon: Icons.directions_bus_rounded,
                  label: 'Transporte',
                  description: 'Táxi e ônibus',
                  onTap: () => onNavigate('transport'),
                ),
                const SizedBox(height: 8),
                _ServiceCard(
                  icon: Icons.phone_rounded,
                  label: 'Telefones Úteis',
                  description: 'Emergências e contatos',
                  onTap: () => onNavigate('services'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // WhatsApp Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: WhatsAppButton(
              text: 'Fale Conosco no WhatsApp',
              subtext: 'Entre em contato com a Me Leva Noronha',
            ),
          ),

          const SizedBox(height: 100), // Espaço para bottom nav
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.gray800,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.gray800,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: const Text('Ver todos'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ArticleCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray100),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: SizedBox(
                  width: 100,
                  height: double.infinity,
                  child: CachedImage(imageUrl: imageUrl),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.gray800,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Flexible(
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppColors.gray500,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
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
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.gray800,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.gray500,
                        fontSize: 12,
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
    );
  }
}







