import 'package:contorno/features/paciente/data/datasources/paciente_datasource.dart';
import 'package:contorno/features/paciente/data/models/paciente_model.dart';
import 'package:contorno/features/paciente/domain/entities/paciente_entity.dart';
import 'package:contorno/features/paciente/domain/repositories/paciente_repository.dart';

class PacienteRepositoryImpl implements IPacienteRepository {
  final IPacienteDatasource datasource;

  PacienteRepositoryImpl(this.datasource);

  @override
  Future<void> cadastrarPaciente(PacienteEntity paciente) async {
    final model = PacienteModel.fromEntity(paciente);
    await datasource.cadastrarPaciente(model);
  }

  @override
  Future<void> atualizarPaciente(PacienteEntity paciente) async {
    final model = PacienteModel.fromEntity(paciente);
    await datasource.atualizarPaciente(model);
  }

  @override
  Future<List<PacienteEntity>> buscarPacientesAtivos() async {
    return await datasource.buscarPacientesAtivos();
  }

  @override
  Future<PacienteEntity?> buscarPacientePorId(String id) async {
    return await datasource.buscarPacientePorId(id);
  }
}
