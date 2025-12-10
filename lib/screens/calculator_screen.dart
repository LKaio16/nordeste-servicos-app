import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../services/mock_data_service.dart';
import '../core/utils.dart';

/// Tela da Calculadora de Viagem
class CalculatorScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const CalculatorScreen({super.key, this.onBack});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _dataService = MockDataService();
  
  String? _origin;
  bool _skipFlight = false;
  int _days = 7;
  int _people = 2;
  String? _accommodation;
  bool _skipAccommodation = false;
  String? _restaurantCategory;
  String? _transportType;
  List<int> _selectedTours = [];

  final _prices = {
    'flight': {'min': 1500.0, 'max': 3000.0},
    'accommodation': {
      'backpacker': 150.0,
      'budget': 300.0,
      'medium': 600.0,
      'luxury': 1500.0,
    },
    'restaurant': {
      'budget': 80.0,
      'medium': 150.0,
      'luxury': 300.0,
    },
    'transport': {
      'none': 0.0,
      'car': 200.0,
      'taxi': 80.0,
      'bus': 10.0,
    },
  };

  Map<String, double> _calculateCosts() {
    if (_restaurantCategory == null || _transportType == null) {
      return {'total': 0};
    }

    final tours = _dataService.getCalculatorTours();

    final flight = _skipFlight ? 0.0 : 
      ((_prices['flight']!['min']! + _prices['flight']!['max']!) / 2) * _people;
    
    final accommodation = (_skipAccommodation || _accommodation == null) ? 0.0 :
      (_prices['accommodation']![_accommodation]! * _days * _people);
    
    final restaurant = _prices['restaurant']![_restaurantCategory]! * _days * _people;
    
    final toursTotal = _selectedTours.fold(0.0, (sum, idx) =>
      sum + (tours[idx]['price'] as int) * _people);
    
    final fees = (AppConstants.tpaDaily * _days.clamp(1, AppConstants.tpaMaxDays) + AppConstants.parnamar) * _people;
    
    final transport = _prices['transport']![_transportType]! * _days * _people;

    return {
      'flight': flight,
      'accommodation': accommodation,
      'restaurant': restaurant,
      'tours': toursTotal,
      'fees': fees,
      'transport': transport,
      'total': flight + accommodation + restaurant + toursTotal + fees + transport,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cities = _dataService.getCities();
    final tours = _dataService.getCalculatorTours();
    final costs = _calculateCosts();
    final showResults = _restaurantCategory != null && _transportType != null;

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
                  isComplete: _origin != null,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.location_on),
                          hintText: 'Selecione sua cidade',
                        ),
                        value: _origin,
                        items: cities.map((city) => DropdownMenuItem(
                          value: city,
                          child: Text(city, style: const TextStyle(fontSize: 14)),
                        )).toList(),
                        onChanged: (val) => setState(() => _origin = val),
                      ),
                      if (_origin != null) ...[
                        const SizedBox(height: 12),
                        _buildCheckbox(
                          value: _skipFlight,
                          label: 'Já tenho passagem aérea',
                          onChanged: (val) => setState(() => _skipFlight = val ?? false),
                        ),
                      ],
                    ],
                  ),
                ),

                if (_origin != null) ...[
                  const SizedBox(height: 12),
                  _buildCard(
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

                  const SizedBox(height: 12),
                  _buildCard(
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

                  if (_accommodation != null || _skipAccommodation) ...[
                    const SizedBox(height: 12),
                    _buildCard(
                      step: 5,
                      title: 'Categoria de Restaurantes',
                      isComplete: _restaurantCategory != null,
                      child: Column(
                        children: _buildRestaurantOptions(),
                      ),
                    ),
                  ],

                  if (_restaurantCategory != null) ...[
                    const SizedBox(height: 12),
                    _buildCard(
                      step: 6,
                      title: 'Transporte na Ilha',
                      isComplete: _transportType != null,
                      child: Column(
                        children: _buildTransportOptions(),
                      ),
                    ),
                  ],

                  if (_transportType != null) ...[
                    const SizedBox(height: 12),
                    _buildCard(
                      step: 7,
                      title: 'Selecione os Passeios',
                      subtitle: 'Escolha os passeios que deseja fazer (opcional)',
                      isComplete: true,
                      child: Column(
                        children: [
                          ...tours.asMap().entries.map((entry) {
                            final index = entry.key;
                            final tour = entry.value;
                            final isSelected = _selectedTours.contains(index);
                            final tourName = tour['name']?.toString() ?? '';
                            final tourDesc = tour['description']?.toString() ?? '';
                            final tourPrice = (tour['price'] as int?) ?? 0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: isSelected ? AppColors.secondaryBg : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: () => setState(() {
                                    if (isSelected) {
                                      _selectedTours.remove(index);
                                    } else {
                                      _selectedTours.add(index);
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
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: (_) => setState(() {
                                            if (isSelected) {
                                              _selectedTours.remove(index);
                                            } else {
                                              _selectedTours.add(index);
                                            }
                                          }),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tourName,
                                                style: const TextStyle(fontWeight: FontWeight.w600),
                                              ),
                                              Text(
                                                tourDesc,
                                                style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              AppUtils.formatMoney(tourPrice.toDouble()),
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
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ],

                // Results
                if (showResults && costs['total']! > 0) ...[
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
                        if (costs['flight']! > 0)
                          _buildCostRow(Icons.flight, 'Passagens Aéreas', costs['flight']!),
                        if (costs['accommodation']! > 0)
                          _buildCostRow(Icons.hotel, 'Hospedagem ($_days dias)', costs['accommodation']!),
                        _buildCostRow(Icons.restaurant, 'Restaurantes', costs['restaurant']!),
                        if (costs['tours']! > 0)
                          _buildCostRow(Icons.tour, 'Passeios (${_selectedTours.length})', costs['tours']!),
                        _buildCostRow(Icons.directions_car, 'Transporte Local', costs['transport']!),
                        _buildCostRow(Icons.receipt, 'Taxas Obrigatórias', costs['fees']!),
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
                          AppUtils.formatMoney(costs['total']!),
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
                            '${AppUtils.formatMoney(costs['total']! / _people)} por pessoa',
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

