// lib/data/models/fornecedor_model.dart

import '../../domain/entities/fornecedor.dart';

class FornecedorModel {
  final int? id;
  final String nome;
  final String? cnpj;
  final String? email;
  final String? telefone;
  final String? endereco;
  final String? cidade;
  final String? estado;
  final String? status;
  final String? observacoes;

  FornecedorModel({
    this.id,
    required this.nome,
    this.cnpj,
    this.email,
    this.telefone,
    this.endereco,
    this.cidade,
    this.estado,
    this.status,
    this.observacoes,
  });

  factory FornecedorModel.fromJson(Map<String, dynamic> json) {
    return FornecedorModel(
      id: (json['id'] as num?)?.toInt(),
      nome: json['nome'] as String? ?? '',
      cnpj: json['cnpj'] as String?,
      email: json['email'] as String?,
      telefone: json['telefone'] as String?,
      endereco: json['endereco'] as String?,
      cidade: json['cidade'] as String?,
      estado: json['estado'] as String?,
      status: json['status'] as String?,
      observacoes: json['observacoes'] as String?,
    );
  }

  Fornecedor toEntity() {
    return Fornecedor(
      id: id,
      nome: nome,
      cnpj: cnpj,
      email: email,
      telefone: telefone,
      endereco: endereco,
      cidade: cidade,
      estado: estado,
      status: status,
      observacoes: observacoes,
    );
  }
}
