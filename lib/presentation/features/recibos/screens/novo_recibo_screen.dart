import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../domain/entities/recibo.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/utils/pdf_download_flow.dart';
import '../providers/recibo_list_provider.dart';

class NovoReciboScreen extends ConsumerStatefulWidget {
  const NovoReciboScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NovoReciboScreen> createState() => _NovoReciboScreenState();
}

class _NovoReciboScreenState extends ConsumerState<NovoReciboScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _clienteController = TextEditingController();
  final _referenteAController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _valorController.dispose();
    _clienteController.dispose();
    _referenteAController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      setState(() => _isSubmitting = true);

      try {
        final valor = double.parse(_valorController.text.replaceAll('.', '').replaceAll(',', '.').replaceAll('R\$ ', '').trim());
        final cliente = _clienteController.text.trim();
        final referenteA = _referenteAController.text.trim();

        final referenteACapitalizado = referenteA.isNotEmpty
            ? referenteA[0].toUpperCase() + (referenteA.length > 1 ? referenteA.substring(1) : '')
            : referenteA;

        final recibo = Recibo(
          valor: valor,
          cliente: cliente,
          referenteA: referenteACapitalizado,
          dataCriacao: DateTime.now(),
          numeroRecibo: '',
        );

        final repository = ref.read(reciboRepositoryProvider);

        if (!mounted) return;
        openPdfLoadingDialog(context, 'Criando recibo e gerando PDF...\nAguarde um momento.');

        try {
          final savedRecibo = await repository.createRecibo(recibo);
          final pdfBytes = await repository.generateReciboPdf(savedRecibo);

          if (!mounted) return;
          dismissPdfLoadingDialog(context);

          ref.invalidate(reciboListProvider);

          await presentPdfFromBytes(
            context: context,
            bytes: pdfBytes,
            fileName: 'recibo_${savedRecibo.numeroRecibo}.pdf',
            sheetTitle: 'Recibo ${savedRecibo.numeroRecibo}',
            shareMessage: 'Recibo ${savedRecibo.numeroRecibo} em PDF.',
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Recibo criado com sucesso!', style: GoogleFonts.poppins()),
                backgroundColor: AppColors.successGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop();
          }
        } catch (inner) {
          if (mounted) dismissPdfLoadingDialog(context);
          rethrow;
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao criar recibo: ${e.toString()}'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text('Novo Recibo', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: _isSubmitting ? null : _submitForm,
              icon: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check_circle_outline, color: Colors.white),
              label: Text('Salvar', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildSectionCard(
              title: 'Informações do Recibo',
              icon: Icons.receipt_long_outlined,
              children: [
                _buildTextFormField(
                  controller: _valorController,
                  label: 'Valor (R\$)*',
                  icon: Icons.attach_money,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe o valor';
                    }
                    final v = double.tryParse(value.replaceAll('.', '').replaceAll(',', '.').replaceAll('R\$ ', '').trim());
                    if (v == null || v <= 0) {
                      return 'O valor deve ser maior que zero';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextFormField(
                  controller: _clienteController,
                  label: 'Cliente*',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe o nome do cliente';
                    }
                    if (value.length < 3) {
                      return 'O nome deve ter pelo menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextFormField(
                  controller: _referenteAController,
                  label: 'Referente a*',
                  icon: Icons.description,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe a descrição';
                    }
                    if (value.length < 5) {
                      return 'A descrição deve ter pelo menos 5 caracteres';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(color: AppColors.primaryBlue.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, size: 24, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 16),
                Text(title, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.dividerColor, height: 1),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryBlue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
            hintText: label.contains('Valor') ? '0,00' : label.contains('Cliente') ? 'Nome do cliente' : 'Descrição do serviço ou produto',
          ),
          validator: validator,
        ),
      ],
    );
  }
}
