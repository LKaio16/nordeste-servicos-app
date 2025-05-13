// lib/data/models/perfil_usuario_model.dart

import 'package:json_annotation/json_annotation.dart';

// Indica ao json_serializable para usar os nomes dos enums como strings
@JsonEnum(fieldRename: FieldRename.none)
enum PerfilUsuarioModel {
  ADMIN,
  TECNICO,
  // Adicione outros perfis se houver
}