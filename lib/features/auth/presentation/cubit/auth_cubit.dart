import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:contorno/core/error/exceptions.dart';
import 'package:contorno/features/auth/domain/entities/psicologo_entity.dart';
import 'package:contorno/features/auth/domain/usecases/cadastrar_psicologo_usecase.dart';
import 'package:contorno/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:contorno/features/auth/domain/usecases/login_usecase.dart';
import 'package:contorno/features/auth/domain/usecases/logout_usecase.dart';
import 'package:contorno/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final CadastrarPsicologoUseCase cadastrarPsicologoUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.cadastrarPsicologoUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial());

  Future<void> checkAuth() async {
    emit(AuthLoading());
    try {
      final user = await getCurrentUserUseCase();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } on ServerException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase(email, password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('Falha ao realizar login. Usuário não encontrado.'));
      }
    } on ServerException catch (e) {
      emit(AuthError(e.message));
    } on ArgumentError catch (e) {
      emit(AuthError(e.message.toString()));
    } catch (e) {
      emit(AuthError('Ocorreu um erro inesperado ao fazer login.'));
    }
  }

  Future<void> cadastrar(PsicologoEntity psicologo, String password) async {
    emit(AuthLoading());
    try {
      await cadastrarPsicologoUseCase(psicologo, password);
      final user = await getCurrentUserUseCase();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } on ServerException catch (e) {
      emit(AuthError(e.message));
    } on ArgumentError catch (e) {
      emit(AuthError(e.message.toString()));
    } catch (e) {
      emit(AuthError('Ocorreu um erro inesperado ao realizar o cadastro.'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await logoutUseCase();
      emit(AuthUnauthenticated());
    } on ServerException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Ocorreu um erro ao encerrar a sessão.'));
    }
  }
}
