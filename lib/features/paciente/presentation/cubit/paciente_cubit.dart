import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:contorno/core/error/exceptions.dart';
import 'package:contorno/features/paciente/domain/entities/paciente_entity.dart';
import 'package:contorno/features/paciente/domain/usecases/cadastrar_paciente_usecase.dart';
import 'package:contorno/features/paciente/domain/usecases/listar_pacientes_ativos_usecase.dart';
import 'package:contorno/features/paciente/presentation/cubit/paciente_state.dart';

class PacienteCubit extends Cubit<PacienteState> {
  final CadastrarPacienteUseCase cadastrarPacienteUseCase;
  final ListarPacientesAtivosUseCase listarPacientesAtivosUseCase;

  PacienteCubit({
    required this.cadastrarPacienteUseCase,
    required this.listarPacientesAtivosUseCase,
  }) : super(PacienteInitial());

  Future<void> carregarPacientes() async {
    emit(PacienteLoading());
    try {
      final pacientes = await listarPacientesAtivosUseCase();
      emit(PacienteLoaded(pacientes));
    } on ServerException catch (e) {
      emit(PacienteError(e.message));
    } catch (e) {
      emit(PacienteError('Erro ao carregar a lista de pacientes.'));
    }
  }

  Future<void> cadastrar(PacienteEntity paciente) async {
    emit(PacienteLoading());

    try {
      await cadastrarPacienteUseCase(paciente);
      emit(PacienteSuccess(paciente: paciente));
    } on ServerException catch (e) {
      emit(PacienteError(e.message));
    } on ArgumentError catch (e) {
      emit(PacienteError(e.message.toString()));
    } catch (e) {
      emit(PacienteError('Ocorreu um erro inesperado ao cadastrar o paciente.'));
    }
  }
}
