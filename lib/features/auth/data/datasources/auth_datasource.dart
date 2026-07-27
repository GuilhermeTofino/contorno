import 'package:contorno/features/auth/data/models/psicologo_model.dart';

abstract class IAuthDatasource {
  Future<PsicologoModel?> login(String email, String password);
  Future<void> cadastrar(PsicologoModel psicologo, String password);
  Future<void> logout();
  Future<PsicologoModel?> getCurrentUser();
}
