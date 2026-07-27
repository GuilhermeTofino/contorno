import 'package:contorno/features/auth/domain/entities/psicologo_entity.dart';

abstract class IAuthRepository {
  Future<PsicologoEntity?> login(String email, String password);
  Future<void> cadastrar(PsicologoEntity psicologo, String password);
  Future<void> logout();
  Future<PsicologoEntity?> getCurrentUser();
}
