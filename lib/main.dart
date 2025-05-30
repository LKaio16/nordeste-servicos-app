// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importações dos seus arquivos
import 'package:nordeste_servicos_app/presentation/features/auth/presentation/screens/login_screen.dart';
import 'package:nordeste_servicos_app/presentation/features/auth/providers/auth_provider.dart';
import 'package:nordeste_servicos_app/presentation/features/auth/providers/auth_state.dart';
import 'package:nordeste_servicos_app/presentation/features/home/screens/admin_home_screen.dart';
import 'package:nordeste_servicos_app/presentation/features/home/screens/home_screen_tecnico.dart';
import 'package:nordeste_servicos_app/presentation/features/home/providers/os_dashboard_data_provider.dart';
import 'package:nordeste_servicos_app/presentation/features/orcamentos/providers/orcamento_dashboard_provider.dart';
import 'package:nordeste_servicos_app/domain/entities/usuario.dart'; // Importe a entidade Usuario
import 'package:nordeste_servicos_app/data/models/perfil_usuario_model.dart'; // Importe o PerfilUsuarioModel
import 'package:nordeste_servicos_app/presentation/features/os/screens/nova_os_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authProvider, (previousState, newState) {
      if (newState.authenticatedUser != null && previousState?.authenticatedUser == null) {
        print('DEBUG: Usuário logado detectado. Acionando busca de dados do dashboard.');
        // Aciona a busca de dados para ambos os tipos de dashboard, se necessário
        ref.read(osDashboardProvider.notifier).fetchOsDashboardData();
        ref.read(orcamentoDashboardProvider.notifier).fetchOrcamentoDashboardData();
      } else if (newState.authenticatedUser == null && previousState?.authenticatedUser != null) {
        print('DEBUG: Usuário deslogado detectado. Limpando dados (opcional).');
      }
    });

    final authState = ref.watch(authProvider);

    Widget _getHomeScreen() {
      if (authState.authenticatedUser == null) {
        return LoginScreen();
      }

      // Verifique o perfil do usuário
      if (authState.authenticatedUser!.perfil == PerfilUsuarioModel.TECNICO) {
        return TecnicoHomeScreen();
      } else if (authState.authenticatedUser!.perfil == PerfilUsuarioModel.ADMIN) { // Supondo que 'ADMIN' seja o perfil do administrador
        return AdminHomeScreen();
      }
      // Caso um perfil não seja reconhecido ou seja um tipo diferente
      // Você pode definir uma tela padrão ou uma tela de erro aqui
      print('DEBUG: Perfil de usuário desconhecido: ${authState.authenticatedUser!.perfil}. Redirecionando para AdminHome como fallback.');
      return AdminHomeScreen(); // Fallback para AdminHomeScreen
    }

    return MaterialApp(
      title: 'Nordeste Serviços',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Use o método _getHomeScreen para decidir qual tela de início
      home: _getHomeScreen(),
      routes: {
        '/adminHome': (context) => const AdminHomeScreen(),
        '/tecnicoHome': (context) => const TecnicoHomeScreen(),
        '/nova-os': (context) => const NovaOsScreen(),// Adicione a rota para a tela do técnico
        // Se você não for navegar diretamente para o login via rota, não precisa aqui
        // '/login': (context) => LoginScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}