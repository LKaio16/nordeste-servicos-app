import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';
import '../widgets/whatsapp_button.dart';
import '../core/utils.dart';

/// Tela de Transporte
class TransportScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const TransportScreen({super.key, this.onBack});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> with SingleTickerProviderStateMixin {
  final _apiService = ApiService();
  final _dataService = MockDataService();
  late TabController _tabController;
  String? _origin;
  String? _destination;
  
  List<String> _origins = [];
  List<String> _destinations = [];
  Map<String, dynamic>? _taxiPrice;
  bool _isLoadingOrigins = false;
  bool _isLoadingPrice = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOriginsDestinations();
  }
  
  Future<void> _loadOriginsDestinations() async {
    setState(() {
      _isLoadingOrigins = true;
      _errorMessage = null;
    });
    
    try {
      final response = await _apiService.getTaxiOriginsDestinations();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _origins = List<String>.from(response.data!['origens'] ?? []);
          _destinations = List<String>.from(response.data!['destinos'] ?? []);
          _isLoadingOrigins = false;
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Erro ao carregar locais';
          _isLoadingOrigins = false;
          // Fallback para dados mockados
          final locations = _dataService.getTransportLocations();
          _origins = locations;
          _destinations = locations;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar locais: $e';
        _isLoadingOrigins = false;
        // Fallback para dados mockados
        final locations = _dataService.getTransportLocations();
        _origins = locations;
        _destinations = locations;
      });
    }
  }
  
  Future<void> _calculateTaxiPrice() async {
    if (_origin == null || _destination == null) {
      setState(() {
        _taxiPrice = null;
      });
      return;
    }
    
    setState(() {
      _isLoadingPrice = true;
      _errorMessage = null;
    });
    
    try {
      final response = await _apiService.calculateTaxi(
        origem: _origin!,
        destino: _destination!,
      );
      
      if (response.isSuccess && response.data != null) {
        setState(() {
          _taxiPrice = response.data;
          _isLoadingPrice = false;
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Erro ao calcular preço';
          _taxiPrice = null;
          _isLoadingPrice = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao calcular preço: $e';
        _taxiPrice = null;
        _isLoadingPrice = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busStops = _dataService.getBusStops();

    return Column(
      children: [
        // Header with back button
        if (widget.onBack != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                Text(
                  'Transporte',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),

        // Tab Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.gray600,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_taxi, size: 18),
                      SizedBox(width: 8),
                      Text('Táxi'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_bus, size: 18),
                      SizedBox(width: 8),
                      Text('Ônibus'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Taxi Tab
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Calculator
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.gray100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Calcular Corrida',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gray800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Origin
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Origem',
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              value: _origin,
                              items: _origins.map((loc) {
                                return DropdownMenuItem(value: loc, child: Text(loc));
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _origin = val;
                                  _taxiPrice = null;
                                });
                                _calculateTaxiPrice();
                              },
                            ),
                            const SizedBox(height: 12),

                            // Destination
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Destino',
                                prefixIcon: Icon(Icons.flag),
                              ),
                              value: _destination,
                              items: _destinations.map((loc) {
                                return DropdownMenuItem(value: loc, child: Text(loc));
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _destination = val;
                                  _taxiPrice = null;
                                });
                                _calculateTaxiPrice();
                              },
                            ),
                            
                            if (_isLoadingPrice) ...[
                              const SizedBox(height: 20),
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ],

                            if (_taxiPrice != null) ...[
                              const SizedBox(height: 20),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final cardWidth = (constraints.maxWidth - 12) / 2;
                                  final fontSize = cardWidth < 120 ? 20.0 : 28.0;
                                  
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            gradient: AppColors.primaryGradient,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Tarifa 1',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.8),
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'R\$ ${(_taxiPrice!['valorTabela1'] ?? 0.0).toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: fontSize,
                                                    fontWeight: FontWeight.bold,
                                                  ),
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
                                              colors: [AppColors.accent, AppColors.accent.withOpacity(0.8)],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Tarifa 2',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.8),
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'R\$ ${(_taxiPrice!['valorTabela2'] ?? 0.0).toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: fontSize,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                            
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Call Taxi
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: WhatsAppButton(
                        text: 'Chamar Táxi',
                        subtext: 'Grupo WhatsApp - Frota de Táxis',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.local_taxi, color: AppColors.primary),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Informações',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.gray800,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '• Táxis identificados pela prefeitura\n'
                                    '• Valores tabelados oficiais\n'
                                    '• Tarifa noturna: 20h às 6h (+50%)\n'
                                    '• Pagamento em dinheiro ou PIX\n'
                                    '• Disponível 24 horas',
                                    style: TextStyle(
                                      color: AppColors.gray700,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
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

              // Bus Tab
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Bus Info
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
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.directions_bus, color: Colors.white, size: 28),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  'Informações do Ônibus',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '• Tarifa: R\$ 5,00 por trecho\n'
                              '• Aceita apenas dinheiro\n\n'
                              'O ônibus de Fernando de Noronha funciona das 07h às 22h, com saídas a cada 30 minutos. 🚍\n\n'
                              'Existem duas rotas:\n'
                              '• Ônibus Sueste: sai da Praia do Porto em direção à Praia do Sueste.\n'
                              '• Ônibus Porto: faz o caminho inverso.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Map PDF button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: () => AppUtils.showSnackBar(context, 'PDF em desenvolvimento'),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.map, color: Colors.white, size: 40),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Mapa dos Pontos de Ônibus (PDF)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Visualize todos os pontos de ônibus',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bus Stops
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.gray100),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Pontos de Ônibus',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...busStops.asMap().entries.map((entry) {
                              final index = entry.key;
                              final stop = entry.value;
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.gray50,
                                  border: index < busStops.length - 1
                                      ? Border(bottom: BorderSide(color: AppColors.gray200))
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            stop['name']!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.gray800,
                                            ),
                                          ),
                                          Text(
                                            'Primeiro horário: ${stop['time']}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.gray500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.location_on, color: AppColors.primary),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}







