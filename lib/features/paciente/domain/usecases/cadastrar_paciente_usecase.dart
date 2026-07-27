import 'package:contorno/features/paciente/domain/entities/paciente_entity.dart';
import 'package:contorno/features/paciente/domain/repositories/paciente_repository.dart';

class CadastrarPacienteUseCase {
  final IPacienteRepository repository;

  CadastrarPacienteUseCase(this.repository);

  Future<void> call(PacienteEntity paciente) async {
    if (paciente.nome.trim().isEmpty) {
      throw ArgumentError('O nome do paciente é obrigatório.');
    }
    if (paciente.telefone.trim().isEmpty) {
      throw ArgumentError('O telefone do paciente é obrigatório.');
    }
    if (paciente.valorSessaoPadrao < 0) {
      throw ArgumentError('O valor padrão da sessão não pode ser negativo.');
    }

    await repository.cadastrarPaciente(paciente);
  }
}
