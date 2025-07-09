// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsuarioModel _$UsuarioModelFromJson(Map<String, dynamic> json) => UsuarioModel(
      id: (json['id'] as num?)?.toInt(),
      nome: json['nome'] as String,
      cracha: json['cracha'] as String?,
      email: json['email'] as String?,
      perfil: $enumDecode(_$PerfilUsuarioModelEnumMap, json['perfil']),
      fotoPerfil: json['fotoPerfil'] as String?,
    );

Map<String, dynamic> _$UsuarioModelToJson(UsuarioModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'cracha': instance.cracha,
      'email': instance.email,
      'perfil': _$PerfilUsuarioModelEnumMap[instance.perfil]!,
      'fotoPerfil': instance.fotoPerfil,
    };

const _$PerfilUsuarioModelEnumMap = {
  PerfilUsuarioModel.ADMIN: 'ADMIN',
  PerfilUsuarioModel.TECNICO: 'TECNICO',
};
