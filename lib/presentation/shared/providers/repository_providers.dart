// lib/presentation/shared/providers/repository_providers.dart

// Importe os pacotes necessários do Riverpod
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importe as classes que você quer prover (ApiClient e implementações de repositório)
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../data/repositories/cliente_repository_impl.dart';
import '../../../domain/repositories/cliente_repository.dart'; // Importe a interface
import '../../../data/repositories/usuario_repository_impl.dart';
import '../../../domain/repositories/usuario_repository.dart';
import '../../../data/repositories/equipamento_repository_impl.dart';
import '../../../domain/repositories/equipamento_repository.dart';
import '../../../data/repositories/os_repository_impl.dart';
import '../../../domain/repositories/os_repository.dart';
import '../../../data/repositories/orcamento_repository_impl.dart';
import '../../../domain/repositories/orcamento_repository.dart';
import '../../../data/repositories/item_orcamento_repository_impl.dart';
import '../../../domain/repositories/item_orcamento_repository.dart';
import '../../../data/repositories/item_os_utilizado_repository_impl.dart';
import '../../../domain/repositories/item_os_utilizado_repository.dart';
import '../../../data/repositories/registro_tempo_repository_impl.dart';
import '../../../domain/repositories/registro_tempo_repository.dart';
import '../../../data/repositories/registro_deslocamento_repository_impl.dart';
import '../../../domain/repositories/registro_deslocamento_repository.dart';
import '../../../data/repositories/foto_os_repository_impl.dart';
import '../../../domain/repositories/foto_os_repository.dart';
import '../../../data/repositories/assinatura_os_repository_impl.dart';
import '../../../domain/repositories/assinatura_os_repository.dart';
import '../../../data/repositories/peca_material_repository_impl.dart';
import '../../../domain/repositories/peca_material_repository.dart';
import '../../../data/repositories/tipo_servico_repository_impl.dart';
import '../../../domain/repositories/tipo_servico_repository.dart';

final dioProvider = Provider<Dio>((ref) => Dio());
// Provider para o ApiClient
// Ele cria uma instância única do ApiClient que pode ser acessada em toda a aplicação.
// Atualize o provider do ApiClient para injetar o SecureStorageService
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.read(dioProvider);
  final secureStorageService = ref.read(secureStorageServiceProvider);
  return ApiClient(dio, secureStorageService);
});

// Provider para ClienteRepository (implementação)
// Depende do apiClientProvider para obter a instância de ApiClient
final clienteRepositoryProvider = Provider<ClienteRepository>((ref) {
  // ref.read(apiClientProvider) obtém a instância do ApiClient
  return ClienteRepositoryImpl(ref.read(apiClientProvider));
});

// Provider para UsuarioRepository (implementação)
final usuarioRepositoryProvider = Provider<UsuarioRepository>((ref) {
  return UsuarioRepositoryImpl(ref.read(apiClientProvider));
});

// Provider para EquipamentoRepository (implementação)
final equipamentoRepositoryProvider = Provider<EquipamentoRepository>((ref) {
  return EquipamentoRepositoryImpl(ref.read(apiClientProvider));
});

// Provider para OsRepository (implementação)
final osRepositoryProvider = Provider<OsRepository>((ref) {
  return OsRepositoryImpl(ref.read(apiClientProvider));
});

// Provider para ItemOrcamentoRepository (implementação)
final itemOrcamentoRepositoryProvider = Provider<ItemOrcamentoRepository>((ref) {
  return ItemOrcamentoRepositoryImpl(ref.read(apiClientProvider));
});

// Provider para ItemOSUtilizadoRepository (implementação)
final itemOsUtilizadoRepositoryProvider = Provider<ItemOSUtilizadoRepository>((ref) {
  return ItemOSUtilizadoRepositoryImpl(ref.read(apiClientProvider));
});

// Provider para RegistroTempoRepository (implementação)
final registroTempoRepositoryProvider = Provider<RegistroTempoRepository>((ref) {
  return RegistroTempoRepositoryImpl(ref.read(apiClientProvider));
});

// Provider para RegistroDeslocamentoRepository (implementação)
final registroDeslocamentoRepositoryProvider = Provider<RegistroDeslocamentoRepository>((ref) {
  return RegistroDeslocamentoRepositoryImpl(ref.read(apiClientProvider));
});

// Provider para FotoOsRepository (implementação)
final fotoOsRepositoryProvider = Provider<FotoOsRepository>((ref) {
  return FotoOsRepositoryImpl(ref.read(apiClientProvider));
});

// Provider para AssinaturaOsRepository (implementação)
final assinaturaOsRepositoryProvider = Provider<AssinaturaOsRepository>((ref) {
  return AssinaturaOsRepositoryImpl(ref.read(apiClientProvider));
});

// Provider para PecaMaterialRepository (implementação)
final pecaMaterialRepositoryProvider = Provider<PecaMaterialRepository>((ref) {
  return PecaMaterialRepositoryImpl(ref.read(apiClientProvider));
});

// Provider para TipoServicoRepository (implementação)
final tipoServicoRepositoryProvider = Provider<TipoServicoRepository>((ref) {
  return TipoServicoRepositoryImpl(ref.read(apiClientProvider));
});

final orcamentoRepositoryProvider = Provider<OrcamentoRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return OrcamentoRepositoryImpl(apiClient);
});

// TODO: Adicionar providers para Use Cases aqui se você os criar na camada domain/usecases
// Ex:
/*
final getClientesUseCaseProvider = Provider<GetClientesUseCase>((ref) {
  return GetClientesUseCase(ref.read(clienteRepositoryProvider));
});
*/