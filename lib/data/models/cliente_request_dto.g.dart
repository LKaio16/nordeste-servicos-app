// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cliente_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClienteRequestDTO _$ClienteRequestDTOFromJson(Map<String, dynamic> json) =>
    ClienteRequestDTO(
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

Map<String, dynamic> _$ClienteRequestDTOToJson(ClienteRequestDTO instance) =>
    <String, dynamic>{
      'tipoCliente': _$TipoClienteEnumMap[instance.tipoCliente]!,
      'nomeCompleto': instance.nomeCompleto,
      'cpfCnpj': instance.cpfCnpj,
      'email': instance.email,
      'telefonePrincipal': instance.telefonePrincipal,
      if (instance.telefoneAdicional case final value?)
        'telefoneAdicional': value,
      'cep': instance.cep,
      'rua': instance.rua,
      'numero': instance.numero,
      if (instance.complemento case final value?) 'complemento': value,
      'bairro': instance.bairro,
      'cidade': instance.cidade,
      'estado': instance.estado,
    };

const _$TipoClienteEnumMap = {
  TipoCliente.PESSOA_FISICA: 'PESSOA_FISICA',
  TipoCliente.PESSOA_JURIDICA: 'PESSOA_JURIDICA',
};
