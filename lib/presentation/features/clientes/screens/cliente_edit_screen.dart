import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/cliente.dart';

class ClienteEditScreen extends StatelessWidget {
  final Cliente cliente;
  const ClienteEditScreen({Key? key, required this.cliente}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar ${cliente.nomeCompleto}', style: GoogleFonts.poppins())),
      body: Center(child: Text('Formulário de edição para o cliente ID: ${cliente.id}', style: GoogleFonts.poppins())),
    );
  }
}