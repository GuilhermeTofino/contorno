import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:contorno/features/paciente/domain/entities/paciente_entity.dart';
import 'package:contorno/features/paciente/domain/enums/paciente_enums.dart';
import 'package:contorno/features/paciente/presentation/cubit/paciente_cubit.dart';
import 'package:contorno/features/paciente/presentation/cubit/paciente_state.dart';

class CadastrarPacientePage extends StatefulWidget {
  const CadastrarPacientePage({super.key});

  @override
  State<CadastrarPacientePage> createState() => _CadastrarPacientePageState();
}

class _CadastrarPacientePageState extends State<CadastrarPacientePage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _valorSessaoController = TextEditingController();
  final _contatoEmergenciaNomeController = TextEditingController();
  final _contatoEmergenciaTelefoneController = TextEditingController();

  TipoAtendimento _tipoAtendimento = TipoAtendimento.particular;

  final _telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _emergenciaTelefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _dataNascimentoMask = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _dataNascimentoController.dispose();
    _valorSessaoController.dispose();
    _contatoEmergenciaNomeController.dispose();
    _contatoEmergenciaTelefoneController.dispose();
    super.dispose();
  }

  void _limparCampos() {
    _nomeController.clear();
    _telefoneController.clear();
    _dataNascimentoController.clear();
    _valorSessaoController.clear();
    _contatoEmergenciaNomeController.clear();
    _contatoEmergenciaTelefoneController.clear();
    setState(() {
      _tipoAtendimento = TipoAtendimento.particular;
    });
  }

  DateTime? _parseDataNascimento(String maskedDate) {
    try {
      final parts = maskedDate.split('/');
      if (parts.length != 3) return null;
      final dia = int.parse(parts[0]);
      final mes = int.parse(parts[1]);
      final ano = int.parse(parts[2]);
      return DateTime(ano, mes, dia);
    } catch (_) {
      return null;
    }
  }

  double _parseValorSessao(String input) {
    final cleanText = input.replaceAll('R\$', '').replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(cleanText) ?? 0.0;
  }

  void _submeterFormulario() {
    if (_formKey.currentState?.validate() ?? false) {
      final dataParsed = _parseDataNascimento(_dataNascimentoController.text);
      if (dataParsed == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data de nascimento inválida!'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final psicologoId = Supabase.instance.client.auth.currentUser?.id ?? '';

      final paciente = PacienteEntity(
        id: const Uuid().v4(),
        psicologoId: psicologoId,
        nome: _nomeController.text.trim(),
        telefone: _telefoneMask.getUnmaskedText(),
        dataNascimento: dataParsed,
        tipoAtendimento: _tipoAtendimento,
        valorSessaoPadrao: _parseValorSessao(_valorSessaoController.text),
        contatoEmergenciaNome: _contatoEmergenciaNomeController.text.trim().isEmpty
            ? null
            : _contatoEmergenciaNomeController.text.trim(),
        contatoEmergenciaTelefone: _emergenciaTelefoneMask.getUnmaskedText().isEmpty
            ? null
            : _emergenciaTelefoneMask.getUnmaskedText(),
        status: StatusPaciente.ativo,
      );

      context.read<PacienteCubit>().cadastrar(paciente);
    }
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Paciente'),
        elevation: 0,
      ),
      body: BlocConsumer<PacienteCubit, PacienteState>(
        listener: (context, state) {
          if (state is PacienteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is PacienteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
            _limparCampos();
            context.pop();
          }
        },
        builder: (context, state) {
          final isLoading = state is PacienteLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Dados do Paciente',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Preencha as informações para o acompanhamento clínico',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _nomeController,
                    decoration: _buildInputDecoration(
                      labelText: 'Nome Completo *',
                      prefixIcon: Icons.person_outline,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o nome do paciente';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _telefoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [_telefoneMask],
                    decoration: _buildInputDecoration(
                      labelText: 'Telefone / WhatsApp *',
                      prefixIcon: Icons.phone_outlined,
                      hintText: '(11) 99999-9999',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o telefone de contato';
                      }
                      if (_telefoneMask.getUnmaskedText().length < 10) {
                        return 'Informe um telefone válido com DDD';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dataNascimentoController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_dataNascimentoMask],
                    decoration: _buildInputDecoration(
                      labelText: 'Data de Nascimento *',
                      prefixIcon: Icons.calendar_today_outlined,
                      hintText: 'DD/MM/AAAA',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe a data de nascimento';
                      }
                      if (value.length < 10 || _parseDataNascimento(value) == null) {
                        return 'Informe uma data válida no formato DD/MM/AAAA';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TipoAtendimento>(
                    initialValue: _tipoAtendimento,
                    decoration: _buildInputDecoration(
                      labelText: 'Tipo de Atendimento',
                      prefixIcon: Icons.category_outlined,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: TipoAtendimento.particular,
                        child: Text('Particular'),
                      ),
                      DropdownMenuItem(
                        value: TipoAtendimento.convenio,
                        child: Text('Convênio'),
                      ),
                      DropdownMenuItem(
                        value: TipoAtendimento.outros,
                        child: Text('Outros'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _tipoAtendimento = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _valorSessaoController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _buildInputDecoration(
                      labelText: 'Valor Padrão da Sessão (R\$) *',
                      prefixIcon: Icons.attach_money_outlined,
                      hintText: 'Ex: 150,00',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o valor padrão da sessão';
                      }
                      final valor = _parseValorSessao(value);
                      if (valor < 0) {
                        return 'Informe um valor válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Contato de Emergência (Opcional)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contatoEmergenciaNomeController,
                    decoration: _buildInputDecoration(
                      labelText: 'Nome do Contato',
                      prefixIcon: Icons.contact_phone_outlined,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contatoEmergenciaTelefoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [_emergenciaTelefoneMask],
                    decoration: _buildInputDecoration(
                      labelText: 'Telefone do Contato',
                      prefixIcon: Icons.phone_paused_outlined,
                      hintText: '(11) 99999-9999',
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submeterFormulario,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.tertiary,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : const Text(
                              'Salvar Paciente',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
