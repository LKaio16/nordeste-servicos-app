// lib/presentation/features/dashboard/providers/desempenho_tecnico_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/desempenho_tecnico.dart';
import '../../../shared/providers/repository_providers.dart';

final desempenhoTecnicoProvider = FutureProvider<List<DesempenhoTecnico>>((ref) async {
  final repository = ref.watch(usuarioRepositoryProvider);
  return repository.getDesempenhoTecnicos();
});