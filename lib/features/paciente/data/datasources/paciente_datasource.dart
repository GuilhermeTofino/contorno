import 'package:contorno/features/paciente/data/models/paciente_model.dart';

abstract class IPacienteDatasource {
  Future<void> cadastrarPaciente(PacienteModel paciente);
  Future<void> atualizarPaciente(PacienteModel paciente);
  Future<List<PacienteModel>> buscarPacientesAtivos();
  Future<PacienteModel?> buscarPacientePorId(String id);
}
