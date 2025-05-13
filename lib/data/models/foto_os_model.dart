// lib/data/models/foto_os_model.dart

import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/foto_os.dart';
// Importar entidade se usar a camada domain
// import 'package:nordeste_servicos/domain/entities/foto_os.dart';

part 'foto_os_model.g.dart';

@JsonSerializable()
class FotoOSModel {
  final int? id;
  final int ordemServicoId;
  final String urlAcesso;
  final String nomeArquivoOriginal;
  final String tipoConteudo;
  final int? tamanhoArquivo;
  final DateTime dataUpload;

  FotoOSModel({
    this.id,
    required this.ordemServicoId,
    required this.urlAcesso,
    required this.nomeArquivoOriginal,
    required this.tipoConteudo,
    this.tamanhoArquivo,
    required this.dataUpload,
  });

  factory FotoOSModel.fromJson(Map<String, dynamic> json) => _$FotoOSModelFromJson(json);
  Map<String, dynamic> toJson() => _$FotoOSModelToJson(this);

// Método para converter para Entity (se usar camada domain) - COMENTADO
  FotoOS toEntity() {
    return FotoOS(
      id: id,
      ordemServicoId: ordemServicoId,
      urlAcesso: urlAcesso,
      nomeArquivoOriginal: nomeArquivoOriginal,
      tipoConteudo: tipoConteudo,
      tamanhoArquivo: tamanhoArquivo,
      dataUpload: dataUpload,
    );
  }
}