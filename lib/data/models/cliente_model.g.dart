// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cliente_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClienteModel _$ClienteModelFromJson(Map<String, dynamic> json) => ClienteModel(
      id: (json['id'] as num).toInt(),
      tipoCliente: $enumDecode(_$TipoClienteEnumMap, json['tipoCliente']),
      nomeCompleto: json['nomeCompleto'] as String,
      cpfCnpj: json['cpfCnpj'] as String,
      email: json['email'] as String,
      telefonePrincipal: json['telefonePrincipal'] as String,
      telefoneAdicional: json['telefoneAdicional'] as String?,
      cep: json['cep'] as String,
      rua: json['rua'] as String,
      numero: json['numero'] as String,
      complemento: json['complemento'] as String?,
      bairro: json['bairro'] as String,
      cidade: json['cidade'] as String,
      estado: json['estado'] as String,
    );

Map<String, dynamic> _$ClienteModelToJson(ClienteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tipoCliente': _$TipoClienteEnumMap[instance.tipoCliente]!,
      'nomeCompleto': instance.nomeCompleto,
      'cpfCnpj': instance.cpfCnpj,
      'email': instance.email,
      'telefonePrincipal': instance.telefonePrincipal,
      'telefoneAdicional': instance.telefoneAdicional,
      'cep': instance.cep,
      'rua': instance.rua,
      'numero': instance.numero,
      'complemento': instance.complemento,
      'bairro': instance.bairro,
      'cidade': instance.cidade,
      'estado': instance.estado,
    };

const _$TipoClienteEnumMap = {
  TipoCliente.PESSOA_FISICA: 'PESSOA_FISICA',
  TipoCliente.PESSOA_JURIDICA: 'PESSOA_JURIDICA',
};
