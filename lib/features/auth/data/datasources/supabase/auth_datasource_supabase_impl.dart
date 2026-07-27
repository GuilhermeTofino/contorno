import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:contorno/core/error/exceptions.dart';
import 'package:contorno/features/auth/data/datasources/auth_datasource.dart';
import 'package:contorno/features/auth/data/models/psicologo_model.dart';

class AuthDatasourceSupabaseImpl implements IAuthDatasource {
  final SupabaseClient supabase;

  AuthDatasourceSupabaseImpl(this.supabase);

  static const String _tableName = 'psicologos';

  @override
  Future<void> cadastrar(PsicologoModel psicologo, String password) async {
    try {
      final authResponse = await supabase.auth.signUp(
        email: psicologo.email,
        password: password,
      );

      final userId = authResponse.user?.id;
      if (userId == null) {
        throw ServerException(message: 'Falha ao gerar ID do usuário no Supabase Auth.');
      }

      final profileMap = psicologo.toMap();
      profileMap['id'] = userId;

      await supabase.from(_tableName).insert(profileMap);
    } on AuthException catch (e) {
      throw ServerException(message: e.message, code: e.statusCode);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PsicologoModel?> login(String email, String password) async {
    try {
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final userId = authResponse.user?.id;
      if (userId == null) return null;

      final response = await supabase
          .from(_tableName)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return PsicologoModel.fromMap(response);
    } on AuthException catch (e) {
      throw ServerException(message: e.message, code: e.statusCode);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException(message: e.message, code: e.statusCode);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PsicologoModel?> getCurrentUser() async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return null;

      final response = await supabase
          .from(_tableName)
          .select()
          .eq('id', currentUser.id)
          .maybeSingle();

      if (response == null) return null;

      return PsicologoModel.fromMap(response);
    } on AuthException catch (e) {
      throw ServerException(message: e.message, code: e.statusCode);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
