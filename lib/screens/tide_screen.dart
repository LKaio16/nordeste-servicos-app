import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/tide_data.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';
import '../core/utils.dart';

/// Tela da Tábua de Maré
class TideScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const TideScreen({super.key, this.onBack});

  @override
  State<TideScreen> createState() => _TideScreenState();
}

class _TideScreenState extends State<TideScreen> {
  final _apiService = ApiService();
  final _mockDataService = MockDataService();
  DateTime _selectedDate = DateTime.now();
  
  List<TideData> _tideData = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarTides();
  }

  Future<void> _carregarTides() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Formata a data no formato yyyy-MM-dd
      final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      
      debugPrint('TideScreen: Iniciando carregamento de marés para $dateStr...');
      final response = await _apiService.getTides(date: dateStr);
      debugPrint('TideScreen: Resposta recebida - success: ${response.isSuccess}');
      
      if (!mounted) return;
      
      if (response.isSuccess && response.data != null) {
        debugPrint('TideScreen: Dados recebidos: ${response.data}');
        final tides = (response.data as List)
            .map((json) => TideData.fromApiJson(json as Map<String, dynamic>))
            .toList();
        // Processa as marés para determinar tipos mais precisos comparando entre si
        final processedTides = TideData.processTides(tides);
        debugPrint('TideScreen: ${processedTides.length} registros de maré carregados');
        setState(() {
          _tideData = processedTides;
          _isLoading = false;
        });
      } else {
        debugPrint('TideScreen: Erro - ${response.error}');
        // Se falhar, usa dados mock como fallback
        _loadMockData();
      }
    } catch (e) {
      debugPrint('TideScreen: Exceção - $e');
      // Em caso de erro, usa dados mock
      if (mounted) {
        _loadMockData();
      }
    }
  }

  void _loadMockData() {
    if (!mounted) return;
    
    setState(() {
      _tideData = _mockDataService.getTideData(_selectedDate);
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

    if (_errorMessage != null && _tideData.isEmpty) {
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
              onPressed: _carregarTides,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final tideData = _tideData;

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
                  'Tábua de Maré',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Date Selector
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Material(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.calendar_today, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Text(
                                    AppUtils.formatDate(_selectedDate),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Só mostra o botão se a data selecionada não for hoje
                        if (!_isToday(_selectedDate))
                          TextButton(
                            onPressed: () {
                              setState(() => _selectedDate = DateTime.now());
                              _carregarTides(); // Recarrega os dados quando volta para hoje
                            },
                            child: const Text('Voltar para Hoje'),
                          ),
                      ],
                    ),
                  ),
                ),

                // Tide Data
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Horários da Maré',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 12),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tideData.length,
                  itemBuilder: (context, index) {
                    final tide = tideData[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TideCard(tide: tide),
                    );
                  },
                ),

                // Tip Box
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.waves, color: Colors.white, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '💡 Dica de Mergulho',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'A maré baixa é ideal para piscinas naturais como o Atalaia. Já a maré alta é melhor para mergulho de cilindro e snorkel em alto mar.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
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

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1); // 1º de janeiro deste ano
    final endOfYear = DateTime(now.year, 12, 31); // 31 de dezembro deste ano
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: startOfYear, // Começa em janeiro deste ano
      lastDate: endOfYear, // Limita até dezembro deste ano
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _carregarTides(); // Recarrega os dados quando a data muda
    }
  }

  /// Verifica se a data é hoje
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }
}

class _TideCard extends StatelessWidget {
  final TideData tide;

  const _TideCard({required this.tide});

  @override
  Widget build(BuildContext context) {
    final isHigh = tide.type == TideType.high;

    return Container(
      padding: const EdgeInsets.all(20),
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
              color: isHigh ? Colors.blue.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isHigh ? Icons.arrow_upward : Icons.arrow_downward,
              color: isHigh ? AppColors.primary : AppColors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tide.time,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray800,
                  ),
                ),
                Text(
                  tide.type.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isHigh ? AppColors.primary : AppColors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tide.height,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                ),
              ),
              const Text(
                'altura',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}







