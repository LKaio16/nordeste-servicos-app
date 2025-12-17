import '../core/api_client.dart';
import '../config/app_constants.dart';

/// Serviço centralizado para chamadas à API
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final ApiClient _client = ApiClient();

  // ==================== TÁBUA DE MARÉS ====================
  
  /// Lista marés por data (formato: yyyy-MM-dd)
  Future<ApiResponse<List<dynamic>>> getTides({String? date}) async {
    final queryParams = date != null ? {'data': date} : null;
    return _client.get<List<dynamic>>(
      ApiEndpoints.tides,
      queryParams: queryParams?.map((k, v) => MapEntry(k, v)),
      fromJson: (json) => json as List<dynamic>,
    );
  }

  // ==================== DICAS ====================
  
  /// Lista todas as dicas
  Future<ApiResponse<List<dynamic>>> getTips() async {
    return _client.get<List<dynamic>>(
      ApiEndpoints.tips,
      fromJson: (json) => json as List<dynamic>,
    );
  }

  /// Busca dica por ID
  Future<ApiResponse<Map<String, dynamic>>> getTipById(int id) async {
    return _client.get<Map<String, dynamic>>(
      '${ApiEndpoints.tips}/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// URL da imagem da dica
  String getTipImageUrl(int id) {
    return '${AppConstants.apiBaseUrl}${ApiEndpoints.tipImage(id)}';
  }

  /// URL do ícone da dica
  String getTipIconUrl(int id) {
    return '${AppConstants.apiBaseUrl}${ApiEndpoints.tipIcon(id)}';
  }

  // ==================== VIDA NOTURNA ====================
  
  /// Lista todas as opções de vida noturna
  Future<ApiResponse<List<dynamic>>> getNightlife() async {
    return _client.get<List<dynamic>>(
      ApiEndpoints.nightlife,
      fromJson: (json) => json as List<dynamic>,
    );
  }

  /// Busca vida noturna por ID
  Future<ApiResponse<Map<String, dynamic>>> getNightlifeById(int id) async {
    return _client.get<Map<String, dynamic>>(
      '${ApiEndpoints.nightlife}/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// URL da imagem de vida noturna
  String getNightlifeImageUrl(int id) {
    return '${AppConstants.apiBaseUrl}${ApiEndpoints.nightlifeImage(id)}';
  }

  // ==================== PASSEIOS ====================
  
  /// Lista todos os passeios
  Future<ApiResponse<List<dynamic>>> getTours() async {
    return _client.get<List<dynamic>>(
      ApiEndpoints.tours,
      fromJson: (json) => json as List<dynamic>,
    );
  }

  /// Busca passeio por ID
  Future<ApiResponse<Map<String, dynamic>>> getTourById(int id) async {
    return _client.get<Map<String, dynamic>>(
      '${ApiEndpoints.tours}/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// URL da imagem do passeio
  String getTourImageUrl(int id) {
    return '${AppConstants.apiBaseUrl}${ApiEndpoints.tourImage(id)}';
  }

  // ==================== RESTAURANTES ====================
  
  /// Lista restaurantes (opcional: filtrar por categoria)
  /// Categorias: ECONOMICO, MODERADO, SOFISTICADO, PREMIUM
  Future<ApiResponse<List<dynamic>>> getRestaurants({String? categoria}) async {
    final queryParams = categoria != null ? {'categoria': categoria} : null;
    return _client.get<List<dynamic>>(
      ApiEndpoints.restaurants,
      queryParams: queryParams,
      fromJson: (json) => json as List<dynamic>,
    );
  }

  /// Busca restaurante por ID
  Future<ApiResponse<Map<String, dynamic>>> getRestaurantById(int id) async {
    return _client.get<Map<String, dynamic>>(
      '${ApiEndpoints.restaurants}/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// URL da imagem do restaurante
  String getRestaurantImageUrl(int id) {
    return '${AppConstants.apiBaseUrl}${ApiEndpoints.restaurantImage(id)}';
  }

  // ==================== PONTOS DE INTERESSE ====================
  
  /// Lista todos os pontos de interesse
  Future<ApiResponse<List<dynamic>>> getPointsOfInterest() async {
    return _client.get<List<dynamic>>(
      ApiEndpoints.pointsOfInterest,
      fromJson: (json) => json as List<dynamic>,
    );
  }

  // ==================== PREVISÃO DO TEMPO (PÚBLICA) ====================
  
  /// Obtém previsão completa do tempo
  Future<ApiResponse<Map<String, dynamic>>> getWeatherForecast({
    double? latitude,
    double? longitude,
  }) async {
    final lat = latitude ?? AppConstants.noronhaLatitude;
    final lon = longitude ?? AppConstants.noronhaLongitude;
    
    return _client.get<Map<String, dynamic>>(
      ApiEndpoints.weatherForecast,
      queryParams: {
        'latitude': lat.toString(),
        'longitude': lon.toString(),
      },
      fromJson: (json) => json as Map<String, dynamic>,
      requiresAuth: false, // Endpoint público
    );
  }

  /// Obtém dados meteorológicos atuais
  Future<ApiResponse<Map<String, dynamic>>> getCurrentWeather({
    double? latitude,
    double? longitude,
  }) async {
    final lat = latitude ?? AppConstants.noronhaLatitude;
    final lon = longitude ?? AppConstants.noronhaLongitude;
    
    return _client.get<Map<String, dynamic>>(
      ApiEndpoints.weatherCurrent,
      queryParams: {
        'latitude': lat.toString(),
        'longitude': lon.toString(),
      },
      fromJson: (json) => json as Map<String, dynamic>,
      requiresAuth: false, // Endpoint público
    );
  }

  // ==================== CALCULADORA DE VIAGEM ====================
  
  /// Lista capitais brasileiras disponíveis
  Future<ApiResponse<List<dynamic>>> getTravelCapitals() async {
    return _client.get<List<dynamic>>(
      ApiEndpoints.calculatorCapitals,
      fromJson: (json) => json as List<dynamic>,
    );
  }

  /// Lista todos os aeroportos brasileiros
  Future<ApiResponse<List<dynamic>>> getAirports() async {
    return _client.get<List<dynamic>>(
      ApiEndpoints.calculatorAirports,
      fromJson: (json) => json as List<dynamic>,
    );
  }

  /// Lista passeios disponíveis na calculadora
  Future<ApiResponse<List<dynamic>>> getTravelTours() async {
    return _client.get<List<dynamic>>(
      ApiEndpoints.calculatorTours,
      fromJson: (json) => json as List<dynamic>,
    );
  }

  /// Calcula valor das passagens aéreas
  Future<ApiResponse<Map<String, dynamic>>> calculateFlights({
    required String origem,
    required int duracaoDias,
    required int numeroPessoas,
  }) async {
    return _client.post<Map<String, dynamic>>(
      ApiEndpoints.calculatorFlights,
      body: {
        'origem': origem,
        'duracaoDias': duracaoDias,
        'numeroPessoas': numeroPessoas,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Calcula custos completos da viagem
  Future<ApiResponse<Map<String, dynamic>>> calculateTravelCosts({
    required String origem,
    required int duracaoDias,
    required int numeroPessoas,
    required String tipoHospedagem, // MOCHILEIRO, ECONOMICA, INTERMEDIARIA, LUXO
    required String categoriaRestaurante, // ECONOMICOS, MEDIO, PREMIUM
    required String tipoTransporte, // ALUGUEL_CARRO_BUGGY, TAXI, ONIBUS, NENHUM
    List<String>? passeios,
    bool jaTemPassagens = false,
  }) async {
    return _client.post<Map<String, dynamic>>(
      ApiEndpoints.calculatorComplete,
      body: {
        'origem': origem,
        'duracaoDias': duracaoDias,
        'numeroPessoas': numeroPessoas,
        'tipoHospedagem': tipoHospedagem,
        'categoriaRestaurante': categoriaRestaurante,
        'tipoTransporte': tipoTransporte,
        'passeios': passeios ?? [],
        'jaTemPassagens': jaTemPassagens,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ==================== CALCULADORA DE TÁXI ====================
  
  /// Busca origens e destinos disponíveis para táxi
  Future<ApiResponse<Map<String, dynamic>>> getTaxiOriginsDestinations() async {
    return _client.get<Map<String, dynamic>>(
      ApiEndpoints.taxiOriginsDestinations,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
  
  /// Calcula valor da corrida de táxi
  Future<ApiResponse<Map<String, dynamic>>> calculateTaxi({
    required String origem,
    required String destino,
  }) async {
    return _client.post<Map<String, dynamic>>(
      ApiEndpoints.taxiCalculator,
      body: {
        'origem': origem,
        'destino': destino,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}


