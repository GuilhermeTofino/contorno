import 'package:contorno/features/agenda/domain/entities/agendamento_entity.dart';
import 'package:contorno/features/agenda/domain/enums/agenda_enums.dart';

abstract class IAgendaRepository {
  Future<List<AgendamentoEntity>> listarAgendamentosPorData(DateTime data);
  Future<List<AgendamentoEntity>> listarAgendamentosPorPaciente(String pacienteId);
  Future<List<AgendamentoEntity>> listarTodosAgendamentos();
  Future<void> cadastrarAgendamento(AgendamentoEntity agendamento, {int repeticoes = 1});
  Future<void> atualizarStatusAgendamento(String agendamentoId, StatusAgendamento status);
  Future<void> alternarStatusPagamento(String agendamentoId, StatusPagamento statusPagamento);
  Future<void> reagendarSessao(String agendamentoId, DateTime novaDataHora);
}
