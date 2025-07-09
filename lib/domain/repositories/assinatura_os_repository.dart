// lib/domain/repositories/assinatura_os_repository.dart

import 'dart:io'; // Para File

import '../entities/assinatura_os.dart';

abstract class AssinaturaOsRepository {
  Future<AssinaturaOS?> getAssinaturaByOsId(int osId);
  Future<AssinaturaOS> uploadAssinatura(int osId, AssinaturaOS assinatura); // Alterado
  Future<void> deleteAssinaturaByOsId(int osId);
}