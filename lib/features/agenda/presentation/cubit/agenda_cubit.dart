import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:contorno/core/error/exceptions.dart';
import 'package:contorno/features/agenda/domain/entities/agendamento_entity.dart';
import 'package:contorno/features/agenda/domain/enums/agenda_enums.dart';
import 'package:contorno/features/agenda/domain/repositories/agenda_repository.dart';
import 'package:contorno/features/agenda/domain/usecases/cadastrar_agendamento_usecase.dart';
import 'package:contorno/features/agenda/domain/usecases/listar_agendamentos_por_data_usecase.dart';
import 'package:contorno/features/agenda/domain/usecases/listar_todos_agendamentos_usecase.dart';
import 'package:contorno/features/agenda/presentation/cubit/agenda_state.dart';

class AgendaCubit extends Cubit<AgendaState> {
  final ListarAgendamentosPorDataUseCase listarAgendamentosPorDataUseCase;
  final ListarTodosAgendamentosUseCase listarTodosAgendamentosUseCase;
  final CadastrarAgendamentoUseCase cadastrarAgendamentoUseCase;
  final IAgendaRepository agendaRepository;

  DateTime _dataAtual = DateTime.now();
  Map<DateTime, List<AgendamentoEntity>> _agendamentosPorData = {};

  AgendaCubit({
    required this.listarAgendamentosPorDataUseCase,
    required this.listarTodosAgendamentosUseCase,
    required this.cadastrarAgendamentoUseCase,
    required this.agendaRepository,
  }) : super(AgendaInitial());

  DateTime get dataAtual => _dataAtual;

  DateTime _normalizarData(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> carregarAgendamentos([DateTime? data]) async {
    if (data != null) {
      _dataAtual = data;
    }

    emit(AgendaLoading());
    try {
      final todos = await listarTodosAgendamentosUseCase();
      _agendamentosPorData = {};

      for (var item in todos) {
        final key = _normalizarData(item.dataHora);
        if (_agendamentosPorData.containsKey(key)) {
          _agendamentosPorData[key]!.add(item);
        } else {
          _agendamentosPorData[key] = [item];
        }
      }

      final keyDiaAtual = _normalizarData(_dataAtual);
      final doDia = _agendamentosPorData[keyDiaAtual] ?? [];

      emit(
        AgendaLoaded(
          dataSelecionada: _dataAtual,
          agendamentos: doDia,
          agendamentosPorData: _agendamentosPorData,
        ),
      );
    } on ServerException catch (e) {
      emit(AgendaError(e.message));
    } catch (e) {
      emit(AgendaError('Erro ao carregar os agendamentos da data.'));
    }
  }

  Future<void> carregarAgendamentosPorPaciente(String pacienteId) async {
    emit(AgendaLoading());
    try {
      final doPaciente = await agendaRepository.listarAgendamentosPorPaciente(
        pacienteId,
      );
      emit(
        AgendaLoaded(
          dataSelecionada: _dataAtual,
          agendamentos: doPaciente,
          agendamentosPorData: _agendamentosPorData,
        ),
      );
    } on ServerException catch (e) {
      emit(AgendaError(e.message));
    } catch (e) {
      emit(
        AgendaError(
          'Erro ao carregar o histórico de agendamentos do paciente.',
        ),
      );
    }
  }

  Future<void> cadastrarAgendamento(
    AgendamentoEntity agendamento, {
    int repeticoes = 1,
  }) async {
    emit(AgendaLoading());
    try {
      await cadastrarAgendamentoUseCase(agendamento, repeticoes: repeticoes);
      emit(AgendaSuccess());
      await carregarAgendamentos(_dataAtual);
    } on ServerException catch (e) {
      emit(AgendaError(e.message));
    } on ArgumentError catch (e) {
      emit(AgendaError(e.message.toString()));
    } catch (e) {
      emit(AgendaError('Ocorreu um erro ao agendar a sessão.'));
    }
  }

  Future<void> alternarPagamento(
    String agendamentoId,
    StatusPagamento novoStatus,
    String pacienteId,
  ) async {
    try {
      await agendaRepository.alternarStatusPagamento(agendamentoId, novoStatus);
      await carregarAgendamentosPorPaciente(pacienteId);
    } catch (e) {
      emit(AgendaError('Erro ao alterar status de pagamento.'));
    }
  }

  Future<void> alterarStatusSessao(
    String agendamentoId,
    StatusAgendamento novoStatus,
    String pacienteId,
  ) async {
    try {
      await agendaRepository.atualizarStatusAgendamento(
        agendamentoId,
        novoStatus,
      );
      await carregarAgendamentosPorPaciente(pacienteId);
    } catch (e) {
      emit(AgendaError('Erro ao atualizar status da sessão.'));
    }
  }

  Future<void> reagendarSessao(
    String agendamentoId,
    DateTime novaDataHora,
    String pacienteId,
  ) async {
    try {
      await agendaRepository.reagendarSessao(agendamentoId, novaDataHora);
      await carregarAgendamentosPorPaciente(pacienteId);
    } catch (e) {
      emit(AgendaError('Erro ao reagendar a sessão.'));
    }
  }

  Future<void> atualizarAgendamento(AgendamentoEntity agendamento) async {
    try {
      await agendaRepository.atualizarStatusAgendamento(
        agendamento.id,
        agendamento.status,
      );
      await agendaRepository.reagendarSessao(
        agendamento.id,
        agendamento.dataHora,
      );
      await carregarAgendamentos(_dataAtual);
    } catch (e) {
      emit(AgendaError('Erro ao atualizar agendamento.'));
    }
  }
}
