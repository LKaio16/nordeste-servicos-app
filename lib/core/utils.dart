import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_constants.dart';

/// Utilitários gerais do app
class AppUtils {
  /// Formata valor monetário
  static String formatMoney(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Abre link no navegador
  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Abre WhatsApp com mensagem
  static Future<void> openWhatsApp({
    String? number,
    String? message,
  }) async {
    final phone = number ?? AppConstants.whatsappNumber;
    final msg = message ?? WhatsAppMessages.defaultGreeting;
    final url = '${AppConstants.whatsappBaseUrl}$phone?text=${Uri.encodeComponent(msg)}';
    await openUrl(url);
  }

  /// Faz ligação telefônica
  static Future<void> makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final url = 'tel:$cleanNumber';
    await openUrl(url);
  }

  /// Abre Google Maps para Fernando de Noronha
  static Future<void> openGoogleMaps() async {
    await openUrl(AppConstants.googleMapsUrl);
  }

  /// Retorna saudação baseada no horário
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom dia';
    } else if (hour < 18) {
      return 'Boa tarde';
    } else {
      return 'Boa noite';
    }
  }

  /// Retorna dia da semana em português
  static String getDayOfWeek(DateTime date) {
    const days = [
      'Domingo',
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
    ];
    return days[date.weekday % 7];
  }

  /// Retorna mês em português
  static String getMonth(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return months[month - 1];
  }

  /// Formata data completa
  static String formatDate(DateTime date) {
    return '${getDayOfWeek(date)}, ${date.day} de ${getMonth(date.month)}';
  }

  /// Mostra snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}







