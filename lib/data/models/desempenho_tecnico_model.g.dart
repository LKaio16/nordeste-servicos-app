// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'desempenho_tecnico_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DesempenhoTecnicoModel _$DesempenhoTecnicoModelFromJson(
        Map<String, dynamic> json) =>
    DesempenhoTecnicoModel(
      id: (json['id'] as num).toInt(),
      nome: json['nome'] as String,
      fotoPerfil: json['fotoPerfil'] as String?,
      totalOS: (json['totalOS'] as num).toInt(),
      desempenho: (json['desempenho'] as num).toDouble(),
    );

Map<String, dynamic> _$DesempenhoTecnicoModelToJson(
        DesempenhoTecnicoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'fotoPerfil': instance.fotoPerfil,
      'totalOS': instance.totalOS,
      'desempenho': instance.desempenho,
    };
