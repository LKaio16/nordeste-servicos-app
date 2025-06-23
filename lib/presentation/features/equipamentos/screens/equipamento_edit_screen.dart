import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/equipamento.dart';

class EquipamentoEditScreen extends StatelessWidget {
  final Equipamento equipamento;
  const EquipamentoEditScreen({Key? key, required this.equipamento}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar ${equipamento.marcaModelo}', style: GoogleFonts.poppins())),
      body: Center(child: Text('Formulário de edição para o equipamento ID: ${equipamento.id}', style: GoogleFonts.poppins())),
    );
  }
}