import 'package:contorno/features/agenda/data/datasources/agenda_datasource.dart';
import 'package:contorno/features/agenda/data/models/agendamento_model.dart';
import 'package:contorno/features/agenda/domain/entities/agendamento_entity.dart';
import 'package:contorno/features/agenda/domain/enums/agenda_enums.dart';
import 'package:contorno/features/agenda/domain/repositories/agenda_repository.dart';

class AgendaRepositoryImpl implements IAgendaRepository {
  final IAgendaDatasource datasource;

  AgendaRepositoryImpl(this.datasource);

  @override
  Future<void> cadastrarAgendamento(AgendamentoEntity agendamento, {int repeticoes = 1}) async {
    final model = AgendamentoModel.fromEntity(agendamento);
    await datasource.cadastrarAgendamento(model, repeticoes: repeticoes);
  }

  @override
  Future<List<AgendamentoEntity>> listarAgendamentosPorData(DateTime data) async {
    return await datasource.listarAgendamentosPorData(data);
  }

  @override
  Future<List<AgendamentoEntity>> listarAgendamentosPorPaciente(String pacienteId) async {
    return await datasource.listarAgendamentosPorPaciente(pacienteId);
  }

  @override
  Future<List<AgendamentoEntity>> listarTodosAgendamentos() async {
    return await datasource.listarTodosAgendamentos();
  }

  @override
  Future<void> atualizarStatusAgendamento(String agendamentoId, StatusAgendamento status) async {
    await datasource.atualizarStatusAgendamento(agendamentoId, status.name);
  }

  @override
  Future<void> alternarStatusPagamento(String agendamentoId, StatusPagamento statusPagamento) async {
    await datasource.alternarStatusPagamento(agendamentoId, statusPagamento.name);
  }

  @override
  Future<void> reagendarSessao(String agendamentoId, DateTime novaDataHora) async {
    await datasource.reagendarSessao(agendamentoId, novaDataHora);
  }
}
