import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../core/utils.dart';
import '../widgets/whatsapp_button.dart';

/// Tela de Telefones Úteis / Serviços
class ServicesScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const ServicesScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with back button
        if (onBack != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                Text(
                  'Telefones Úteis',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emergency Services
                _buildSectionHeader(context, 'Emergências', Icons.warning_rounded),
                _EmergencyCard(
                  name: 'SAMU - Emergência Médica',
                  phone: '192',
                  icon: Icons.medical_services,
                  colors: [Colors.red.shade500, Colors.red.shade600],
                ),
                _EmergencyCard(
                  name: 'Polícia Militar',
                  phone: '190',
                  icon: Icons.shield,
                  colors: [Colors.blue.shade700, Colors.blue.shade800],
                ),
                _EmergencyCard(
                  name: 'Corpo de Bombeiros',
                  phone: '193',
                  icon: Icons.local_fire_department,
                  colors: [Colors.red.shade600, Colors.red.shade700],
                ),

                // Health
                _buildSectionHeader(context, 'Saúde', Icons.favorite),
                _ServiceContactCard(name: 'Hospital São Lucas', phone: '(81) 3619-1477'),
                _ServiceContactCard(name: 'Farmácia Central', phone: '(81) 3619-1234'),

                // Administration
                _buildSectionHeader(context, 'Administração', Icons.business),
                _ServiceContactCard(name: 'Administração da Ilha', phone: '(81) 3619-1100'),
                _ServiceContactCard(name: 'ICMBio - PARNAMAR', phone: '(81) 3619-1171'),
                _ServiceContactCard(name: 'Aeroporto', phone: '(81) 3619-1444'),

                // Tourism
                _buildSectionHeader(context, 'Turismo', Icons.location_on),
                _ServiceContactCard(name: 'Centro de Visitantes', phone: '(81) 3619-1352'),
                _ServiceContactCard(name: 'Projeto Tamar', phone: '(81) 3619-1171'),

                // Gas Station
                _buildSectionHeader(context, 'Posto de Gasolina', Icons.local_gas_station),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Posto Noronha',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(icon: Icons.location_on, text: 'BR-363, Vila dos Remédios'),
                        const SizedBox(height: 8),
                        _InfoRow(icon: Icons.schedule, text: 'Segunda a Sábado: 07:00 - 18:00'),
                        const SizedBox(height: 8),
                        _InfoRow(icon: Icons.schedule, text: 'Domingo: 08:00 - 12:00'),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Único posto da ilha - Abasteça com antecedência!',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Me Leva Noronha Contact
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: WhatsAppButton(
                    text: 'Me Leva Noronha',
                    subtext: 'Entre em contato conosco',
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondaryBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  final String name;
  final String phone;
  final IconData icon;
  final List<Color> colors;

  const _EmergencyCard({
    required this.name,
    required this.phone,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => AppUtils.makePhoneCall(phone),
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          phone,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.phone, color: Colors.white, size: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceContactCard extends StatelessWidget {
  final String name;
  final String phone;

  const _ServiceContactCard({
    required this.name,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => AppUtils.makePhoneCall(phone),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gray100),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phone,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.phone, color: AppColors.primary, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}







