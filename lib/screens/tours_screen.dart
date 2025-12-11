import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../models/tour.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';
import '../widgets/cached_image.dart';
import '../widgets/whatsapp_button.dart';

import '../core/utils.dart';

/// Tela de Passeios
class ToursScreen extends StatefulWidget {
  const ToursScreen({super.key});

  @override
  State<ToursScreen> createState() => _ToursScreenState();
}

class _ToursScreenState extends State<ToursScreen> {
  final _apiService = ApiService();
  final _mockDataService = MockDataService();
  
  TourCategory _selectedCategory = TourCategory.todos;
  Tour? _selectedTour;
  
  List<Tour> _tours = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTours();
  }

  Future<void> _loadTours() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getTours();
      
      if (!mounted) return;
      
      if (response.isSuccess && response.data != null) {
        final toursData = response.data as List<dynamic>;
        final parsedTours = toursData.map((json) => Tour.fromApiJson(json as Map<String, dynamic>)).toList();
        
        // Debug: mostra quais passeios têm topSeller
        for (var tour in parsedTours) {
          if (tour.topSeller != null) {
            debugPrint('Tour em destaque: ${tour.name} - Top ${tour.topSeller}');
          }
        }
        
        setState(() {
          _tours = parsedTours;
          _isLoading = false;
        });
      } else {
        // Se falhar, usa dados mock como fallback
        _loadMockData();
      }
    } catch (e) {
      // Em caso de erro, usa dados mock
      if (mounted) {
        _loadMockData();
      }
    }
  }

  void _loadMockData() {
    if (!mounted) return;
    
    setState(() {
      _tours = _mockDataService.getTours();
      _isLoading = false;
      _error = null; // Não mostra erro se tem mock data
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null && _tours.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.gray400),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: AppColors.gray600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTours,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    // Filtra passeios em destaque (com topSeller/topRanking) e ordena por ranking
    final featuredTours = _tours
        .where((t) => t.featured || t.topSeller != null)
        .toList()
      ..sort((a, b) => (a.topSeller ?? 999).compareTo(b.topSeller ?? 999));
    
    final filteredTours = _selectedCategory == TourCategory.todos
        ? _tours
        : _tours.where((t) => t.categories.contains(_selectedCategory)).toList();

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadTours,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Featured Tours
                if (featuredTours.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Passeios em Destaque',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Os mais procurados pelos visitantes',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  
                  // Featured Tours Horizontal List
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: featuredTours.length,
                      itemBuilder: (context, index) {
                        return _FeaturedTourCard(
                          tour: featuredTours[index],
                          onTap: () => _showTourDetails(featuredTours[index]),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                ],

                // Category Filters
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: TourCategory.values.length,
                    itemBuilder: (context, index) {
                      final category = TourCategory.values[index];
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCategory = category),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.gray200,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getCategoryIcon(category),
                                  size: 14,
                                  color: isSelected ? Colors.white : AppColors.gray700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  category.label,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.gray700,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // All Tours
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory == TourCategory.todos 
                          ? 'Todos os Passeios' 
                          : _selectedCategory.label,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${filteredTours.length} passeios',
                        style: TextStyle(
                          color: AppColors.gray500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                if (filteredTours.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 48, color: AppColors.gray300),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum passeio encontrado\nnesta categoria',
                            style: TextStyle(color: AppColors.gray500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredTours.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _TourListCard(
                          tour: filteredTours[index],
                          onTap: () => _showTourDetails(filteredTours[index]),
                        ),
                      );
                    },
                  ),

                // Tip Box
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.amber500.withOpacity(0.1),
                          AppColors.orange.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.amber500.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dica Importante',
                                style: TextStyle(
                                  color: AppColors.amber900,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Recomendamos agendar seus passeios com antecedência, especialmente na alta temporada. Alguns passeios como a Trilha do Atalaia têm vagas limitadas!',
                                style: TextStyle(
                                  color: AppColors.amber800,
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

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),

        // Tour Detail Modal
        if (_selectedTour != null)
          _TourDetailModal(
            tour: _selectedTour!,
            onClose: () => setState(() => _selectedTour = null),
          ),
      ],
    );
  }

  void _showTourDetails(Tour tour) {
    setState(() => _selectedTour = tour);
  }

  IconData _getCategoryIcon(TourCategory category) {
    switch (category) {
      case TourCategory.todos:
        return Icons.auto_awesome;
      case TourCategory.aquaticos:
        return Icons.waves;
      case TourCategory.terrestres:
        return Icons.terrain;
      case TourCategory.exclusivos:
        return Icons.star;
      case TourCategory.aventura:
        return Icons.emoji_events;
    }
  }
}

class _FeaturedTourCard extends StatelessWidget {
  final Tour tour;
  final VoidCallback onTap;

  const _FeaturedTourCard({required this.tour, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: _TourImage(imageUrl: tour.imageUrl),
                ),
                if (tour.topSeller != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.amber500, AppColors.orange],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.white, size: 10),
                          const SizedBox(width: 3),
                          Text(
                            'Top ${tour.topSeller}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tour.name,
                      style: const TextStyle(
                        color: AppColors.gray800,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Text(
                        tour.description,
                        style: const TextStyle(
                          color: AppColors.gray500,
                          fontSize: 11,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            tour.price,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.schedule, size: 10, color: AppColors.gray500),
                        const SizedBox(width: 2),
                        Text(
                          tour.duration,
                          style: const TextStyle(
                            color: AppColors.gray500,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourListCard extends StatelessWidget {
  final Tour tour;
  final VoidCallback onTap;

  const _TourListCard({required this.tour, required this.onTap});

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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: _TourImage(imageUrl: tour.imageUrl),
                  ),
                ),
                if (tour.topSeller != null)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.amber500, AppColors.orange],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Top ${tour.topSeller}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tour.name,
                    style: const TextStyle(
                      color: AppColors.gray800,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tour.description,
                    style: const TextStyle(
                      color: AppColors.gray600,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule, size: 11, color: AppColors.gray500),
                          const SizedBox(width: 3),
                          Text(
                            tour.duration,
                            style: const TextStyle(
                              color: AppColors.gray500,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        tour.price,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: OutlinedButton(
                            onPressed: onTap,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Detalhes', style: TextStyle(fontSize: 11)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              AppUtils.openWhatsApp(
                                message: 'Olá! Gostaria de agendar o passeio: ${tour.name}',
                              );
                            },
                            icon: const Icon(Icons.chat, size: 12),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Agendar', style: TextStyle(fontSize: 11)),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.whatsappGreen,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
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
  }
}

class _TourDetailModal extends StatefulWidget {
  final Tour tour;
  final VoidCallback onClose;

  const _TourDetailModal({required this.tour, required this.onClose});

  @override
  State<_TourDetailModal> createState() => _TourDetailModalState();
}

class _TourDetailModalState extends State<_TourDetailModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleClose() async {
    await _controller.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleClose,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          color: Colors.black54,
          child: GestureDetector(
            onTap: () {},
            child: SlideTransition(
              position: _slideAnimation,
              child: DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Detalhes do Passeio',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            onPressed: _handleClose,
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    
                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image
                            Stack(
                              children: [
                                SizedBox(
                                  height: 250,
                                  width: double.infinity,
                                  child: _TourImage(imageUrl: widget.tour.imageUrl),
                                ),
                                if (widget.tour.topSeller != null)
                                  Positioned(
                                    top: 16,
                                    left: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [AppColors.amber500, AppColors.orange],
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.emoji_events, color: Colors.white, size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Top ${widget.tour.topSeller} Mais Vendido',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
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
                                    widget.tour.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.gray800,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    widget.tour.fullDescription,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.gray600,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Duration and Price
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondaryBg,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.schedule, size: 14, color: AppColors.primary),
                                                  const SizedBox(width: 4),
                                                  const Flexible(
                                                    child: Text(
                                                      'Duração',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: AppColors.primary,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                widget.tour.duration,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.gray800,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondaryBg,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.attach_money, size: 14, color: AppColors.primary),
                                                  const SizedBox(width: 4),
                                                  const Flexible(
                                                    child: Text(
                                                      'Valor',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: AppColors.primary,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                widget.tour.price,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.gray800,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // What's included
                                  if (widget.tour.includes.isNotEmpty) ...[
                                    const Text(
                                      'O que está incluído:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.gray800,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ...widget.tour.includes.map((item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            margin: const EdgeInsets.only(top: 6),
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppColors.gray700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                    const SizedBox(height: 24),
                                  ],

                                  // WhatsApp Button
                                  WhatsAppButton(
                                    text: 'Agendar Passeio via WhatsApp',
                                    message: 'Olá! Gostaria de agendar o passeio: ${widget.tour.name}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
            ),
        ),
      ),
        ),
    );
  }
}

/// Widget para exibir imagem do passeio com tratamento de erro
class _TourImage extends StatelessWidget {
  final String imageUrl;

  const _TourImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    // Verifica se é URL da API (precisa de token) ou URL externa
    final isApiImage = imageUrl.contains('/api/passeios/') && imageUrl.contains('/imagem');
    
    if (isApiImage) {
      // Para imagens da API, usa AuthenticatedImage com headers
      return AuthenticatedImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        errorWidget: Container(
          color: AppColors.gray100,
          child: const Center(
            child: Icon(Icons.sailing, size: 40, color: AppColors.gray400),
          ),
        ),
      );
    }
    
    // Para URLs externas, usa CachedImage
    return CachedImage(imageUrl: imageUrl);
  }
}
