import 'package:json_annotation/json_annotation.dart';

// Adicione esta anotação acima do enum
@JsonEnum(alwaysCreate: true)
enum PrioridadeOSModel {
  // Adicione @JsonValue com a string EXATA que a API espera para cada valor
  @JsonValue('BAIXA')
  BAIXA,

  @JsonValue('MEDIA')
  MEDIA,

  @JsonValue('ALTA')
  ALTA,

  @JsonValue('URGENTE')
  URGENTE;

  // Opcional: Adicionar um getter para o valor, se útil em outros lugares
  String get apiValue {
    switch (this) {
      case PrioridadeOSModel.BAIXA: return 'BAIXA';
      case PrioridadeOSModel.MEDIA: return 'MEDIA';
      case PrioridadeOSModel.ALTA: return 'ALTA';
      case PrioridadeOSModel.URGENTE: return 'URGENTE';
    }
  }
}
