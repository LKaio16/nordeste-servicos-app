import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClienteDetailScreen extends StatelessWidget {
  final int clienteId;
  const ClienteDetailScreen({Key? key, required this.clienteId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalhes do Cliente #$clienteId', style: GoogleFonts.poppins())),
      body: Center(child: Text('Exibindo detalhes do cliente com ID: $clienteId', style: GoogleFonts.poppins())),
    );
  }
}