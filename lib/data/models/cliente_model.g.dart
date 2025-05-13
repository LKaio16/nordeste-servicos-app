// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cliente_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClienteModel _$ClienteModelFromJson(Map<String, dynamic> json) => ClienteModel(
      id: (json['id'] as num?)?.toInt(),
      nomeRazaoSocial: json['nomeRazaoSocial'] as String,
      endereco: json['endereco'] as String,
      telefone: json['telefone'] as String,
      email: json['email'] as String,
      cnpjCpf: json['cnpjCpf'] as String,
    );

Map<String, dynamic> _$ClienteModelToJson(ClienteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nomeRazaoSocial': instance.nomeRazaoSocial,
      'endereco': instance.endereco,
      'telefone': instance.telefone,
      'email': instance.email,
      'cnpjCpf': instance.cnpjCpf,
    };
