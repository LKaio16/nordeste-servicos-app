// lib/presentation/common/app_colors.dart

import 'package:flutter/material.dart';

import '../../../data/models/prioridade_os_model.dart';
import '../../../data/models/status_os_model.dart';

class AppColors {
  // Cores principais
  static const Color primaryBlue = Color(0xFF1A73E8); // Azul principal mais vibrante
  static const Color secondaryBlue = Color(0xFF4285F4); // Azul secundário
  static const Color accentBlue = Color(0xFF8AB4F8); // Azul claro para acentos
  static const Color darkBlue = Color(0xFF0D47A1); // Azul escuro para detalhes

  // Cores de status
  static const Color successGreen = Color(0xFF34A853); // Verde mais moderno
  static const Color warningOrange = Color(0xFFCD8000); // Laranja mais vibrante
  static const Color errorRed = Color(0xFFEA4335); // Vermelho mais moderno
  static const Color infoBlue = Color(0xFF039BE5); // Azul informativo

  // Cores de fundo e texto
  static const Color backgroundGray = Color(0xFFF8F9FA); // Fundo cinza claro
  static const Color cardBackground = Colors.white; // Fundo dos cards
  static const Color textDark = Color(0xFF202124); // Texto escuro
  static const Color textLight = Color(0xFF5F6368); // Texto cinza
  static const Color dividerColor = Color(0xFFEEEEEE); // Cor para divisores

  static Color getStatusBackgroundColor(StatusOSModel status) {
    switch (status) {
      case StatusOSModel.CONCLUIDA:
      case StatusOSModel.ENCERRADA:
        return successGreen.withOpacity(0.1);
      case StatusOSModel.EM_ANDAMENTO:
        return warningOrange.withOpacity(0.1);
      case StatusOSModel.AGUARDANDO_APROVACAO:
        return infoBlue.withOpacity(0.1);
      case StatusOSModel.EM_ABERTO:
      case StatusOSModel.PENDENTE_PECAS:
        return primaryBlue.withOpacity(0.1);
      case StatusOSModel.CANCELADA:
        return errorRed.withOpacity(0.1);
      default:
        return Colors.grey.shade100;
    }
  }

  static Color getStatusTextColor(StatusOSModel status) {
    switch (status) {
      case StatusOSModel.CONCLUIDA:
      case StatusOSModel.ENCERRADA:
        return successGreen;
      case StatusOSModel.EM_ANDAMENTO:
        return warningOrange;
      case StatusOSModel.AGUARDANDO_APROVACAO:
        return infoBlue;
      case StatusOSModel.EM_ABERTO:
      case StatusOSModel.PENDENTE_PECAS:
        return primaryBlue;
      case StatusOSModel.CANCELADA:
        return errorRed;
      default:
        return textLight;
    }
  }

  static Color getPrioridadeColor(PrioridadeOSModel? prioridade) {
    switch (prioridade) {
      case PrioridadeOSModel.URGENTE:
        return errorRed;
      case PrioridadeOSModel.ALTA:
        return warningOrange;
      case PrioridadeOSModel.MEDIA:
        return primaryBlue;
      case PrioridadeOSModel.BAIXA:
        return successGreen;
      default:
        return textLight;
    }
  }
}