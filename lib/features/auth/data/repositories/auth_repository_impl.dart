import 'package:contorno/features/auth/data/datasources/auth_datasource.dart';
import 'package:contorno/features/auth/data/models/psicologo_model.dart';
import 'package:contorno/features/auth/domain/entities/psicologo_entity.dart';
import 'package:contorno/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<void> cadastrar(PsicologoEntity psicologo, String password) async {
    final model = PsicologoModel.fromEntity(psicologo);
    await datasource.cadastrar(model, password);
  }

  @override
  Future<PsicologoEntity?> login(String email, String password) async {
    return await datasource.login(email, password);
  }

  @override
  Future<void> logout() async {
    await datasource.logout();
  }

  @override
  Future<PsicologoEntity?> getCurrentUser() async {
    return await datasource.getCurrentUser();
  }
}
