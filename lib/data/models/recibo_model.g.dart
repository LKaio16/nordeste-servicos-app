// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recibo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReciboModel _$ReciboModelFromJson(Map<String, dynamic> json) => ReciboModel(
      id: (json['id'] as num?)?.toInt(),
      valor: (json['valor'] as num).toDouble(),
      cliente: json['cliente'] as String,
      referenteA: json['referenteA'] as String,
      dataCriacao: DateTime.parse(json['dataCriacao'] as String),
      numeroRecibo: json['numeroRecibo'] as String,
    );

Map<String, dynamic> _$ReciboModelToJson(ReciboModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'valor': instance.valor,
      'cliente': instance.cliente,
      'referenteA': instance.referenteA,
      'dataCriacao': instance.dataCriacao.toIso8601String(),
      'numeroRecibo': instance.numeroRecibo,
    };
