import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';
import '../core/utils.dart';

/// Tela da Calculadora de Viagem
class CalculatorScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const CalculatorScreen({super.key, this.onBack});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _apiService = ApiService();
  final _cityController = TextEditingController();
  
  List<Map<String, dynamic>> _airports = [];
  List<Map<String, dynamic>> _tours = [];
  Map<String, dynamic>? _selectedAirport;
  bool _isLoadingAirports = false;
  bool _isLoadingTours = false;
  bool _isCalculating = false;
  
  String? _cityName;
  bool _skipFlight = false;
  int _days = 7;
  int _people = 2;
  String? _accommodation;
  bool _skipAccommodation = false;
  String? _restaurantCategory;
  String? _transportType;
  List<String> _selectedTours = [];
  
  Map<String, dynamic>? _calculationResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAirports();
    _loadTours();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadAirports() async {
    setState(() {
      _isLoadingAirports = true;
    });

    try {
      final response = await _apiService.getAirports();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _airports = (response.data as List)
              .map((json) => json as Map<String, dynamic>)
              .toList();
          _isLoadingAirports = false;
        });
      } else {
        setState(() {
          _isLoadingAirports = false;
          _errorMessage = 'Erro ao carregar aeroportos';
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingAirports = false;
        _errorMessage = 'Erro ao carregar aeroportos: $e';
      });
    }
  }

  Future<void> _loadTours() async {
    setState(() {
      _isLoadingTours = true;
    });

    try {
      final response = await _apiService.getTravelTours();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _tours = (response.data as List)
              .map((json) => json as Map<String, dynamic>)
              .toList();
          _isLoadingTours = false;
        });
      } else {
        setState(() {
          _isLoadingTours = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingTours = false;
      });
    }
  }

  void _findNearestAirport(String cityName) {
    if (cityName.isEmpty) {
      setState(() {
        _selectedAirport = null;
        _cityName = null;
      });
      return;
    }

    // Normaliza a cidade para busca (remove acentos, lowercase)
    final normalizedCity = _normalizeString(cityName);
    
    // Mapeamento de cidades comuns para códigos IATA principais
    final cityToIataMap = {
      'sao paulo': 'GRU',
      'sp': 'GRU',
      'rio de janeiro': 'GIG',
      'rio': 'GIG',
      'rj': 'GIG',
      'belo horizonte': 'CNF',
      'bh': 'CNF',
      'curitiba': 'CWB',
      'porto alegre': 'POA',
      'brasilia': 'BSB',
      'salvador': 'SSA',
      'fortaleza': 'FOR',
      'recife': 'REC',
      'natal': 'NAT',
      'joao pessoa': 'JPA',
      'maceio': 'MCZ',
      'aracaju': 'AJU',
      'vitoria': 'VIX',
      'florianopolis': 'FLN',
      'goiania': 'GYN',
      'campinas': 'VCP',
      'sao luiz': 'SLZ',
      'belem': 'BEL',
      'manaus': 'MAO',
      'porto velho': 'PVH',
      'rio branco': 'RBR',
      'cuiaba': 'CGB',
      'campo grande': 'CGR',
    };

    // Verifica se a cidade está no mapeamento
    final cityKey = normalizedCity.toLowerCase().trim();
    if (cityToIataMap.containsKey(cityKey)) {
      final iataCode = cityToIataMap[cityKey]!;
      // Busca o aeroporto pelo código IATA
      final airport = _airports.firstWhere(
        (a) => _normalizeString(a['codigoIATA']?.toString() ?? '') == iataCode.toLowerCase(),
        orElse: () => {
          'cidade': cityName,
          'nomeAeroporto': 'Aeroporto de $cityName',
          'codigoIATA': iataCode,
        },
      );
      setState(() {
        _selectedAirport = airport;
        _cityName = cityName;
      });
      return;
    }
    
    // Busca exata primeiro
    Map<String, dynamic>? exactMatch;
    for (var airport in _airports) {
      final airportCity = _normalizeString(airport['cidade']?.toString() ?? '');
      if (airportCity == normalizedCity) {
        exactMatch = airport;
        break;
      }
    }

    if (exactMatch != null) {
      setState(() {
        _selectedAirport = exactMatch;
        _cityName = cityName;
      });
      return;
    }

    // Busca parcial (contém) - mais flexível
    List<Map<String, dynamic>> partialMatches = [];
    for (var airport in _airports) {
      final airportCity = _normalizeString(airport['cidade']?.toString() ?? '');
      final airportName = _normalizeString(airport['nomeAeroporto']?.toString() ?? '');
      
      // Verifica se a cidade digitada contém o nome da cidade do aeroporto ou vice-versa
      if (airportCity.contains(normalizedCity) || 
          normalizedCity.contains(airportCity) ||
          airportName.contains(normalizedCity) ||
          normalizedCity.contains(airportName)) {
        partialMatches.add(airport);
      }
    }

    if (partialMatches.isNotEmpty) {
      // Prioriza o primeiro match (pode melhorar a lógica aqui)
      setState(() {
        _selectedAirport = partialMatches.first;
        _cityName = cityName;
      });
      return;
    }

    // Busca por palavras-chave comuns nas cidades
    final cityWords = normalizedCity.split(' ').where((w) => w.length > 2).toList();
    for (var word in cityWords) {
      for (var airport in _airports) {
        final airportCity = _normalizeString(airport['cidade']?.toString() ?? '');
        if (airportCity.contains(word)) {
          setState(() {
            _selectedAirport = airport;
            _cityName = cityName;
          });
          return;
        }
      }
    }

    // Se não encontrou, permite continuar mesmo assim
    // Usará um código padrão baseado na primeira letra ou região
    setState(() {
      _selectedAirport = null;
      _cityName = cityName;
    });
  }

  String _normalizeString(String str) {
    return str
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c')
        .trim();
  }

  String _getDefaultIataCode(String? cityName) {
    if (cityName == null || cityName.isEmpty) return 'GRU';
    
    final normalized = _normalizeString(cityName);
    
    // Mapeamento de padrões para códigos IATA comuns
    if (normalized.contains('sao paulo') || normalized.contains('sp')) return 'GRU';
    if (normalized.contains('rio') || normalized.contains('rj')) return 'GIG';
    if (normalized.contains('belo horizonte') || normalized.contains('bh')) return 'CNF';
    if (normalized.contains('curitiba')) return 'CWB';
    if (normalized.contains('porto alegre')) return 'POA';
    if (normalized.contains('brasilia')) return 'BSB';
    if (normalized.contains('salvador')) return 'SSA';
    if (normalized.contains('fortaleza')) return 'FOR';
    if (normalized.contains('recife')) return 'REC';
    if (normalized.contains('natal')) return 'NAT';
    if (normalized.contains('joao pessoa')) return 'JPA';
    if (normalized.contains('maceio')) return 'MCZ';
    if (normalized.contains('aracaju')) return 'AJU';
    if (normalized.contains('vitoria')) return 'VIX';
    if (normalized.contains('florianopolis') || normalized.contains('floripa')) return 'FLN';
    if (normalized.contains('goiania')) return 'GYN';
    if (normalized.contains('campinas')) return 'VCP';
    if (normalized.contains('sao luiz') || normalized.contains('sao luis')) return 'SLZ';
    if (normalized.contains('belem')) return 'BEL';
    if (normalized.contains('manaus')) return 'MAO';
    if (normalized.contains('porto velho')) return 'PVH';
    if (normalized.contains('rio branco')) return 'RBR';
    if (normalized.contains('cuiaba')) return 'CGB';
    if (normalized.contains('campo grande')) return 'CGR';
    
    // Se começar com certas letras, usa códigos comuns
    final firstLetter = normalized.isNotEmpty ? normalized[0] : 'g';
    if (firstLetter == 's') return 'GRU'; // São Paulo
    if (firstLetter == 'r') return 'GIG'; // Rio
    if (firstLetter == 'b') return 'BSB'; // Brasília
    if (firstLetter == 'c') return 'CNF'; // Belo Horizonte (Confins)
    if (firstLetter == 'f') return 'FOR'; // Fortaleza
    if (firstLetter == 'm') return 'MAO'; // Manaus
    
    // Padrão: GRU (São Paulo - maior hub)
    return 'GRU';
  }

  Future<void> _calculateCosts() async {
    if ((_cityName == null || _cityName!.isEmpty) && !_skipFlight) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe sua cidade de origem'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_restaurantCategory == null || _transportType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCalculating = true;
      _calculationResult = null;
      _errorMessage = null;
    });

    try {
      // Se não encontrou aeroporto, usa um código padrão baseado na cidade
      final origem = _selectedAirport?['codigoIATA']?.toString() ?? 
                    _getDefaultIataCode(_cityName);
      
      // Mapeia os valores para o formato da API
      String tipoHospedagem = 'ECONOMICA';
      if (_accommodation == 'backpacker') tipoHospedagem = 'MOCHILEIRO';
      else if (_accommodation == 'budget') tipoHospedagem = 'ECONOMICA';
      else if (_accommodation == 'medium') tipoHospedagem = 'INTERMEDIARIA';
      else if (_accommodation == 'luxury') tipoHospedagem = 'LUXO';

      String categoriaRestaurante = 'MODERADO';
      if (_restaurantCategory == 'budget') categoriaRestaurante = 'ECONOMICO';
      else if (_restaurantCategory == 'medium') categoriaRestaurante = 'MODERADO';
      else if (_restaurantCategory == 'luxury') categoriaRestaurante = 'PREMIUM';

      String tipoTransporte = 'NENHUM';
      if (_transportType == 'car') tipoTransporte = 'ALUGUEL_CARRO_BUGGY';
      else if (_transportType == 'taxi') tipoTransporte = 'TAXI';
      else if (_transportType == 'bus') tipoTransporte = 'ONIBUS';

      final response = await _apiService.calculateTravelCosts(
        origem: origem,
        duracaoDias: _days,
        numeroPessoas: _people,
        tipoHospedagem: tipoHospedagem,
        categoriaRestaurante: categoriaRestaurante,
        tipoTransporte: tipoTransporte,
        passeios: _selectedTours,
        jaTemPassagens: _skipFlight,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          _calculationResult = response.data as Map<String, dynamic>;
          _isCalculating = false;
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Erro ao calcular custos';
          _isCalculating = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao calcular custos: $e';
        _isCalculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final showResults = _calculationResult != null;

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
                  'Calculadora de Viagem',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Origin
                _buildCard(
                  step: 1,
                  title: 'De onde você é?',
                  isComplete: _selectedAirport != null || _skipFlight,
                  child: Column(
                    children: [
                      TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.location_on),
                          hintText: 'Nome da cidade ou aeroporto',
                          suffixIcon: _cityController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _cityController.clear();
                                    _findNearestAirport('');
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          _findNearestAirport(value);
                        },
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, -0.1),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                              child: child,
                            ),
                          );
                        },
                        child: _selectedAirport != null
                            ? Padding(
                                key: const ValueKey('airport'),
                                padding: const EdgeInsets.only(top: 12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primary),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.flight_takeoff, color: AppColors.primary, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _selectedAirport!['nomeAeroporto']?.toString() ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.gray800,
                                              ),
                                            ),
                                            Text(
                                              '${_selectedAirport!['cidade']?.toString() ?? ''} - ${_selectedAirport!['codigoIATA']?.toString() ?? ''}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.gray600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : _cityName != null && _cityName!.isNotEmpty && _selectedAirport == null
                                ? Padding(
                                    key: const ValueKey('info'),
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.blue.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Aeroporto não encontrado para "$_cityName". O cálculo usará um aeroporto padrão próximo. Você pode continuar normalmente.',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.blue.shade800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(key: ValueKey('empty')),
                      ),
                      const SizedBox(height: 12),
                      _buildCheckbox(
                        value: _skipFlight,
                        label: 'Já tenho passagem aérea',
                        onChanged: (val) => setState(() => _skipFlight = val ?? false),
                      ),
                    ],
                  ),
                ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                        child: child,
                      ),
                    );
                  },
                  child: ((_cityName != null && _cityName!.isNotEmpty) || _skipFlight) && !_isLoadingAirports
                      ? Column(
                          key: const ValueKey('form'),
                          children: [
                            const SizedBox(height: 12),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildCard(
                                step: 2,
                                title: 'Duração da viagem',
                                isComplete: true,
                                suffix: '$_days dias',
                                child: Column(
                                  children: [
                                    Slider(
                                      value: _days.toDouble(),
                                      min: 3,
                                      max: 15,
                                      divisions: 12,
                                      label: '$_days dias',
                                      onChanged: (val) => setState(() => _days = val.round()),
                                    ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('3 dias', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
                            Text('15 dias', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                            ),

                            const SizedBox(height: 12),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildCard(
                                step: 3,
                                title: 'Número de pessoas',
                                isComplete: true,
                                suffix: '$_people pessoas',
                                child: Column(
                                  children: [
                                    Slider(
                                      value: _people.toDouble(),
                                      min: 1,
                                      max: 6,
                                      divisions: 5,
                                      label: '$_people',
                                      onChanged: (val) => setState(() => _people = val.round()),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: const [
                                        Text('1 pessoa', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
                                        Text('6 pessoas', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),
                            _buildCard(
                              step: 4,
                              title: 'Tipo de hospedagem',
                              isComplete: _accommodation != null || _skipAccommodation,
                    child: Column(
                      children: [
                        if (!_skipAccommodation) ...[
                          ..._buildAccommodationOptions(),
                        ] else
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: const Text(
                              'Hospedagem já incluída',
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        const SizedBox(height: 12),
                        _buildCheckbox(
                          value: _skipAccommodation,
                          label: 'Já tenho hospedagem',
                          onChanged: (val) => setState(() {
                            _skipAccommodation = val ?? false;
                            if (_skipAccommodation) _accommodation = null;
                          }),
                        ),
                      ],
                    ),
                  ),

                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.1),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                                    child: child,
                                  ),
                                );
                              },
                              child: (_accommodation != null || _skipAccommodation)
                                  ? Padding(
                                      key: const ValueKey('restaurant'),
                                      padding: const EdgeInsets.only(top: 12),
                                      child: _buildCard(
                                        step: 5,
                                        title: 'Categoria de Restaurantes',
                                        isComplete: _restaurantCategory != null,
                                        child: Column(
                                          children: _buildRestaurantOptions(),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(key: ValueKey('no-restaurant')),
                            ),

                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.1),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                                    child: child,
                                  ),
                                );
                              },
                              child: _restaurantCategory != null
                                  ? Padding(
                                      key: const ValueKey('transport'),
                                      padding: const EdgeInsets.only(top: 12),
                                      child: _buildCard(
                                        step: 6,
                                        title: 'Transporte na Ilha',
                                        isComplete: _transportType != null,
                                        child: Column(
                                          children: _buildTransportOptions(),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(key: ValueKey('no-transport')),
                            ),

                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.1),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                                    child: child,
                                  ),
                                );
                              },
                              child: _transportType != null
                                  ? Padding(
                                      key: const ValueKey('tours'),
                                      padding: const EdgeInsets.only(top: 12),
                                      child: _buildCard(
                                        step: 7,
                                        title: 'Selecione os Passeios',
                                        subtitle: 'Escolha os passeios que deseja fazer (opcional)',
                                        isComplete: true,
                                        child: _isLoadingTours
                                            ? const Center(child: CircularProgressIndicator())
                                            : Column(
                                                children: _tours.isEmpty
                                                    ? [
                                                        const Padding(
                                                          padding: EdgeInsets.all(16),
                                                          child: Text(
                                                            'Nenhum passeio disponível',
                                                            style: TextStyle(color: AppColors.gray500),
                                                          ),
                                                        ),
                                                      ]
                                                    : _tours.asMap().entries.map((entry) {
                                                        final index = entry.key;
                                                        final tour = entry.value;
                                                        final tourCode = tour['codigo']?.toString() ?? '';
                                                        final isSelected = _selectedTours.contains(tourCode);
                                                        final tourName = tour['nome']?.toString() ?? tour['descricao']?.toString() ?? '';
                                                        final tourPrice = (tour['preco'] as num?)?.toDouble() ?? 0.0;
                                                        
                                                        return TweenAnimationBuilder<double>(
                                                          tween: Tween(begin: 0.0, end: 1.0),
                                                          duration: Duration(milliseconds: 300 + (index * 50)),
                                                          curve: Curves.easeOut,
                                                          builder: (context, value, child) {
                                                            return Opacity(
                                                              opacity: value,
                                                              child: Transform.translate(
                                                                offset: Offset(0, 20 * (1 - value)),
                                                                child: child,
                                                              ),
                                                            );
                                                          },
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(bottom: 8),
                                                            child: AnimatedContainer(
                                                              duration: const Duration(milliseconds: 200),
                                                              curve: Curves.easeInOut,
                                                              child: Material(
                                                                color: isSelected ? AppColors.secondaryBg : Colors.white,
                                                                borderRadius: BorderRadius.circular(12),
                                                                child: InkWell(
                                                                  onTap: () => setState(() {
                                                                    if (isSelected) {
                                                                      _selectedTours.remove(tourCode);
                                                                    } else {
                                                                      _selectedTours.add(tourCode);
                                                                    }
                                                                  }),
                                                                  borderRadius: BorderRadius.circular(12),
                                                                  child: Container(
                                                                    padding: const EdgeInsets.all(12),
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(12),
                                                                      border: Border.all(
                                                                        color: isSelected ? AppColors.primary : AppColors.gray200,
                                                                        width: isSelected ? 2 : 1,
                                                                      ),
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        AnimatedScale(
                                                                          scale: isSelected ? 1.1 : 1.0,
                                                                          duration: const Duration(milliseconds: 200),
                                                                          child: Checkbox(
                                                                            value: isSelected,
                                                                            onChanged: (_) => setState(() {
                                                                              if (isSelected) {
                                                                                _selectedTours.remove(tourCode);
                                                                              } else {
                                                                                _selectedTours.add(tourCode);
                                                                              }
                                                                            }),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                tourName,
                                                                                style: const TextStyle(fontWeight: FontWeight.w600),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        if (tourPrice > 0)
                                                                          Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                                            children: [
                                                                              Text(
                                                                                AppUtils.formatMoney(tourPrice),
                                                                                style: const TextStyle(
                                                                                  color: AppColors.primary,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                              const Text(
                                                                                'por pessoa',
                                                                                style: TextStyle(fontSize: 10, color: AppColors.gray500),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                ),
                                            ),
                                      )
                                    : const SizedBox.shrink(key: ValueKey('no-tours')),
                              ),

                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                      scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                                        CurvedAnimation(parent: animation, curve: Curves.easeOut),
                                      ),
                                      child: child,
                                    ),
                                  );
                                },
                                child: _transportType != null
                                    ? Padding(
                                        key: const ValueKey('button'),
                                        padding: const EdgeInsets.only(top: 16),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          width: double.infinity,
                                          child: AnimatedScale(
                                            scale: _isCalculating ? 0.95 : 1.0,
                                            duration: const Duration(milliseconds: 200),
                                            child: ElevatedButton(
                                              onPressed: _isCalculating ? null : _calculateCosts,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                elevation: _isCalculating ? 2 : 4,
                                              ),
                                              child: _isCalculating
                                                  ? const SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                      ),
                                                    )
                                                  : const Text(
                                                      'Calcular Custos',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(key: ValueKey('no-button')),
                              ),
                          ],
                        )
                        : const SizedBox.shrink(key: ValueKey('empty-form')),
                      ),

                // Results
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                          CurvedAnimation(parent: animation, curve: Curves.easeOut),
                        ),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: showResults && _calculationResult != null
                      ? Column(
                          key: const ValueKey('results'),
                          children: [
                            const SizedBox(height: 16),
                            Container(
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
                          'Detalhamento de Custos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (((_calculationResult!['passagensAereas'] as num?)?.toDouble() ?? 0.0) > 0)
                          _buildCostRow(
                            Icons.flight,
                            'Passagens Aéreas',
                            (_calculationResult!['passagensAereas'] as num?)?.toDouble() ?? 0.0,
                          ),
                        if (((_calculationResult!['hospedagem'] as num?)?.toDouble() ?? 0.0) > 0)
                          _buildCostRow(
                            Icons.hotel,
                            'Hospedagem ($_days dias)',
                            (_calculationResult!['hospedagem'] as num?)?.toDouble() ?? 0.0,
                          ),
                        _buildCostRow(
                          Icons.restaurant,
                          'Restaurantes',
                          (_calculationResult!['alimentacao'] as num?)?.toDouble() ?? 0.0,
                        ),
                        if (((_calculationResult!['passeios'] as num?)?.toDouble() ?? 0.0) > 0)
                          _buildCostRow(
                            Icons.tour,
                            'Passeios (${_selectedTours.length})',
                            (_calculationResult!['passeios'] as num?)?.toDouble() ?? 0.0,
                          ),
                        _buildCostRow(
                          Icons.directions_car,
                          'Transporte Local',
                          (_calculationResult!['transporte'] as num?)?.toDouble() ?? 0.0,
                        ),
                        _buildCostRow(
                          Icons.receipt,
                          'Taxas Obrigatórias',
                          (_calculationResult!['taxas'] as num?)?.toDouble() ?? 0.0,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Container(
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
                      children: [
                        Text(
                          'Custo Total Estimado',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppUtils.formatMoney((_calculationResult!['total'] as num?)?.toDouble() ?? 0.0),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${AppUtils.formatMoney(((_calculationResult!['total'] as num?)?.toDouble() ?? 0.0) / _people)} por pessoa',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Warning
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        const Text('⚠️', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Importante',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '• Valores aproximados baseados em médias\n'
                                '• Preços de passagens variam conforme temporada\n'
                                '• Taxas: TPA (R\$ 79,20/dia) e PARNAMAR (R\$ 222)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber.shade800,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                          ],
                        )
                      : const SizedBox.shrink(key: ValueKey('no-results')),
                ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                        child: child,
                      ),
                    );
                  },
                  child: _errorMessage != null
                      ? Padding(
                          key: const ValueKey('error'),
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade700),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('no-error')),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required int step,
    required String title,
    String? subtitle,
    required bool isComplete,
    String? suffix,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isComplete ? AppColors.success : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isComplete
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : Text(
                          '$step',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray700),
                    ),
                    if (subtitle != null)
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
                  ],
                ),
              ),
              if (suffix != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    suffix,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: value ? Colors.green.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? Colors.green : AppColors.gray200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: value ? Colors.green : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: value ? Colors.green : AppColors.gray300, width: 2),
              ),
              child: value ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: value ? Colors.green.shade700 : AppColors.gray600)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAccommodationOptions() {
    final options = [
      {'key': 'backpacker', 'label': 'Mochileiro', 'price': 'R\$ 150/dia'},
      {'key': 'budget', 'label': 'Econômica', 'price': 'R\$ 300/dia'},
      {'key': 'medium', 'label': 'Intermediária', 'price': 'R\$ 600/dia'},
      {'key': 'luxury', 'label': 'Luxo', 'price': 'R\$ 1.500/dia'},
    ];

    return options.map((opt) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _buildOptionButton(
        isSelected: _accommodation == opt['key'],
        label: opt['label']!,
        price: opt['price']!,
        onTap: () => setState(() => _accommodation = opt['key']),
      ),
    )).toList();
  }

  List<Widget> _buildRestaurantOptions() {
    final options = [
      {'key': 'budget', 'label': 'Econômicos', 'price': 'R\$ 80/dia', 'desc': 'Lanchonetes e opções simples'},
      {'key': 'medium', 'label': 'Médio', 'price': 'R\$ 150/dia', 'desc': 'Restaurantes intermediários'},
      {'key': 'luxury', 'label': 'Premium', 'price': 'R\$ 300/dia', 'desc': 'Gastronomia refinada'},
    ];

    return options.map((opt) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _buildOptionButton(
        isSelected: _restaurantCategory == opt['key'],
        label: opt['label']!,
        price: opt['price']!,
        description: opt['desc'],
        onTap: () => setState(() => _restaurantCategory = opt['key']),
      ),
    )).toList();
  }

  List<Widget> _buildTransportOptions() {
    final options = [
      _TransportOption(key: 'car', label: 'Aluguel de Carro/Buggy', price: 'R\$ 200/dia', icon: Icons.directions_car),
      _TransportOption(key: 'taxi', label: 'Táxi', price: 'R\$ 80/dia', icon: Icons.local_taxi),
      _TransportOption(key: 'bus', label: 'Ônibus', price: 'R\$ 10/dia', icon: Icons.directions_bus),
      _TransportOption(key: 'none', label: 'Nenhum', price: 'R\$ 0', icon: Icons.location_on),
    ];

    return options.map((opt) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _buildOptionButton(
        isSelected: _transportType == opt.key,
        label: opt.label,
        price: opt.price,
        icon: opt.icon,
        onTap: () => setState(() => _transportType = opt.key),
      ),
    )).toList();
  }

  Widget _buildOptionButton({
    required bool isSelected,
    required String label,
    required String price,
    String? description,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryBg : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.gray300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            if (icon != null) ...[
              Icon(icon, size: 20, color: AppColors.gray600),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: AppColors.gray800)),
                  if (description != null)
                    Text(description, style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                price,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(IconData icon, String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondaryBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.gray700))),
          Text(
            AppUtils.formatMoney(value),
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray800),
          ),
        ],
      ),
    );
  }
}

class _TransportOption {
  final String key;
  final String label;
  final String price;
  final IconData icon;

  _TransportOption({
    required this.key,
    required this.label,
    required this.price,
    required this.icon,
  });
}
