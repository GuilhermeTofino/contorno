import 'package:contorno/features/paciente/domain/enums/paciente_enums.dart';

class PacienteEntity {
  final String id;
  final String psicologoId;
  final String nome;
  final String telefone;
  final DateTime dataNascimento;
  final TipoAtendimento tipoAtendimento;
  final double valorSessaoPadrao;
  final String? contatoEmergenciaNome;
  final String? contatoEmergenciaTelefone;
  final StatusPaciente status;
  final bool temRecorrencia;

  PacienteEntity({
    required this.id,
    required this.psicologoId,
    required this.nome,
    required this.telefone,
    required this.dataNascimento,
    required this.tipoAtendimento,
    required this.valorSessaoPadrao,
    this.contatoEmergenciaNome,
    this.contatoEmergenciaTelefone,
    this.status = StatusPaciente.ativo,
    this.temRecorrencia = false,
  }) {
    if (psicologoId.trim().isEmpty) {
      throw ArgumentError(
        'O psicólogo responsável (psicologoId) é obrigatório.',
      );
    }
    if (nome.trim().isEmpty) {
      throw ArgumentError('O nome do paciente não pode ser vazio.');
    }
    if (telefone.trim().isEmpty) {
      throw ArgumentError('O telefone do paciente não pode ser vazio.');
    }
    if (valorSessaoPadrao < 0) {
      throw ArgumentError('O valor padrão da sessão não pode ser negativo.');
    }
  }
}
