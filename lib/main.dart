// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordeste_servicos_app/presentation/features/auth/presentation/screens/login_screen.dart'; // Importe a tela de Login


void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nordeste Serviços OS App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Remova initialRoute e onGenerateRoute se estiver definindo home
      home: LoginScreen(), // Define a tela de Login como a tela inicial

      // Se quiser usar rotas nomeadas, configure aqui e use initialRoute: '/login'
      /*
      initialRoute: '/login',
      routes: {
         '/login': (context) => LoginScreen(),
         // '/dashboard': (context) => DashboardScreen(), // Tela após o login
      },
      */

      debugShowCheckedModeBanner: false,
    );
  }
}