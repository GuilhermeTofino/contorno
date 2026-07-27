import 'package:contorno/features/agenda/data/models/agendamento_model.dart';

abstract class IAgendaDatasource {
  Future<List<AgendamentoModel>> listarAgendamentosPorData(DateTime data);
  Future<List<AgendamentoModel>> listarAgendamentosPorPaciente(String pacienteId);
  Future<List<AgendamentoModel>> listarTodosAgendamentos();
  Future<void> cadastrarAgendamento(AgendamentoModel agendamento, {int repeticoes = 1});
  Future<void> atualizarStatusAgendamento(String agendamentoId, String status);
  Future<void> alternarStatusPagamento(String agendamentoId, String statusPagamento);
  Future<void> reagendarSessao(String agendamentoId, DateTime novaDataHora);
}
