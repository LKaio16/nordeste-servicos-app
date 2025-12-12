import 'package:dio/dio.dart';

class CepService {
  static final Dio _dio = Dio();

  static Future<Map<String, String>> buscarEnderecoPorCEP(String cep) async {
    try {
      // Remove formatação do CEP
      final cepLimpo = cep.replaceAll(RegExp(r'[^\d]'), '');
      
      // Valida se o CEP tem 8 dígitos
      if (cepLimpo.length != 8) {
        throw Exception('CEP deve ter 8 dígitos');
      }

      // Busca na API ViaCEP
      final response = await _dio.get('https://viacep.com.br/ws/$cepLimpo/json/');

      if (response.statusCode != 200) {
        throw Exception('Erro ao buscar CEP');
      }

      final data = response.data;

      // Verifica se o CEP foi encontrado
      if (data['erro'] == true) {
        throw Exception('CEP não encontrado');
      }

      return {
        'rua': data['logradouro'] ?? '',
        'bairro': data['bairro'] ?? '',
        'cidade': data['localidade'] ?? '',
        'estado': data['uf'] ?? '',
      };
    } catch (e) {
      throw Exception('Erro ao buscar CEP: ${e.toString()}');
    }
  }
}


