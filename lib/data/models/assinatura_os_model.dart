// lib/data/models/assinatura_os_model.dart

import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/assinatura_os.dart';
// Importar entidade se usar a camada domain
// import 'package:nordeste_servicos/domain/entities/assinatura_os.dart';

part 'assinatura_os_model.g.dart';

@JsonSerializable()
class AssinaturaOSModel {
  final int? id;
  final int ordemServicoId;

  final String urlAcesso;
  final String tipoConteudo;
  final int? tamanhoArquivo;
  final DateTime dataHoraColeta;

  AssinaturaOSModel({
    this.id,
    required this.ordemServicoId,
    required this.urlAcesso,
    required this.tipoConteudo,
    this.tamanhoArquivo,
    required this.dataHoraColeta,
  });

  factory AssinaturaOSModel.fromJson(Map<String, dynamic> json) => _$AssinaturaOSModelFromJson(json);
  Map<String, dynamic> toJson() => _$AssinaturaOSModelToJson(this);

// Método para converter para Entity (se usar camada domain) - COMENTADO
  AssinaturaOS toEntity() {
    return AssinaturaOS(
      id: id,
      ordemServicoId: ordemServicoId,
      urlAcesso: urlAcesso,
      tipoConteudo: tipoConteudo,
      tamanhoArquivo: tamanhoArquivo,
      dataHoraColeta: dataHoraColeta,
    );
  }
}