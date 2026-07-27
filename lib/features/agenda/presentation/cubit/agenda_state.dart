import 'package:contorno/features/agenda/domain/entities/agendamento_entity.dart';

abstract class AgendaState {}

class AgendaInitial extends AgendaState {}

class AgendaLoading extends AgendaState {}

class AgendaLoaded extends AgendaState {
  final DateTime dataSelecionada;
  final List<AgendamentoEntity> agendamentos;
  final Map<DateTime, List<AgendamentoEntity>> agendamentosPorData;

  AgendaLoaded({
    required this.dataSelecionada,
    required this.agendamentos,
    this.agendamentosPorData = const {},
  });
}

class AgendaSuccess extends AgendaState {
  final String message;

  AgendaSuccess({this.message = 'Sessão agendada com sucesso!'});
}

class AgendaError extends AgendaState {
  final String message;

  AgendaError(this.message);
}
