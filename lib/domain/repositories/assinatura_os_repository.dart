// lib/domain/repositories/assinatura_os_repository.dart

import 'dart:io'; // Para File

import '../entities/assinatura_os.dart';

abstract class AssinaturaOsRepository {
  /// Obtém a assinatura para uma OS específica (se existir).
  /// Retorna null se não houver assinatura.
  Future<AssinaturaOS?> getAssinaturaByOsId(int osId);

   /// Obtém a assinatura pelo seu ID.
  Future<AssinaturaOS> getAssinaturaById(int id);


  /// Faz upload ou atualiza a assinatura para uma OS.
  Future<AssinaturaOS> uploadAssinatura(int osId, File signatureFile); // Ou String path, ou List<int> bytes

  /// Deleta a assinatura para uma OS específica.
  Future<void> deleteAssinaturaByOsId(int osId); // Deleta pelo ID da OS
}