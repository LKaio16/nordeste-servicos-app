// lib/data/models/prioridade_os_model.dart

import 'package:json_annotation/json_annotation.dart';

@JsonEnum(fieldRename: FieldRename.none)
enum PrioridadeOSModel {
  BAIXA,
  MEDIA,
  ALTA,
  URGENTE,
}