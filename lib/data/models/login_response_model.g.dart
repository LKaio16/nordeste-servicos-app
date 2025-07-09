// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponseModel _$LoginResponseModelFromJson(Map<String, dynamic> json) =>
    LoginResponseModel(
      id: (json['id'] as num?)?.toInt(),
      nome: json['nome'] as String,
      cracha: json['cracha'] as String,
      email: json['email'] as String,
      perfil: $enumDecode(_$PerfilUsuarioModelEnumMap, json['perfil']),
      token: json['token'] as String,
      fotoPerfil: json['fotoPerfil'] as String?,
    );

Map<String, dynamic> _$LoginResponseModelToJson(LoginResponseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'cracha': instance.cracha,
      'email': instance.email,
      'perfil': _$PerfilUsuarioModelEnumMap[instance.perfil]!,
      'token': instance.token,
      'fotoPerfil': instance.fotoPerfil,
    };

const _$PerfilUsuarioModelEnumMap = {
  PerfilUsuarioModel.ADMIN: 'ADMIN',
  PerfilUsuarioModel.TECNICO: 'TECNICO',
};
