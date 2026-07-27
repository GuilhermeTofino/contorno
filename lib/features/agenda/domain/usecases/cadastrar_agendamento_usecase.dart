import 'package:contorno/features/agenda/domain/entities/agendamento_entity.dart';
import 'package:contorno/features/agenda/domain/repositories/agenda_repository.dart';

class CadastrarAgendamentoUseCase {
  final IAgendaRepository repository;

  CadastrarAgendamentoUseCase(this.repository);

  Future<void> call(AgendamentoEntity agendamento, {int repeticoes = 1}) async {
    if (agendamento.pacienteId.trim().isEmpty) {
      throw ArgumentError('Selecione um paciente para o agendamento.');
    }
    if (agendamento.valorSessao < 0) {
      throw ArgumentError('O valor da sessão não pode ser negativo.');
    }

    await repository.cadastrarAgendamento(agendamento, repeticoes: repeticoes);
  }
}
