import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../core/utils.dart';

/// Botão do WhatsApp reutilizável
class WhatsAppButton extends StatelessWidget {
  final String text;
  final String? subtext;
  final String? phoneNumber;
  final String? message;
  final bool expanded;
  final EdgeInsets? padding;

  const WhatsAppButton({
    super.key,
    this.text = 'Fale Conosco no WhatsApp',
    this.subtext,
    this.phoneNumber,
    this.message,
    this.expanded = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => AppUtils.openWhatsApp(
          number: phoneNumber,
          message: message,
        ),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.whatsappGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.whatsappGreen.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                if (subtext != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          subtext!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botão pequeno do WhatsApp
class WhatsAppIconButton extends StatelessWidget {
  final String? phoneNumber;
  final String? message;
  final double size;

  const WhatsAppIconButton({
    super.key,
    this.phoneNumber,
    this.message,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.whatsappGreen,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => AppUtils.openWhatsApp(
          number: phoneNumber,
          message: message,
        ),
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: size,
          height: size,
          child: const Icon(Icons.chat_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}








