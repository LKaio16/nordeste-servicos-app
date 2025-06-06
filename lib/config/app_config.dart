// lib/config/app_config.dart

class AppConfig {
  // TODO: Substituir pela URL base da sua API local ou em produção
  static const String apiBaseUrl = 'https://d0b4-2804-29b8-518f-8dbb-30d6-16d5-3cb8-63d4.ngrok-free.app/api';
  // static const String apiBaseUrl = 'http://192.168.0.2:8080/api'; // Exemplo: http://192.168.1.100:8080/api
  // Se usar emulador Android e a API estiver no localhost da máquina: http://10.0.2.2:8080/api
  // Se usar simulador iOS e a API estiver no localhost da máquina: http://localhost:8080/api

  // Outras configurações globais podem vir aqui
  static const int apiTimeoutSeconds = 30;
}