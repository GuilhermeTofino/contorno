import 'package:contorno/features/agenda/domain/enums/agenda_enums.dart';

class AgendamentoEntity {
  final String id;
  final String psicologoId;
  final String pacienteId;
  final String? pacienteNome;
  final DateTime dataHora;
  final double valorSessao;
  final StatusAgendamento status;
  final StatusPagamento statusPagamento;
  final String? observacoes;
  final bool isRecorrente;
  final FrequenciaRecorrencia frequencia;
  final String? grupoRecorrenciaId;

  AgendamentoEntity({
    required this.id,
    required this.psicologoId,
    required this.pacienteId,
    this.pacienteNome,
    required this.dataHora,
    required this.valorSessao,
    this.status = StatusAgendamento.agendada,
    this.statusPagamento = StatusPagamento.pendente,
    this.observacoes,
    this.isRecorrente = false,
    this.frequencia = FrequenciaRecorrencia.nenhuma,
    this.grupoRecorrenciaId,
  }) {
    if (psicologoId.trim().isEmpty) {
      throw ArgumentError('O ID do psicólogo é obrigatório.');
    }
    if (pacienteId.trim().isEmpty) {
      throw ArgumentError('O ID do paciente é obrigatório.');
    }
    if (valorSessao < 0) {
      throw ArgumentError('O valor da sessão não pode ser negativo.');
    }
  }
}
