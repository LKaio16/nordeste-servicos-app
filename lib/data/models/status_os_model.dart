// lib/data/models/status_os_model.dart

import 'package:json_annotation/json_annotation.dart';

@JsonEnum(fieldRename: FieldRename.none)
enum StatusOSModel {
  EM_ABERTO,
  ATRIBUIDA,
  EM_ANDAMENTO,
  PENDENTE_PECAS,
  AGUARDANDO_APROVACAO,
  CONCLUIDA,
  ENCERRADA,
  CANCELADA,
}