import 'package:contorno/features/paciente/domain/entities/paciente_entity.dart';
import 'package:contorno/features/paciente/domain/repositories/paciente_repository.dart';

class ListarPacientesAtivosUseCase {
  final IPacienteRepository repository;

  ListarPacientesAtivosUseCase(this.repository);

  Future<List<PacienteEntity>> call() async {
    return await repository.buscarPacientesAtivos();
  }
}
