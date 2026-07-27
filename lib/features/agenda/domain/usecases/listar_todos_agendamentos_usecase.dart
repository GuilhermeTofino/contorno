import 'package:contorno/features/agenda/domain/entities/agendamento_entity.dart';
import 'package:contorno/features/agenda/domain/repositories/agenda_repository.dart';

class ListarTodosAgendamentosUseCase {
  final IAgendaRepository repository;

  ListarTodosAgendamentosUseCase(this.repository);

  Future<List<AgendamentoEntity>> call() async {
    return await repository.listarTodosAgendamentos();
  }
}
