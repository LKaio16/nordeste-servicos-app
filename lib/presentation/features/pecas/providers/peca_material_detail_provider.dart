import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/peca_material.dart';
import '../../../shared/providers/repository_providers.dart';

final pecaMaterialDetailProvider = FutureProvider.family<PecaMaterial, int>((ref, pecaId) async {
  final repository = ref.watch(pecaMaterialRepositoryProvider);
  return repository.getPecaMaterialById(pecaId);
});