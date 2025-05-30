// lib/presentation/features/orcamentos/providers/orcamento_dashboard_state.dart

import 'package:flutter/foundation.dart';
import '../../dashboard/models/dashboard_data.dart';
import '../../home/screens/admin_home_screen.dart'; // Importe seu DashboardData

class OrcamentoDashboardState {
  final DashboardData? data;
  final bool isLoading;
  final String? errorMessage;

  OrcamentoDashboardState({
    this.data,
    this.isLoading = true, // Inicia carregando
    this.errorMessage,
  });

  OrcamentoDashboardState copyWith({
    DashboardData? data,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OrcamentoDashboardState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Permite limpar o erro passando null
    );
  }
}