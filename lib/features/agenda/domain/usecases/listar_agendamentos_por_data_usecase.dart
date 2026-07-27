import 'package:contorno/features/agenda/domain/entities/agendamento_entity.dart';
import 'package:contorno/features/agenda/domain/repositories/agenda_repository.dart';

class ListarAgendamentosPorDataUseCase {
  final IAgendaRepository repository;

  ListarAgendamentosPorDataUseCase(this.repository);

  Future<List<AgendamentoEntity>> call(DateTime data) async {
    return await repository.listarAgendamentosPorData(data);
  }
}
