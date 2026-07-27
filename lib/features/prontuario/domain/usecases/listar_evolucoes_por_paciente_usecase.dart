import 'package:contorno/features/prontuario/domain/entities/evolucao_entity.dart';
import 'package:contorno/features/prontuario/domain/repositories/evolucao_repository.dart';

class ListarEvolucoesPorPacienteUseCase {
  final IEvolucaoRepository repository;

  ListarEvolucoesPorPacienteUseCase(this.repository);

  Future<List<EvolucaoEntity>> call(String pacienteId) async {
    return await repository.listarEvolucoesPorPaciente(pacienteId);
  }
}
