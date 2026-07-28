import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:contorno/features/auth/domain/entities/psicologo_entity.dart';
import 'package:contorno/features/auth/domain/enums/auth_enums.dart';
import 'package:contorno/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:contorno/features/auth/presentation/cubit/auth_state.dart';
import 'package:contorno/features/splash/presentation/widgets/brand_backdrop.dart';
import 'package:contorno/features/splash/presentation/widgets/rosette_widget.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _crpController = TextEditingController();
  final _telefoneController = TextEditingController();

  TipoPessoa _tipoPessoa = TipoPessoa.fisica;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _crpController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  void _submeterCadastro() {
    if (_formKey.currentState?.validate() ?? false) {
      final psicologo = PsicologoEntity(
        id: const Uuid().v4(),
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        tipoPessoa: _tipoPessoa,
        crp: _crpController.text.trim(),
      );

      context.read<AuthCubit>().cadastrar(psicologo, _senhaController.text);
    }
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, size: 20, color: const Color(0xFF6B6582)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3A345C), width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrandBackdrop(
        child: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state is AuthAuthenticated) {
                context.go('/');
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28.0,
                    vertical: 24.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BOTÃO VOLTAR E LOGO COMPACTO
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Color(0xFF2C2448),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const RosetteWidget(
                              size: 36,
                              showGlow: false,
                              color: Color(0xFFE4B363),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Enquadre',
                              style: TextStyle(
                                fontFamily: 'Serif',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C2448),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // TÍTULO E SUBTÍTULO
                        const Text(
                          'Cadastro Profissional',
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2448),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Crie sua conta para gerenciar seu setting terapêutico.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B6582),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // NOME COMPLETO
                        TextFormField(
                          controller: _nomeController,
                          style: const TextStyle(fontSize: 14),
                          decoration: _buildInputDecoration(
                            labelText: 'Nome Completo *',
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe seu nome completo';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // E-MAIL
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 14),
                          decoration: _buildInputDecoration(
                            labelText: 'E-mail *',
                            prefixIcon: Icons.mail_outline_rounded,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe seu e-mail';
                            }
                            if (!value.contains('@')) {
                              return 'E-mail inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // SENHA
                        TextFormField(
                          controller: _senhaController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(fontSize: 14),
                          decoration: _buildInputDecoration(
                            labelText: 'Senha (mínimo 6 caracteres) *',
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                                color: const Color(0xFF6B6582),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe uma senha';
                            }
                            if (value.length < 6) {
                              return 'A senha deve ter no mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // CRP (REGISTRO PROFISSIONAL)
                        TextFormField(
                          controller: _crpController,
                          style: const TextStyle(fontSize: 14),
                          decoration: _buildInputDecoration(
                            labelText: 'Número do CRP *',
                            hintText: 'Ex: 06/123456',
                            prefixIcon: Icons.badge_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe seu CRP';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // TELEFONE / WHATSAPP PROFISSIONAL
                        TextFormField(
                          controller: _telefoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(fontSize: 14),
                          decoration: _buildInputDecoration(
                            labelText: 'Telefone / WhatsApp',
                            hintText: '(11) 99999-9999',
                            prefixIcon: Icons.phone_outlined,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // SELETOR TIPO DE PESSOA (CPF / CNPJ)
                        const Text(
                          'Tipo de Registro',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2448),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Text('Pessoa Física (CPF)'),
                                selected: _tipoPessoa == TipoPessoa.fisica,
                                selectedColor: const Color(0xFF3A345C),
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color: _tipoPessoa == TipoPessoa.fisica
                                      ? const Color(0xFF3A345C)
                                      : Colors.grey.shade300,
                                ),
                                labelStyle: TextStyle(
                                  color: _tipoPessoa == TipoPessoa.fisica
                                      ? Colors.white
                                      : const Color(0xFF6B6582),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _tipoPessoa = TipoPessoa.fisica;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ChoiceChip(
                                label: const Text('Pessoa Jurídica (CNPJ)'),
                                selected: _tipoPessoa == TipoPessoa.juridica,
                                selectedColor: const Color(0xFF3A345C),
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color: _tipoPessoa == TipoPessoa.juridica
                                      ? const Color(0xFF3A345C)
                                      : Colors.grey.shade300,
                                ),
                                labelStyle: TextStyle(
                                  color: _tipoPessoa == TipoPessoa.juridica
                                      ? Colors.white
                                      : const Color(0xFF6B6582),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _tipoPessoa = TipoPessoa.juridica;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // BOTÃO CADASTRAR (GRADIENTE)
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3A345C), Color(0xFF2C2448)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF3A345C,
                                ).withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submeterCadastro,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : const Text(
                                    'Concluir Cadastro',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // BOTÃO JÁ TENHO CONTA
                        Center(
                          child: TextButton(
                            onPressed: () => context.pop(),
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B6582),
                                ),
                                children: [
                                  TextSpan(text: 'Já tem uma conta? '),
                                  TextSpan(
                                    text: 'Fazer Login',
                                    style: TextStyle(
                                      color: Color(0xFF3A345C),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
