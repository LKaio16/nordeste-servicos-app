import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/cliente.dart';
import '../../../../domain/repositories/cliente_repository.dart';
import '../../../shared/providers/repository_providers.dart';

// Este provider busca um cliente específico pelo seu ID
final clienteDetailProvider = FutureProvider.family<Cliente, int>((ref, clienteId) async {
  // Obtém o repositório de cliente
  final repository = ref.watch(clienteRepositoryProvider);
  // Chama o método para buscar o cliente por ID
  return repository.getClienteById(clienteId);
});