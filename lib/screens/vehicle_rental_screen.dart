import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/mock_data_service.dart';
import '../widgets/cached_image.dart';
import '../core/utils.dart';

/// Tela de Aluguel de Veículos
class VehicleRentalScreen extends StatelessWidget {
  final VoidCallback? onBack;

  VehicleRentalScreen({super.key, this.onBack});

  final _dataService = MockDataService();

  @override
  Widget build(BuildContext context) {
    final vehicles = _dataService.getVehicles();
    final cars = _dataService.getCarRentals();

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
                  'Aluguel de Veículos',
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
                // Vehicles
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.gray100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  child: SizedBox(
                                    height: 180,
                                    width: double.infinity,
                                    child: CachedImage(imageUrl: vehicle.imageUrl),
                                  ),
                                ),
                                Container(
                                  height: 180,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                                    ),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.95),
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Text(vehicle.icon, style: const TextStyle(fontSize: 28)),
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: _getVehicleGradient(index),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      vehicle.price,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vehicle.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.gray800,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...vehicle.features.map((feature) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.check, size: 14, color: Colors.green.shade600),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          feature,
                                          style: const TextStyle(
                                            color: AppColors.gray600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () => AppUtils.openWhatsApp(
                                      message: 'Olá! Gostaria de alugar ${vehicle.name} em Fernando de Noronha',
                                    ),
                                    icon: const Icon(Icons.phone, size: 18),
                                    label: const Text('Reservar Agora'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.whatsappGreen,
                                      minimumSize: const Size(double.infinity, 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Cars Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '🚗 Carros Fechados',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 12),
                
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.gray100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: _getCarGradient(index),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                car.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              car.models,
                              style: const TextStyle(
                                color: AppColors.gray600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.green.shade50, Colors.teal.shade50],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.green.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '💳 PIX',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          car.pricePix,
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                        Text(
                                          'à vista',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.green.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.blue.shade50, Colors.cyan.shade50],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.blue.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '💳 Cartão',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          car.priceCard,
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                        Text(
                                          car.installments,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.blue.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => AppUtils.openWhatsApp(
                                message: 'Olá! Gostaria de consultar disponibilidade de ${car.category}',
                              ),
                              icon: const Icon(Icons.phone, size: 18),
                              label: const Text('Consultar Disponibilidade'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Documents Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        const Text('📋', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Documentos Necessários',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...[
                                'CNH válida (categoria adequada ao veículo)',
                                'RG e CPF',
                                'Comprovante de residência',
                                'Cartão de crédito para caução',
                              ].map((doc) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.check, size: 14, color: Colors.blue.shade600),
                                    const SizedBox(width: 8),
                                    Text(
                                      doc,
                                      style: TextStyle(
                                        color: Colors.blue.shade800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade500, Colors.red.shade500],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 12),
                        const Text(
                          'Dicas Importantes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• Reserve com antecedência na alta temporada\n'
                          '• Combustível por conta do locatário\n'
                          '• Único posto abre até 18h (dias de semana)\n'
                          '• Respeite os limites de velocidade (máx. 40 km/h)\n'
                          '• Atenção aos animais na pista',
                          style: TextStyle(
                            color: Colors.orange.shade50,
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
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

  LinearGradient _getVehicleGradient(int index) {
    final gradients = [
      LinearGradient(colors: [Colors.green.shade500, Colors.teal.shade600]),
      LinearGradient(colors: [Colors.orange.shade500, Colors.red.shade600]),
      LinearGradient(colors: [Colors.blue.shade500, Colors.cyan.shade600]),
    ];
    return gradients[index % gradients.length];
  }

  LinearGradient _getCarGradient(int index) {
    final gradients = [
      LinearGradient(colors: [Colors.blue.shade500, Colors.blue.shade600]),
      LinearGradient(colors: [Colors.purple.shade500, Colors.purple.shade600]),
      LinearGradient(colors: [Colors.indigo.shade600, Colors.purple.shade600]),
    ];
    return gradients[index % gradients.length];
  }
}

