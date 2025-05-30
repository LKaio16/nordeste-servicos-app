// lib/presentation/features/cliente/providers/novo_cliente_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importar estado, repositório, DTO e enum
import '../../../../core/error/exceptions.dart';
import '../../../../data/models/cliente_request_dto.dart';
import '../../../../data/models/tipo_cliente.dart';
import '../../../../domain/repositories/cliente_repository.dart';
import '../../../shared/providers/repository_providers.dart';
import 'novo_cliente_state.dart';


// Provider que expõe o StateNotifier
final novoClienteProvider = StateNotifierProvider<NovoClienteNotifier, NovoClienteState>((ref) {
  // Obtém a instância do repositório através do provider
  final clienteRepository = ref.watch(clienteRepositoryProvider);
  return NovoClienteNotifier(clienteRepository);
});

// O Notifier que gerencia o estado da tela NovoCliente
class NovoClienteNotifier extends StateNotifier<NovoClienteState> {
  final ClienteRepository _clienteRepository;

  NovoClienteNotifier(this._clienteRepository) : super(const NovoClienteState());

  // Método para salvar o cliente
  Future<void> salvarCliente({
    required TipoCliente tipoCliente,
    required String nomeCompleto,
    required String cpfCnpj,
    required String email,
    required String telefonePrincipal,
    String? telefoneAdicional,
    required String cep,
    required String rua,
    required String numero,
    String? complemento,
    required String bairro,
    required String cidade,
    required String estado,
  }) async {
    // Limpa estado anterior e inicia carregamento
    state = const NovoClienteState(isSubmitting: true);

    try {
      // Cria o DTO com os dados recebidos
      final dto = ClienteRequestDTO(
        tipoCliente: tipoCliente,
        nomeCompleto: nomeCompleto,
        cpfCnpj: cpfCnpj,
        email: email,
        telefonePrincipal: telefonePrincipal,
        telefoneAdicional: telefoneAdicional,
        cep: cep,
        rua: rua,
        numero: numero,
        complemento: complemento,
        bairro: bairro,
        cidade: cidade,
        estado: estado,
      );

      // Chama o método do repositório para criar o cliente
      await _clienteRepository.createCliente(dto);

      // Define o estado como sucesso (sem erro e não está mais enviando)
      state = state.copyWith(isSubmitting: false);

    } on ApiException catch (e) {
      // Define o estado com a mensagem de erro da API
      state = state.copyWith(isSubmitting: false, submissionError: e.message);
    } catch (e) {
      // Define o estado com uma mensagem de erro genérica
      state = state.copyWith(isSubmitting: false, submissionError: 'Ocorreu um erro inesperado ao salvar o cliente.');
    }
  }
}

