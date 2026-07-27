import 'package:contorno/features/auth/domain/entities/psicologo_entity.dart';
import 'package:contorno/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final IAuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<PsicologoEntity?> call() async {
    return await repository.getCurrentUser();
  }
}
