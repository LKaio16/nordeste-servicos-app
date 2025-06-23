import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/usuario.dart';
import '../../../../domain/repositories/usuario_repository.dart';
import '../../../shared/providers/repository_providers.dart';

// Este provider busca um usuário/funcionário específico pelo seu ID.
final funcionarioDetailProvider = FutureProvider.family<Usuario, int>((ref, funcionarioId) async {
  final repository = ref.watch(usuarioRepositoryProvider);
  // Usando o método que você já tem
  return repository.getUserById(funcionarioId);
});