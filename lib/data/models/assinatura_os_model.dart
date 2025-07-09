import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/assinatura_os.dart';

part 'assinatura_os_model.g.dart';

@JsonSerializable()
class AssinaturaOSModel {
  final int? id;
  final int ordemServicoId;

  // Campos alterados para refletir a nova estrutura da entidade
  final String? assinaturaClienteBase64;
  final String? nomeClienteResponsavel;
  final String? documentoClienteResponsavel;
  final String? assinaturaTecnicoBase64;
  final String? nomeTecnicoResponsavel;
  final DateTime? dataHoraColeta;

  AssinaturaOSModel({
    this.id,
    required this.ordemServicoId,
    this.assinaturaClienteBase64,
    this.nomeClienteResponsavel,
    this.documentoClienteResponsavel,
    this.assinaturaTecnicoBase64,
    this.nomeTecnicoResponsavel,
    this.dataHoraColeta,
  });

  factory AssinaturaOSModel.fromJson(Map<String, dynamic> json) =>
      _$AssinaturaOSModelFromJson(json);

  Map<String, dynamic> toJson() => _$AssinaturaOSModelToJson(this);

  // Método para converter o Model para a Entidade de domínio
  AssinaturaOS toEntity() {
    return AssinaturaOS(
      id: id,
      ordemServicoId: ordemServicoId,
      assinaturaClienteBase64: assinaturaClienteBase64,
      nomeClienteResponsavel: nomeClienteResponsavel,
      documentoClienteResponsavel: documentoClienteResponsavel,
      assinaturaTecnicoBase64: assinaturaTecnicoBase64,
      nomeTecnicoResponsavel: nomeTecnicoResponsavel,
      dataHoraColeta: dataHoraColeta,
    );
  }
}