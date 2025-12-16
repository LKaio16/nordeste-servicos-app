import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/point_of_interest.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';
import '../core/utils.dart';
import '../widgets/image_viewer.dart';

/// Tela do Mapa
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _apiService = ApiService();
  final _mockDataService = MockDataService();
  
  List<PointOfInterest> _points = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarPontosInteresse();
  }

  Future<void> _carregarPontosInteresse() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('MapScreen: Iniciando carregamento de pontos de interesse...');
      final response = await _apiService.getPointsOfInterest();
      debugPrint('MapScreen: Resposta recebida - success: ${response.isSuccess}');
      
      if (!mounted) return;
      
      if (response.isSuccess && response.data != null) {
        debugPrint('MapScreen: Dados recebidos: ${response.data}');
        final pontos = (response.data as List)
            .map((json) => PointOfInterest.fromApiJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('MapScreen: ${pontos.length} pontos de interesse carregados');
        setState(() {
          _points = pontos;
          _isLoading = false;
        });
      } else {
        debugPrint('MapScreen: Erro - ${response.error}');
        // Se falhar, usa dados mock como fallback
        _loadMockData();
      }
    } catch (e) {
      debugPrint('MapScreen: Exceção - $e');
      // Em caso de erro, usa dados mock
      if (mounted) {
        _loadMockData();
      }
    }
  }

  void _loadMockData() {
    if (!mounted) return;
    
    setState(() {
      _points = _mockDataService.getPointsOfInterest();
      _isLoading = false;
      _errorMessage = null; // Não mostra erro se tem mock data
    });
  }

  void _abrirMapaPDF(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ImageViewer(
          imagePath: 'assets/images/MAPA_NORONHA.jpg',
          title: 'Mapa de Fernando de Noronha',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null && _points.isEmpty) {
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
              onPressed: _carregarPontosInteresse,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final points = _points;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mapa PDF Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => _abrirMapaPDF(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Icon(
                          Icons.map_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Mapa da Ilha (PDF)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Visualize e baixe o mapa completo de Fernando de Noronha com todos os pontos turísticos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.map, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Ver Mapa PDF',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
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
          ),

          // Pontos de Interesse
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Pontos de Interesse',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 12),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: points.length,
            itemBuilder: (context, index) {
              final point = points[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              point.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    point.type,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.gray100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    point.coords,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.gray600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: AppColors.secondaryBg,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () {
                            if (point.linkGoogleMaps != null && point.linkGoogleMaps!.isNotEmpty) {
                              AppUtils.openUrl(point.linkGoogleMaps!);
                            } else {
                              AppUtils.openGoogleMaps();
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.navigation,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Info Box
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondaryBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Text('🗺️', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Navegue pela Ilha',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.gray800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'A ilha é pequena e tudo fica perto! A distância máxima entre dois pontos é de apenas 30 minutos.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Google Maps Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => AppUtils.openGoogleMaps(),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Icon(
                          Icons.navigation,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Abrir no Google Maps',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Navegue com GPS em tempo real',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
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
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}







