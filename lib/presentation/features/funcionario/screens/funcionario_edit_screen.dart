import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../data/models/perfil_usuario_model.dart';
import '../../../../domain/entities/usuario.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/funcionario_detail_provider.dart';
import '../providers/funcionario_edit_provider.dart';
import '../providers/funcionario_list_provider.dart';

class FuncionarioEditScreen extends ConsumerStatefulWidget {
  final int funcionarioId;
  const FuncionarioEditScreen({Key? key, required this.funcionarioId}) : super(key: key);

  @override
  ConsumerState<FuncionarioEditScreen> createState() => _FuncionarioEditScreenState();
}

class _FuncionarioEditScreenState extends ConsumerState<FuncionarioEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _crachaController;
  PerfilUsuarioModel? _selectedPerfil;
  bool _initialDataLoaded = false;

  String? _base64Image;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _emailController = TextEditingController();
    _crachaController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(funcionarioEditProvider(widget.funcionarioId).notifier).loadFuncionario(widget.funcionarioId);
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _crachaController.dispose();
    super.dispose();
  }

  void _initializeFormFields(Usuario funcionario) {
    if (!_initialDataLoaded) {
      _nomeController.text = funcionario.nome;
      _emailController.text = funcionario.email ?? '';
      _crachaController.text = funcionario.cracha ?? '';

      setState(() {
        _selectedPerfil = funcionario.perfil;
        if (funcionario.fotoPerfil != null && funcionario.fotoPerfil!.isNotEmpty) {
          _imageBytes = base64Decode(funcionario.fotoPerfil!);
          _base64Image = funcionario.fotoPerfil!;
        }
      });

      _initialDataLoaded = true;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 800);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _base64Image = base64Encode(bytes);
      });
    }
  }


  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(funcionarioEditProvider(widget.funcionarioId).notifier).updateFuncionario(
        id: widget.funcionarioId,
        nome: _nomeController.text,
        email: _emailController.text,
        cracha: _crachaController.text,
        perfil: _selectedPerfil!,
        fotoPerfil: _base64Image,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funcionário atualizado com sucesso!'), backgroundColor: AppColors.successGreen));
        ref.invalidate(funcionarioListProvider);
        ref.invalidate(funcionarioDetailProvider(widget.funcionarioId));
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(funcionarioEditProvider(widget.funcionarioId));

    ref.listen<FuncionarioEditState>(funcionarioEditProvider(widget.funcionarioId), (previous, next) {
      if (next.originalFuncionario != null && !_initialDataLoaded) {
        setState(() {
          _initializeFormFields(next.originalFuncionario!);
        });
      }
      if (next.submissionError != null && next.submissionError != previous?.submissionError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.submissionError!), backgroundColor: AppColors.errorRed));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text('Editar Funcionário', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryBlue, AppColors.secondaryBlue]))),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: state.isLoading || state.isSubmitting ? null : _submitForm,
              icon: state.isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue)) : const Icon(Icons.save, size: 18),
              label: Text('Salvar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, foregroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            ),
          ),
        ],
      ),
      body: state.isLoading && !_initialDataLoaded
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue,))
          : state.errorMessage != null
          ? Center(child: Text(state.errorMessage!))
          : _buildFormContent(),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileImage(),
          const SizedBox(height: 32),
          _buildSectionCard(
            title: 'Informações Pessoais',
            icon: Icons.person_outline,
            children: [
              _buildTextFormField(controller: _nomeController, label: 'Nome Completo', icon: Icons.badge_outlined),
              const SizedBox(height: 20),
              _buildTextFormField(controller: _emailController, label: 'E-mail', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionCard(
            title: 'Detalhes Corporativos',
            icon: Icons.business_center_outlined,
            children: [
              _buildTextFormField(controller: _crachaController, label: 'Crachá', icon: Icons.credit_card_outlined),
              const SizedBox(height: 20),
              _buildDropdownFormField(
                label: 'Perfil de Acesso',
                value: _selectedPerfil,
                items: PerfilUsuarioModel.values.map((perfil) {
                  return DropdownMenuItem(
                    value: perfil,
                    child: Text(perfil.name == 'ADMIN' ? 'Administrador' : 'Técnico', style: GoogleFonts.poppins()),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedPerfil = value),
                icon: Icons.security_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    ImageProvider? backgroundImage;
    if (_imageBytes != null) {
      backgroundImage = MemoryImage(_imageBytes!);
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            backgroundImage: backgroundImage,
            child: backgroundImage == null
                ? Icon(Icons.person, size: 60, color: AppColors.primaryBlue.withOpacity(0.5))
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              color: AppColors.primaryBlue,
              shape: const CircleBorder(),
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.3),
              child: InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
                  child: Icon(
                    icon,
                    size: 24,
                    color: AppColors.primaryBlue,
                  ),
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
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Container(
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
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) {
            return 'Campo obrigatório';
          }
          return null;
        },
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: AppColors.textLight,
            fontSize: 14,
          ),
          prefixIcon: icon != null
              ? Container(
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
          )
              : null,
          filled: true,
          fillColor: AppColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.errorRed),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: icon != null ? 16 : 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownFormField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
    String? hint,
    IconData? icon,
  }) {
    return Container(
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
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        validator: validator ?? (val) => val == null ? 'Selecione uma opção' : null,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: AppColors.textLight,
            fontSize: 14,
          ),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: AppColors.textLight,
            fontSize: 14,
          ),
          prefixIcon: icon != null
              ? Container(
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
          )
              : null,
          filled: true,
          fillColor: AppColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.errorRed),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: icon != null ? 16 : 16,
            vertical: 16,
          ),
        ),
        dropdownColor: AppColors.cardBackground,
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}