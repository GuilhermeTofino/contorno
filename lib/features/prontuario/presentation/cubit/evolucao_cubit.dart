import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:contorno/core/error/exceptions.dart';
import 'package:contorno/features/prontuario/domain/entities/evolucao_entity.dart';
import 'package:contorno/features/prontuario/domain/usecases/cadastrar_evolucao_usecase.dart';
import 'package:contorno/features/prontuario/domain/usecases/listar_evolucoes_por_paciente_usecase.dart';
import 'package:contorno/features/prontuario/presentation/cubit/evolucao_state.dart';

class EvolucaoCubit extends Cubit<EvolucaoState> {
  final ListarEvolucoesPorPacienteUseCase listarEvolucoesPorPacienteUseCase;
  final CadastrarEvolucaoUseCase cadastrarEvolucaoUseCase;

  EvolucaoCubit({
    required this.listarEvolucoesPorPacienteUseCase,
    required this.cadastrarEvolucaoUseCase,
  }) : super(EvolucaoInitial());

  Future<void> carregarEvolucoes(String pacienteId) async {
    emit(EvolucaoLoading());
    try {
      final list = await listarEvolucoesPorPacienteUseCase(pacienteId);
      emit(EvolucaoLoaded(list));
    } on ServerException catch (e) {
      emit(EvolucaoError(e.message));
    } catch (e) {
      emit(EvolucaoError('Erro ao carregar o prontuário do paciente.'));
    }
  }

  Future<void> cadastrarEvolucao(EvolucaoEntity evolucao) async {
    emit(EvolucaoLoading());
    try {
      await cadastrarEvolucaoUseCase(evolucao);
      emit(EvolucaoSuccess());
      await carregarEvolucoes(evolucao.pacienteId);
    } on ServerException catch (e) {
      emit(EvolucaoError(e.message));
    } on ArgumentError catch (e) {
      emit(EvolucaoError(e.message.toString()));
    } catch (e) {
      emit(EvolucaoError('Erro ao salvar a evolução clínica.'));
    }
  }
}
