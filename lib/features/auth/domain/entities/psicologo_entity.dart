import 'package:contorno/features/auth/domain/enums/auth_enums.dart';

class PsicologoEntity {
  final String id;
  final String nome;
  final String email;
  final TipoPessoa tipoPessoa;
  final String crp;

  PsicologoEntity({
    required this.id,
    required this.nome,
    required this.email,
    required this.tipoPessoa,
    required this.crp,
  }) {
    if (nome.trim().isEmpty) {
      throw ArgumentError('O nome do psicólogo é obrigatório.');
    }
    if (email.trim().isEmpty) {
      throw ArgumentError('O e-mail é obrigatório.');
    }
    if (crp.trim().isEmpty) {
      throw ArgumentError('O CRP é obrigatório.');
    }
  }
}
