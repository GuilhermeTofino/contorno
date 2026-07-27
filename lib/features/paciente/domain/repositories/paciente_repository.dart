import 'package:contorno/features/paciente/domain/entities/paciente_entity.dart';

abstract class IPacienteRepository {
  Future<void> cadastrarPaciente(PacienteEntity paciente);
  Future<void> atualizarPaciente(PacienteEntity paciente);
  Future<List<PacienteEntity>> buscarPacientesAtivos();
  Future<PacienteEntity?> buscarPacientePorId(String id);
}
