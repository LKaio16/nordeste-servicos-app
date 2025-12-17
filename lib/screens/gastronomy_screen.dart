import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/restaurant.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';
import '../widgets/cached_image.dart';
import '../widgets/pdf_viewer.dart';
import '../core/utils.dart';
import '../config/app_constants.dart';

/// Tela de Gastronomia
class GastronomyScreen extends StatefulWidget {
  const GastronomyScreen({super.key});

  @override
  State<GastronomyScreen> createState() => _GastronomyScreenState();
}

class _GastronomyScreenState extends State<GastronomyScreen> {
  final _apiService = ApiService();
  final _mockDataService = MockDataService();
  String _priceFilter = 'all';
  
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarRestaurantes();
  }

  Future<void> _carregarRestaurantes() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('GastronomyScreen: Iniciando carregamento de restaurantes...');
      
      // Carrega todos os restaurantes (sem filtro)
      final response = await _apiService.getRestaurants();
      debugPrint('GastronomyScreen: Resposta recebida - success: ${response.isSuccess}');
      
      if (!mounted) return;
      
      if (response.isSuccess && response.data != null) {
        debugPrint('GastronomyScreen: Dados recebidos: ${response.data}');
        final restaurantes = (response.data as List)
            .map((json) => Restaurant.fromApiJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('GastronomyScreen: ${restaurantes.length} restaurantes carregados');
        setState(() {
          _restaurants = restaurantes;
          _isLoading = false;
        });
      } else {
        debugPrint('GastronomyScreen: Erro - ${response.error}');
        // Se falhar, usa dados mock como fallback
        _loadMockData();
      }
    } catch (e) {
      debugPrint('GastronomyScreen: Exceção - $e');
      // Em caso de erro, usa dados mock
      if (mounted) {
        _loadMockData();
      }
    }
  }

  void _loadMockData() {
    if (!mounted) return;
    
    setState(() {
      _restaurants = _mockDataService.getRestaurants();
      _isLoading = false;
      _errorMessage = null; // Não mostra erro se tem mock data
    });
  }

  void _onFilterChanged(String newFilter) {
    if (_priceFilter != newFilter) {
      setState(() {
        _priceFilter = newFilter;
      });
      // Não precisa recarregar da API, apenas filtra localmente
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null && _restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.gray400),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.gray600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarRestaurantes,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final filteredRestaurants = _priceFilter == 'all'
        ? _restaurants
        : _restaurants.where((r) => r.priceRange == _priceFilter).toList();

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
                  'Gastronomia',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Descubra as melhores opções gastronômicas da ilha',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Price Filter
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'Todos',
                  isSelected: _priceFilter == 'all',
                  onTap: () => _onFilterChanged('all'),
                ),
                _FilterChip(
                  label: '\$ Econômico',
                  isSelected: _priceFilter == '\$',
                  onTap: () => _onFilterChanged('\$'),
                ),
                _FilterChip(
                  label: '\$\$ Moderado',
                  isSelected: _priceFilter == '\$\$',
                  onTap: () => _onFilterChanged('\$\$'),
                ),
                _FilterChip(
                  label: '\$\$\$ Sofisticado',
                  isSelected: _priceFilter == '\$\$\$',
                  onTap: () => _onFilterChanged('\$\$\$'),
                ),
                _FilterChip(
                  label: '\$\$\$\$ Premium',
                  isSelected: _priceFilter == '\$\$\$\$',
                  onTap: () => _onFilterChanged('\$\$\$\$'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Restaurant List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredRestaurants.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RestaurantCard(restaurant: filteredRestaurants[index]),
              );
            },
          ),

          // Info Box
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
                  const Text('🍽️', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 12),
                  const Text(
                    'Gastronomia Local',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fernando de Noronha oferece opções gastronômicas para todos os gostos, desde frutos do mar frescos até culinária regional nordestina. Reserve com antecedência nos restaurantes mais concorridos!',
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
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.gray200,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.gray600,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const _RestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: CachedImage(
                    imageUrl: restaurant.imageUrl,
                    useAuth: true, // Imagens da API precisam de auth
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    restaurant.priceRange,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  restaurant.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(height: 16),

                // Menu Button
                if (restaurant.linkCardapio != null && restaurant.linkCardapio!.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PdfViewer(
                            pdfUrl: restaurant.linkCardapio!,
                            title: 'Cardápio - ${restaurant.name}',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book, size: 18),
                    label: const Text('Ver Cardápio'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 44),
                      side: const BorderSide(color: AppColors.primary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),

                // Action Button
                if (restaurant.hasReservation)
                  ElevatedButton.icon(
                    onPressed: () {
                      AppUtils.openWhatsApp(
                        number: restaurant.whatsapp,
                        message: WhatsAppMessages.restaurantReservation(restaurant.name),
                      );
                    },
                    icon: const Icon(Icons.chat, size: 18),
                    label: const Text('Fazer Reserva'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                
                if (restaurant.hasDelivery)
                  ElevatedButton.icon(
                    onPressed: () {
                      AppUtils.openWhatsApp(
                        number: restaurant.whatsapp,
                        message: WhatsAppMessages.restaurantOrder(restaurant.name),
                      );
                    },
                    icon: const Icon(Icons.chat, size: 18),
                    label: const Text('Fazer Pedido'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.whatsappGreen,
                      minimumSize: const Size(double.infinity, 44),
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
    );
  }
}







