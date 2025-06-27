import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/tipo_servico.dart';
import '../../../shared/providers/repository_providers.dart';

final tipoServicoDetailProvider = FutureProvider.family<TipoServico, int>((ref, servicoId) async {
  final repository = ref.watch(tipoServicoRepositoryProvider);
  return repository.getTipoServicoById(servicoId);
});
