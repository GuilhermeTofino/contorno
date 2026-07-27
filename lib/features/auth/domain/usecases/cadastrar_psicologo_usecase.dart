import 'package:contorno/features/auth/domain/entities/psicologo_entity.dart';
import 'package:contorno/features/auth/domain/repositories/auth_repository.dart';
import 'package:contorno/features/auth/domain/services/crp_validator_service.dart';

class CadastrarPsicologoUseCase {
  final IAuthRepository repository;
  final ICrpValidatorService crpValidatorService;

  CadastrarPsicologoUseCase({
    required this.repository,
    required this.crpValidatorService,
  });

  Future<void> call(PsicologoEntity psicologo, String password) async {
    final isCrpValido = await crpValidatorService.validarCrp(psicologo.crp);
    if (!isCrpValido) {
      throw ArgumentError('O CRP informado é inválido ou inativo.');
    }

    if (psicologo.nome.trim().isEmpty) {
      throw ArgumentError('O nome do psicólogo é obrigatório.');
    }
    if (psicologo.email.trim().isEmpty) {
      throw ArgumentError('O e-mail é obrigatório.');
    }
    if (password.length < 6) {
      throw ArgumentError('A senha deve ter no mínimo 6 caracteres.');
    }

    await repository.cadastrar(psicologo, password);
  }
}
