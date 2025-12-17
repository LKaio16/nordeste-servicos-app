import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/recibo.dart';
import '../../../../domain/repositories/recibo_repository.dart';
import '../../../shared/providers/repository_providers.dart';

final reciboDetailProvider = FutureProvider.family<Recibo, int>((ref, reciboId) async {
  final repository = ref.watch(reciboRepositoryProvider);
  return repository.getReciboById(reciboId);
});


