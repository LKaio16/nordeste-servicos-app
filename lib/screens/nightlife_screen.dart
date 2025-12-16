import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/nightlife_venue.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';
import '../widgets/cached_image.dart';
import '../core/utils.dart';

/// Tela de Vida Noturna
class NightlifeScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const NightlifeScreen({super.key, this.onBack});

  @override
  State<NightlifeScreen> createState() => _NightlifeScreenState();
}

class _NightlifeScreenState extends State<NightlifeScreen> {
  final _apiService = ApiService();
  final _mockDataService = MockDataService();
  
  List<NightlifeVenue> _venues = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarVidaNoturna();
  }

  Future<void> _carregarVidaNoturna() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('NightlifeScreen: Iniciando carregamento de vida noturna...');
      final response = await _apiService.getNightlife();
      debugPrint('NightlifeScreen: Resposta recebida - success: ${response.isSuccess}');
      
      if (!mounted) return;
      
      if (response.isSuccess && response.data != null) {
        debugPrint('NightlifeScreen: Dados recebidos: ${response.data}');
        final venues = (response.data as List)
            .map((json) => NightlifeVenue.fromApiJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('NightlifeScreen: ${venues.length} locais de vida noturna carregados');
        setState(() {
          _venues = venues;
          _isLoading = false;
        });
      } else {
        debugPrint('NightlifeScreen: Erro - ${response.error}');
        // Se falhar, usa dados mock como fallback
        _loadMockData();
      }
    } catch (e) {
      debugPrint('NightlifeScreen: Exceção - $e');
      // Em caso de erro, usa dados mock
      if (mounted) {
        _loadMockData();
      }
    }
  }

  void _loadMockData() {
    if (!mounted) return;
    
    setState(() {
      _venues = _mockDataService.getNightlifeVenues();
      _isLoading = false;
      _errorMessage = null; // Não mostra erro se tem mock data
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null && _venues.isEmpty) {
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
              onPressed: _carregarVidaNoturna,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final venues = _venues;

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
                  'Vida Noturna',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Venues
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: venues.length,
                  itemBuilder: (context, index) {
                    final venue = venues[index];
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
                                      height: 200,
                                      width: double.infinity,
                                      child: CachedImage(
                                        imageUrl: venue.imageUrl,
                                        useAuth: true, // Imagens da API precisam de auth
                                      ),
                                    ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    venue.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.gray800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    venue.description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.gray600,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule, size: 16, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        venue.schedule,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.gray700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.music_note, size: 16, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        venue.highlight,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => AppUtils.openWhatsApp(
                                            number: venue.whatsapp,
                                            message: 'Olá! Gostaria de mais informações sobre ${venue.name}',
                                          ),
                                          icon: const Icon(Icons.chat, size: 18),
                                          label: const Text('Chamar no WhatsApp'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.whatsappGreen,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Material(
                                        color: AppColors.secondaryBg,
                                        borderRadius: BorderRadius.circular(12),
                                        child: InkWell(
                                          onTap: () {
                                            if (venue.linkGoogleMaps != null && venue.linkGoogleMaps!.isNotEmpty) {
                                              AppUtils.openUrl(venue.linkGoogleMaps!);
                                            } else {
                                              AppUtils.openGoogleMaps();
                                            }
                                          },
                                          borderRadius: BorderRadius.circular(12),
                                          child: const Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Icon(Icons.location_on, color: AppColors.primary),
                                          ),
                                        ),
                                      ),
                                    ],
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

                // Info Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          child: const Icon(Icons.music_note, color: AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vida Noturna em Noronha',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gray800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'A vida noturna em Fernando de Noronha é tranquila e familiar. Os bares concentram-se na Vila dos Remédios. A programação varia durante a semana, então vale conferir o calendário para não perder as melhores festas!',
                                style: TextStyle(
                                  color: AppColors.gray700,
                                  fontSize: 13,
                                  height: 1.4,
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
        ),
      ],
    );
  }
}

