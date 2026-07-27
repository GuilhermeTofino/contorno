import 'package:contorno/features/paciente/domain/entities/paciente_entity.dart';

abstract class PacienteState {}

class PacienteInitial extends PacienteState {}

class PacienteLoading extends PacienteState {}

class PacienteLoaded extends PacienteState {
  final List<PacienteEntity> pacientes;

  PacienteLoaded(this.pacientes);
}

class PacienteSuccess extends PacienteState {
  final PacienteEntity? paciente;
  final String message;

  PacienteSuccess({
    this.paciente,
    this.message = 'Paciente cadastrado com sucesso!',
  });
}

class PacienteError extends PacienteState {
  final String message;

  PacienteError(this.message);
}
