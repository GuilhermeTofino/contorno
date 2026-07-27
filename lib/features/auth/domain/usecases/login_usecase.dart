import 'package:contorno/features/auth/domain/entities/psicologo_entity.dart';
import 'package:contorno/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<PsicologoEntity?> call(String email, String password) async {
    if (email.trim().isEmpty) {
      throw ArgumentError('O e-mail é obrigatório.');
    }
    if (password.trim().isEmpty) {
      throw ArgumentError('A senha é obrigatória.');
    }

    return await repository.login(email.trim(), password);
  }
}
