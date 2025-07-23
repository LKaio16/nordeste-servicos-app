import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nordeste_servicos_app/data/models/status_orcamento_model.dart';
import 'package:nordeste_servicos_app/domain/entities/item_orcamento.dart';
import 'package:nordeste_servicos_app/domain/entities/ordem_servico.dart';
import 'package:nordeste_servicos_app/domain/entities/peca_material.dart';
import 'package:nordeste_servicos_app/domain/entities/tipo_servico.dart';

import '../../../../domain/entities/cliente.dart';
import '../../../../domain/entities/orcamento.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/orcamento_detail_provider.dart';
import '../providers/orcamento_edit_provider.dart';
import '../providers/orcamento_list_provider.dart';

class OrcamentoEditScreen extends ConsumerStatefulWidget {
  final int orcamentoId;
  const OrcamentoEditScreen({Key? key, required this.orcamentoId}) : super(key: key);

  @override
  ConsumerState<OrcamentoEditScreen> createState() => _OrcamentoEditScreenState();
}

class _OrcamentoEditScreenState extends ConsumerState<OrcamentoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _observacoesController = TextEditingController();

  String? _selectedClienteId;
  String? _selectedOsId;
  late DateTime _dataValidade;
  StatusOrcamentoModel? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _dataValidade = DateTime.now();
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    super.dispose();
  }

  void _initializeFormFields(Orcamento orcamento) {
    _observacoesController.text = orcamento.observacoesCondicoes ?? '';
    _dataValidade = orcamento.dataValidade;
    _selectedClienteId = orcamento.clienteId.toString();
    _selectedOsId = orcamento.ordemServicoOrigemId?.toString();
    _selectedStatus = orcamento.status;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataValidade,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dataValidade = picked);
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final state = ref.read(orcamentoEditProvider(widget.orcamentoId));
      if (state.originalOrcamento == null) return;

      final orcamentoAtualizado = Orcamento(
        id: widget.orcamentoId,
        numeroOrcamento: state.originalOrcamento!.numeroOrcamento,
        dataCriacao: state.originalOrcamento!.dataCriacao,
        status: _selectedStatus!,
        clienteId: int.parse(_selectedClienteId!),
        dataValidade: _dataValidade,
        ordemServicoOrigemId: _selectedOsId != null ? int.parse(_selectedOsId!) : null,
        observacoesCondicoes: _observacoesController.text,
        valorTotal: state.originalOrcamento!.valorTotal,
      );

      final success = await ref.read(orcamentoEditProvider(widget.orcamentoId).notifier).updateOrcamento(orcamentoAtualizado);

      if (success && mounted) {
        ref.invalidate(orcamentoListProvider);
        ref.invalidate(orcamentoDetailProvider(widget.orcamentoId));
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Orçamento atualizado com sucesso!'),
              ],
            ),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orcamentoEditProvider(widget.orcamentoId));
    final notifier = ref.read(orcamentoEditProvider(widget.orcamentoId).notifier);

    ref.listen<OrcamentoEditState>(orcamentoEditProvider(widget.orcamentoId), (previous, next) {
      if (next.originalOrcamento != null && next.originalOrcamento != previous?.originalOrcamento) {
        setState(() {
          _initializeFormFields(next.originalOrcamento!);
        });
      }
      if (next.submissionError != null && previous?.submissionError != next.submissionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text(next.submissionError!)),
              ],
            ),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text(
          'Editar Orçamento',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBlue,
                AppColors.secondaryBlue,
              ],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.9),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextButton.icon(
              onPressed: state.isSubmitting ? null : _submitForm,
              icon: state.isSubmitting
                  ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: AppColors.primaryBlue,
                  strokeWidth: 2,
                ),
              )
                  : Icon(Icons.check_circle_outline, color: AppColors.primaryBlue, size: 18),
              label: Text(
                'Salvar',
                style: GoogleFonts.poppins(
                  color: AppColors.primaryBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Elementos decorativos de fundo
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Conteúdo principal
          state.isLoading
              ? _buildLoadingState()
              : state.errorMessage != null
              ? _buildErrorState(context, state.errorMessage!, () => notifier.loadInitialData())
              : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectionCard(
                  title: 'Informações Principais',
                  icon: Icons.article_outlined,
                  children: [
                    _buildDropdownFormField(
                      label: 'Cliente*',
                      hint: 'Selecione o cliente',
                      value: _selectedClienteId,
                      items: state.clientes.map((Cliente c) => DropdownMenuItem(value: c.id.toString(), child: Text(c.nomeCompleto, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClienteId = value;
                          _selectedOsId = null;
                        });
                        if (value != null) notifier.fetchOrdensDeServico(int.parse(value));
                      },
                      icon: Icons.person_search_outlined,
                    ),
                    const SizedBox(height: 20),
                    _buildStatusDropdown(),
                    const SizedBox(height: 20),
                    _buildDropdownFormField(
                      label: 'Ordem de Serviço (Opcional)',
                      hint: 'Selecione a OS',
                      value: _selectedOsId,
                      items: state.ordensDeServico.map((OrdemServico os) => DropdownMenuItem(value: os.id.toString(), child: Text('#${os.numeroOS} - ${os.problemaRelatado}', overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (value) => setState(() => _selectedOsId = value),
                      icon: Icons.receipt_long_outlined,
                      isOptional: true,
                    ),
                    const SizedBox(height: 20),
                    _buildDateField(
                      label: 'Data de Validade*',
                      selectedDate: _dataValidade,
                      onTap: () => _selectDate(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildItensCard(state, notifier),
                const SizedBox(height: 24),
                _buildSectionCard(
                  title: 'Observações e Condições',
                  icon: Icons.edit_note_outlined,
                  children: [
                    _buildTextFormField(
                      controller: _observacoesController,
                      label: 'Adicione observações ou condições comerciais',
                      icon: Icons.notes,
                      maxLines: 5,
                      isOptional: true,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundGray,
            AppColors.backgroundGray.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Carregando orçamento...',
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                color: AppColors.errorRed,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Erro ao Carregar',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue,
                    AppColors.secondaryBlue,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  'Tentar Novamente',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Status*",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<StatusOrcamentoModel>(
            value: _selectedStatus,
            items: StatusOrcamentoModel.values.map((StatusOrcamentoModel status) {
              return DropdownMenuItem<StatusOrcamentoModel>(
                value: status,
                child: Text(
                  status.name,
                  style: GoogleFonts.poppins(
                    color: AppColors.textDark,
                    fontSize: 15,
                  ),
                ),
              );
            }).toList(),
            onChanged: (StatusOrcamentoModel? newValue) {
              setState(() {
                _selectedStatus = newValue;
              });
            },
            style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 15),
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.flag_outlined,
                  size: 20,
                  color: AppColors.primaryBlue,
                ),
              ),
              filled: true,
              fillColor: AppColors.backgroundGray.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) => value == null ? 'Selecione um status' : null,
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
            dropdownColor: Colors.white,
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildItensCard(OrcamentoEditState state, OrcamentoEditNotifier notifier) {
    return _buildSectionCard(
      title: 'Itens do Orçamento',
      icon: Icons.shopping_cart_outlined,
      children: [
        if (state.isLoadingItens)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Carregando itens...',
                    style: GoogleFonts.poppins(
                      color: AppColors.textLight,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (state.itens.isEmpty)
          Container(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.textLight.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inventory_outlined,
                    size: 48,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum item adicionado',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Adicione peças, materiais ou serviços ao orçamento.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.itens.length,
            itemBuilder: (context, index) {
              final item = state.itens[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.dividerColor,
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item.pecaMaterialId != null
                          ? AppColors.warningOrange.withOpacity(0.1)
                          : AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      item.pecaMaterialId != null
                          ? Icons.construction
                          : Icons.design_services,
                      color: item.pecaMaterialId != null
                          ? AppColors.warningOrange
                          : AppColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item.descricao,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  subtitle: Text(
                    '${item.quantidade} x ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(item.valorUnitario)}',
                    style: GoogleFonts.poppins(
                      color: AppColors.textLight,
                      fontSize: 13,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(item.subtotal),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.successGreen,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: AppColors.errorRed,
                            size: 20,
                          ),
                          onPressed: () => notifier.deleteItem(item.id!),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondaryBlue,
                      AppColors.secondaryBlue.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddItemDialog(context, ref, state, isService: false),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Peça/Material',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.primaryBlue.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddItemDialog(context, ref, state, isService: true),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Serviço',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref, OrcamentoEditState state, {required bool isService}) {
    final formKey = GlobalKey<FormState>();
    final descricaoController = TextEditingController();
    final quantidadeController = TextEditingController(text: '1');
    final valorController = TextEditingController();

    dynamic selectedItem;
    bool isCustom = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isService ? Icons.design_services : Icons.construction,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Adicionar ${isService ? "Serviço" : "Peça"}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.backgroundGray.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            "Item Personalizado",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                          ),
                          value: isCustom,
                          activeColor: AppColors.primaryBlue,
                          onChanged: (val) => setDialogState(() {
                            isCustom = val;
                            descricaoController.clear();
                            valorController.clear();
                            selectedItem = null;
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if(isCustom)
                        TextFormField(
                          controller: descricaoController,
                          style: GoogleFonts.poppins(color: AppColors.textDark),
                          decoration: InputDecoration(
                            labelText: 'Descrição*',
                            labelStyle: GoogleFonts.poppins(color: AppColors.textLight),
                            prefixIcon: Icon(Icons.edit, color: AppColors.primaryBlue),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                            ),
                          ),
                          validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                        )
                      else if(isService)
                        DropdownButtonFormField<TipoServico>(
                          hint: Text(
                            "Selecione um serviço",
                            style: GoogleFonts.poppins(color: AppColors.textLight),
                          ),
                          items: state.servicos.map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s.descricao,
                              style: GoogleFonts.poppins(color: AppColors.textDark),
                            ),
                          )).toList(),
                          onChanged: (val) => setDialogState(() {
                            selectedItem = val;
                            descricaoController.text = val?.descricao ?? '';
                          }),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.design_services, color: AppColors.primaryBlue),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                            ),
                          ),
                          validator: (v) => v == null ? 'Campo obrigatório' : null,
                        )
                      else
                        DropdownButtonFormField<PecaMaterial>(
                          hint: Text(
                            "Selecione uma peça",
                            style: GoogleFonts.poppins(color: AppColors.textLight),
                          ),
                          items: state.pecas.map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(
                              p.descricao,
                              style: GoogleFonts.poppins(color: AppColors.textDark),
                            ),
                          )).toList(),
                          onChanged: (val) => setDialogState(() {
                            selectedItem = val;
                            descricaoController.text = val?.descricao ?? '';
                            valorController.text = val?.preco?.toString() ?? '';
                          }),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.construction, color: AppColors.primaryBlue),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                            ),
                          ),
                          validator: (v) => v == null ? 'Campo obrigatório' : null,
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: quantidadeController,
                        style: GoogleFonts.poppins(color: AppColors.textDark),
                        decoration: InputDecoration(
                          labelText: 'Quantidade*',
                          labelStyle: GoogleFonts.poppins(color: AppColors.textLight),
                          prefixIcon: Icon(Icons.numbers, color: AppColors.primaryBlue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: valorController,
                        style: GoogleFonts.poppins(color: AppColors.textDark),
                        decoration: InputDecoration(
                          labelText: 'Valor Unitário (R\$)*',
                          labelStyle: GoogleFonts.poppins(color: AppColors.textLight),
                          prefixIcon: Icon(Icons.attach_money, color: AppColors.primaryBlue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.poppins(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue,
                        AppColors.secondaryBlue,
                      ],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final novoItem = ItemOrcamento(
                          orcamentoId: widget.orcamentoId,
                          pecaMaterialId: !isService && !isCustom ? (selectedItem as PecaMaterial).id : null,
                          tipoServicoId: isService && !isCustom ? (selectedItem as TipoServico).id : null,
                          descricao: descricaoController.text,
                          quantidade: double.parse(quantidadeController.text),
                          valorUnitario: double.parse(valorController.text.replaceAll(',', '.')),
                        );
                        ref.read(orcamentoEditProvider(widget.orcamentoId).notifier).addItem(novoItem);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'Adicionar',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
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
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 24, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.dividerColor,
                    AppColors.dividerColor.withOpacity(0.1),
                  ],
                ),
              ),
            ),
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
    bool isOptional = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: GoogleFonts.poppins(
              color: AppColors.textDark,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.primaryBlue,
                ),
              ),
              filled: true,
              fillColor: AppColors.backgroundGray.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (!isOptional && (value == null || value.isEmpty)) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFormField({
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required String label,
    required IconData icon,
    required String hint,
    bool isOptional = false
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items,
            onChanged: onChanged,
            validator: (val) {
              if (!isOptional && (val == null || val.isEmpty)) {
                return 'Campo obrigatório';
              }
              return null;
            },
            style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 15),
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.primaryBlue,
                ),
              ),
              filled: true,
              fillColor: AppColors.backgroundGray.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: AppColors.textLight.withOpacity(0.7),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
            dropdownColor: Colors.white,
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({required String label, required DateTime selectedDate, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.backgroundGray.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(selectedDate),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.primaryBlue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

