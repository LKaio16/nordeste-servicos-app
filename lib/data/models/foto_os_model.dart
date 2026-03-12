// lib/data/models/foto_os_model.dart

import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/foto_os.dart';

part 'foto_os_model.g.dart';

int _ordemServicoIdFromJson(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// Converte valores do JSON de forma null-safe para evitar TypeError ao parsear.
DateTime _parseDataUpload(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return DateTime.now();
}

@JsonSerializable()
class FotoOSModel {
  final int? id;
  @JsonKey(fromJson: _ordemServicoIdFromJson)
  final int ordemServicoId;
  final String? fotoBase64; // Legado (OS antigas sem GCloud)
  final String? fotoUrl; // URL no Google Cloud Storage
  final String? descricao;
  final String? nomeArquivoOriginal;
  final String? tipoConteudo;
  final int? tamanhoArquivo;
  @JsonKey(fromJson: _parseDataUpload)
  final DateTime dataUpload;

  FotoOSModel({
    this.id,
    required this.ordemServicoId,
    this.fotoBase64,
    this.fotoUrl,
    this.descricao,
    this.nomeArquivoOriginal,
    this.tipoConteudo,
    this.tamanhoArquivo,
    required this.dataUpload,
  });

  factory FotoOSModel.fromJson(Map<String, dynamic> json) => _$FotoOSModelFromJson(json);
  Map<String, dynamic> toJson() => _$FotoOSModelToJson(this);

  FotoOS toEntity() {
    return FotoOS(
      id: id,
      ordemServicoId: ordemServicoId,
      fotoBase64: fotoBase64,
      fotoUrl: fotoUrl,
      descricao: descricao,
      nomeArquivoOriginal: nomeArquivoOriginal,
      tipoConteudo: tipoConteudo,
      tamanhoArquivo: tamanhoArquivo,
      dataUpload: dataUpload,
    );
  }
}