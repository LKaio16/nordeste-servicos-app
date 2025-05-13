// lib/domain/repositories/foto_os_repository.dart

import 'dart:io'; // Para File
import '../entities/foto_os.dart';
import '/core/error/exceptions.dart';

abstract class FotoOsRepository {
  /// Obtém a lista de fotos para uma OS específica.
  Future<List<FotoOS>> getFotosByOsId(int osId);

  /// Obtém uma foto pelo seu ID.
  Future<FotoOS> getFotoById(int id);

  /// Faz upload de uma nova foto para uma OS.
  /// Recebe o ID da OS e os dados da foto.
  Future<FotoOS> uploadFoto(int osId, File photoFile); // Ou String path, ou List<int> bytes

  /// Deleta uma foto pelo seu ID.
  Future<void> deleteFoto(int id);
}