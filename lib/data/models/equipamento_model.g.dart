// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipamento_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EquipamentoModel _$EquipamentoModelFromJson(Map<String, dynamic> json) =>
    EquipamentoModel(
      id: (json['id'] as num?)?.toInt(),
      tipo: json['tipo'] as String,
      marcaModelo: json['marcaModelo'] as String,
      numeroSerieChassi: json['numeroSerieChassi'] as String,
      horimetro: (json['horimetro'] as num?)?.toDouble(),
      clienteId: (json['clienteId'] as num).toInt(),
    );

Map<String, dynamic> _$EquipamentoModelToJson(EquipamentoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tipo': instance.tipo,
      'marcaModelo': instance.marcaModelo,
      'numeroSerieChassi': instance.numeroSerieChassi,
      'horimetro': instance.horimetro,
      'clienteId': instance.clienteId,
    };
