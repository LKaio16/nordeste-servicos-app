// lib/data/models/status_orcamento_model.dart

import 'package:json_annotation/json_annotation.dart';

@JsonEnum(fieldRename: FieldRename.none)
enum StatusOrcamentoModel {
  PENDENTE,
  APROVADO,
  REJEITADO,
  CANCELADO,
}