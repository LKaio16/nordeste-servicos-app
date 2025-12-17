import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/weather_data.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';
import '../core/utils.dart';

/// Tela de Previsão do Tempo
class WeatherScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const WeatherScreen({super.key, this.onBack});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _apiService = ApiService();
  final _mockDataService = MockDataService();
  DateTime _selectedDate = DateTime.now();
  
  CurrentWeather? _currentWeather;
  List<HourlyWeather> _hourlyWeather = [];
  List<DailyForecast> _forecast = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarPrevisao();
  }

  Future<void> _carregarPrevisao() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('WeatherScreen: Iniciando carregamento de previsão do tempo...');
      final response = await _apiService.getWeatherForecast();
      debugPrint('WeatherScreen: Resposta recebida - success: ${response.isSuccess}');
      
      if (!mounted) return;
      
      if (response.isSuccess && response.data != null) {
        debugPrint('WeatherScreen: Dados recebidos: ${response.data}');
        final data = response.data as Map<String, dynamic>;
        
        // Processa current
        if (data['current'] != null) {
          final currentData = data['current'] as Map<String, dynamic>;
          _currentWeather = CurrentWeather.fromApiJson(currentData);
        }
        
        // Processa hourly - filtra apenas horários futuros
        if (data['hourly'] != null) {
          final hourlyList = data['hourly'] as List<dynamic>;
          final now = DateTime.now();
          
          // Filtra apenas horários futuros antes de criar os objetos
          final futureHourly = hourlyList.where((json) {
            try {
              final timeStr = json['time']?.toString() ?? '';
              if (timeStr.contains('T')) {
                final dateTime = DateTime.parse(timeStr);
                return dateTime.isAfter(now);
              }
              return true;
            } catch (e) {
              return true;
            }
          }).toList();
          
          _hourlyWeather = futureHourly
              .map((json) => HourlyWeather.fromApiJson(json as Map<String, dynamic>))
              .toList();
        }
        
        // Processa daily
        if (data['daily'] != null) {
          final dailyList = data['daily'] as List<dynamic>;
          _forecast = dailyList
              .map((json) => DailyForecast.fromApiJson(json as Map<String, dynamic>))
              .toList();
        }
        
        debugPrint('WeatherScreen: Previsão carregada - current: ${_currentWeather != null}, hourly: ${_hourlyWeather.length}, daily: ${_forecast.length}');
        setState(() {
          _isLoading = false;
        });
      } else {
        debugPrint('WeatherScreen: Erro - ${response.error}');
        // Se falhar, usa dados mock como fallback
        _loadMockData();
      }
    } catch (e) {
      debugPrint('WeatherScreen: Exceção - $e');
      // Em caso de erro, usa dados mock
      if (mounted) {
        _loadMockData();
      }
    }
  }

  void _loadMockData() {
    if (!mounted) return;
    
    setState(() {
      _currentWeather = _mockDataService.getCurrentWeather();
      _hourlyWeather = _mockDataService.getHourlyWeather(_selectedDate);
      _forecast = _mockDataService.getDailyForecast();
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

    if (_errorMessage != null && _currentWeather == null) {
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
              onPressed: _carregarPrevisao,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final currentWeather = _currentWeather ?? _mockDataService.getCurrentWeather();
    final hourlyWeather = _hourlyWeather.isNotEmpty ? _hourlyWeather : _mockDataService.getHourlyWeather(_selectedDate);
    final forecast = _forecast.isNotEmpty ? _forecast : _mockDataService.getDailyForecast();

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
                  'Previsão do Tempo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Current Weather Card
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Weather icon
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _getWeatherGradient(currentWeather),
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: _getWeatherShadowColor(currentWeather).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getCurrentWeatherIcon(currentWeather),
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '${currentWeather.temp}°',
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray800,
                          ),
                        ),
                        Text(
                          currentWeather.condition,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.gray600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppUtils.formatDate(_selectedDate),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.gray500,
                          ),
                        ),
                        Text(
                          'Sensação térmica: ${currentWeather.feelsLike}°',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.gray500,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Weather Details Grid
                        Row(
                          children: [
                            Expanded(
                              child: _WeatherDetailCard(
                                icon: Icons.water_drop,
                                label: 'Umidade',
                                value: '${currentWeather.humidity}%',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _WeatherDetailCard(
                                icon: Icons.air,
                                label: 'Vento',
                                value: '${currentWeather.wind} km/h',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _WeatherDetailCard(
                                icon: Icons.wb_sunny,
                                label: 'Índice UV',
                                value: '${currentWeather.uvIndex}',
                                highlight: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Hourly Forecast
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Previsão Hora a Hora',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: hourlyWeather.length,
                    itemBuilder: (context, index) {
                      return _HourlyCard(weather: hourlyWeather[index]);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 7 Day Forecast
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Próximos 7 dias',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: forecast.map((day) => _DailyRow(forecast: day)).toList(),
                  ),
                ),

                // Recommendation
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.explore, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Recomendação do Dia',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ótimo dia para praias! Recomendamos visitar a Baía do Sancho pela manhã. Sol forte, use protetor solar FPS 50+.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
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
      ],
    );
  }

  IconData _getCurrentWeatherIcon(CurrentWeather weather) {
    // Determina o ícone baseado no UV index e condições
    if (weather.uvIndex >= 7) {
      return Icons.wb_sunny; // Sol forte
    } else if (weather.uvIndex >= 3) {
      return Icons.wb_cloudy; // Parcialmente nublado
    } else {
      // Verifica a descrição do tempo para casos específicos
      final condition = weather.condition.toLowerCase();
      if (condition.contains('chuva') || condition.contains('rain')) {
        return Icons.grain; // Chuva
      } else if (condition.contains('nublado') || condition.contains('cloud')) {
        return Icons.cloud; // Nublado
      } else {
        return Icons.wb_cloudy; // Padrão nublado
      }
    }
  }

  List<Color> _getWeatherGradient(CurrentWeather weather) {
    if (weather.uvIndex >= 7) {
      return [Colors.yellow.shade400, Colors.orange.shade500]; // Sol
    } else if (weather.uvIndex >= 3) {
      return [Colors.blue.shade300, Colors.blue.shade500]; // Parcialmente nublado
    } else {
      final condition = weather.condition.toLowerCase();
      if (condition.contains('chuva') || condition.contains('rain')) {
        return [Colors.blue.shade600, Colors.blue.shade800]; // Chuva
      } else {
        return [Colors.grey.shade400, Colors.grey.shade600]; // Nublado
      }
    }
  }

  Color _getWeatherShadowColor(CurrentWeather weather) {
    if (weather.uvIndex >= 7) {
      return Colors.orange;
    } else if (weather.uvIndex >= 3) {
      return Colors.blue;
    } else {
      final condition = weather.condition.toLowerCase();
      if (condition.contains('chuva') || condition.contains('rain')) {
        return Colors.blue.shade800;
      } else {
        return Colors.grey.shade600;
      }
    }
  }
}

class _WeatherDetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _WeatherDetailCard({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? Colors.orange.shade50 : AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: highlight ? Colors.orange : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.gray600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyCard extends StatelessWidget {
  final HourlyWeather weather;

  const _HourlyCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            weather.time,
            style: const TextStyle(fontSize: 12, color: AppColors.gray600),
          ),
          const SizedBox(height: 8),
          Icon(
            _getWeatherIcon(weather.icon),
            size: 28,
            color: _getWeatherColor(weather.icon),
          ),
          const SizedBox(height: 8),
          Text(
            weather.temp,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water_drop, size: 10, color: AppColors.primary),
              const SizedBox(width: 2),
              Text(
                '${weather.humidity}%',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(WeatherIcon icon) {
    switch (icon) {
      case WeatherIcon.sun:
        return Icons.wb_sunny;
      case WeatherIcon.cloud:
        return Icons.cloud;
      case WeatherIcon.rain:
        return Icons.water_drop;
    }
  }

  Color _getWeatherColor(WeatherIcon icon) {
    switch (icon) {
      case WeatherIcon.sun:
        return Colors.yellow.shade600;
      case WeatherIcon.cloud:
        return AppColors.gray400;
      case WeatherIcon.rain:
        return AppColors.primary;
    }
  }
}

class _DailyRow extends StatelessWidget {
  final DailyForecast forecast;

  const _DailyRow({required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              forecast.day,
              style: const TextStyle(
                color: AppColors.gray700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getWeatherIcon(forecast.icon),
                  size: 24,
                  color: _getWeatherColor(forecast.icon),
                ),
                if (forecast.humidity != null) ...[
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.water_drop, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${forecast.humidity}%',
                        style: const TextStyle(
                          color: AppColors.gray600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Text(
            forecast.temp,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(WeatherIcon icon) {
    switch (icon) {
      case WeatherIcon.sun:
        return Icons.wb_sunny;
      case WeatherIcon.cloud:
        return Icons.cloud;
      case WeatherIcon.rain:
        return Icons.water_drop;
    }
  }

  Color _getWeatherColor(WeatherIcon icon) {
    switch (icon) {
      case WeatherIcon.sun:
        return Colors.yellow.shade600;
      case WeatherIcon.cloud:
        return AppColors.gray400;
      case WeatherIcon.rain:
        return AppColors.primary;
    }
  }
}







