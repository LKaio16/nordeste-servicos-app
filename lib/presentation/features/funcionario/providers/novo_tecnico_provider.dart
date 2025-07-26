import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:nordeste_servicos_app/config/app_config.dart';
import 'novo_tecnico_state.dart';

// TODO: Substitua pela URL base da sua API
const String _apiBaseUrl = AppConfig.apiBaseUrl;

// Função utilitária para converter texto para title case (primeira letra maiúscula)
String _toTitleCase(String text) {
  if (text.isEmpty) return text;
  
  // Remove espaços extras e divide em palavras
  final words = text.trim().split(RegExp(r'\s+'));
  
  if (words.isEmpty) return text;
  
  // Converte cada palavra para title case (primeira letra maiúscula)
  List<String> titleCaseWords = [];
  for (String word in words) {
    if (word.isNotEmpty) {
      titleCaseWords.add(word[0].toUpperCase() + word.substring(1).toLowerCase());
    }
  }
  
  return titleCaseWords.join(' ');
}

final novoTecnicoProvider = StateNotifierProvider.autoDispose<
    NovoTecnicoNotifier, NovoTecnicoState>((ref) {
  return NovoTecnicoNotifier();
});

class NovoTecnicoNotifier extends StateNotifier<NovoTecnicoState> {
  NovoTecnicoNotifier() : super(NovoTecnicoState()); // Corrigido: Usa construtor padrão

  Future<void> createUsuario({
    required String nome,
    required String cracha,
    required String email,
    required String senha,
  }) async {
    state = state.copyWith(isSubmitting: true, submissionError: null);

    try {
      // Aplicar title case ao nome antes de enviar
      final nomeTitleCase = _toTitleCase(nome);
      
      final url = Uri.parse('$_apiBaseUrl/usuarios');
      final body = jsonEncode({
        'nome': nomeTitleCase, // Nome convertido para title case
        'cracha': cracha,
        'email': email,
        'senha': senha,
        'perfil': 'TECNICO', // Definindo o perfil como TECNICO
      });

      // TODO: Adicione headers de autenticação se necessário (ex: Bearer token)
      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        // 'Authorization': 'Bearer SEU_TOKEN_JWT',
      };

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201) { // 201 Created
        state = state.copyWith(isSubmitting: false, submissionError: null);
        // Opcional: você pode querer limpar o estado ou navegar para outra tela aqui
      } else {
        // Tenta decodificar a mensagem de erro do corpo da resposta
        String errorMessage = 'Erro ao criar técnico: ${response.statusCode}';
        try {
          final responseBody = jsonDecode(response.body);
          if (responseBody is Map && responseBody.containsKey('message')) {
            errorMessage = responseBody['message'];
          } else {
            errorMessage = response.body; // Usa o corpo bruto se não for JSON esperado
          }
        } catch (e) {
          errorMessage = 'Erro ao criar técnico (resposta inválida): ${response.body}';
        }
        state = state.copyWith(isSubmitting: false, submissionError: errorMessage);
      }
    } catch (e) {
      state = state.copyWith(
          isSubmitting: false, submissionError: 'Erro de conexão: ${e.toString()}');
    }
  }
}

