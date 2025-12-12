// lib/data/models/recibo_model.dart

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/recibo.dart';

part 'recibo_model.g.dart';

@JsonSerializable()
class ReciboModel {
  final int? id;
  final double valor;
  final String cliente;
  final String referenteA;
  @JsonKey(name: 'dataCriacao')
  final DateTime dataCriacao;
  final String numeroRecibo;

  ReciboModel({
    this.id,
    required this.valor,
    required this.cliente,
    required this.referenteA,
    required this.dataCriacao,
    required this.numeroRecibo,
  });

  factory ReciboModel.fromJson(Map<String, dynamic> json) => _$ReciboModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReciboModelToJson(this);

  Recibo toEntity() {
    return Recibo(
      id: id,
      valor: valor,
      cliente: cliente,
      referenteA: referenteA,
      dataCriacao: dataCriacao,
      numeroRecibo: numeroRecibo,
    );
  }
}

