/// Constantes do app Me Leva Noronha
class AppConstants {
  // App info
  static const String appName = 'Me Leva Noronha';
  static const String appTagline = 'Seu guia completo para Fernando de Noronha';
  
  // WhatsApp
  static const String whatsappNumber = '5581999999999';
  static const String whatsappBaseUrl = 'https://wa.me/';
  
  // URLs externas
  static const String googleMapsUrl = 'https://www.google.com/maps/place/Fernando+de+Noronha';
  
  // Preços e taxas (para calculadora)
  static const double tpaDaily = 79.20; // Taxa de Preservação Ambiental por dia
  static const double parnamar = 222.0; // Ingresso PARNAMAR
  static const int tpaMaxDays = 10; // Máximo de dias para TPA
  
  // API Base URL
  // Para desenvolvimento local:
  // - Android emulator: http://10.0.2.2:8080
  // - iOS simulator / Web local: http://localhost:8080


  static const String apiBaseUrl = 'http://localhost:8080';
  // static const String apiBaseUrl = 'https://me-leva-noronha-ms-homolog.up.railway.app';

  // Coordenadas de Fernando de Noronha (para API de clima)
  static const double noronhaLatitude = -3.8548;
  static const double noronhaLongitude = -32.4233;
  
  // Imagens placeholder
  static const String heroImageUrl = 'https://images.unsplash.com/photo-1645985118085-69c21faf8303?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxGZXJuYW5kbyUyMGRlJTIwTm9yb25oYSUyMGJlYWNoJTIwcGFyYWRpc2V8ZW58MXx8fHwxNzYwOTI3NTU4fDA&ixlib=rb-4.1.0&q=80&w=1080';
}

/// Endpoints da API
class ApiEndpoints {
  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  
  // Tábua de marés
  static const String tides = '/api/tabuamare';
  
  // Dicas
  static const String tips = '/api/dicas';
  static String tipImage(int id) => '/api/dicas/$id/imagem';
  static String tipIcon(int id) => '/api/dicas/$id/icone';
  
  // Vida noturna
  static const String nightlife = '/api/vida-noturna';
  static String nightlifeImage(int id) => '/api/vida-noturna/$id/imagem';
  
  // Passeios
  static const String tours = '/api/passeios';
  static String tourImage(int id) => '/api/passeios/$id/imagem';
  
  // Restaurantes
  static const String restaurants = '/api/restaurantes';
  static String restaurantImage(int id) => '/api/restaurantes/$id/imagem';
  
  // Pontos de interesse
  static const String pointsOfInterest = '/api/pontos-interesse';
  
  // Previsão do tempo (pública)
  static const String weatherForecast = '/api/weather/forecast';
  static const String weatherCurrent = '/api/weather/current';
  
  // Calculadora de viagem
  static const String calculatorCapitals = '/api/calculadora-viagem/capitais';
  static const String calculatorTours = '/api/calculadora-viagem/passeios';
  static const String calculatorFlights = '/api/calculadora-viagem/passagens';
  static const String calculatorCosts = '/api/calculadora-viagem/calcular';
  static const String calculatorComplete = '/api/calculadora-viagem/calcular-completo';
  
  // Calculadora de táxi
  static const String taxiCalculator = '/api/taxi/calcular';
}

/// Mensagens padrão do WhatsApp
class WhatsAppMessages {
  static const String defaultGreeting = 'Olá! Gostaria de mais informações sobre passeios em Fernando de Noronha.';
  static const String tourBooking = 'Olá! Gostaria de agendar um passeio.';
  static const String taxiRequest = 'Olá! Preciso de um táxi.';
  static String restaurantMenu(String name) => 'Olá! Gostaria de ver o cardápio do $name';
  static String restaurantReservation(String name) => 'Olá! Gostaria de fazer uma reserva no $name';
  static String restaurantOrder(String name) => 'Olá! Gostaria de fazer um pedido no $name';
}
