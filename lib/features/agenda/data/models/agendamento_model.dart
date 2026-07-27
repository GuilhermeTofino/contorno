import 'package:contorno/features/agenda/domain/entities/agendamento_entity.dart';
import 'package:contorno/features/agenda/domain/enums/agenda_enums.dart';

class AgendamentoModel extends AgendamentoEntity {
  AgendamentoModel({
    required super.id,
    required super.psicologoId,
    required super.pacienteId,
    super.pacienteNome,
    required super.dataHora,
    required super.valorSessao,
    super.status = StatusAgendamento.agendada,
    super.statusPagamento = StatusPagamento.pendente,
    super.observacoes,
    super.isRecorrente = false,
    super.frequencia = FrequenciaRecorrencia.nenhuma,
    super.grupoRecorrenciaId,
  });

  factory AgendamentoModel.fromEntity(AgendamentoEntity entity) {
    return AgendamentoModel(
      id: entity.id,
      psicologoId: entity.psicologoId,
      pacienteId: entity.pacienteId,
      pacienteNome: entity.pacienteNome,
      dataHora: entity.dataHora,
      valorSessao: entity.valorSessao,
      status: entity.status,
      statusPagamento: entity.statusPagamento,
      observacoes: entity.observacoes,
      isRecorrente: entity.isRecorrente,
      frequencia: entity.frequencia,
      grupoRecorrenciaId: entity.grupoRecorrenciaId,
    );
  }

  factory AgendamentoModel.fromMap(Map<String, dynamic> map) {
    String? nomePaciente;
    if (map['pacientes'] != null && map['pacientes']['nome'] != null) {
      nomePaciente = map['pacientes']['nome'] as String;
    }

    return AgendamentoModel(
      id: map['id'] as String,
      psicologoId: map['psicologo_id'] as String,
      pacienteId: map['paciente_id'] as String,
      pacienteNome: nomePaciente ?? map['paciente_nome'] as String?,
      dataHora: DateTime.parse(map['data_hora'] as String),
      valorSessao: (map['valor_sessao'] as num).toDouble(),
      status: StatusAgendamento.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StatusAgendamento.agendada,
      ),
      statusPagamento: StatusPagamento.values.firstWhere(
        (e) => e.name == map['status_pagamento'],
        orElse: () => StatusPagamento.pendente,
      ),
      observacoes: map['observacoes'] as String?,
      isRecorrente: map['is_recorrente'] as bool? ?? false,
      frequencia: FrequenciaRecorrencia.values.firstWhere(
        (e) => e.name == map['frequencia'],
        orElse: () => FrequenciaRecorrencia.nenhuma,
      ),
      grupoRecorrenciaId: map['grupo_recorrencia_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'psicologo_id': psicologoId,
      'paciente_id': pacienteId,
      'data_hora': dataHora.toIso8601String(),
      'valor_sessao': valorSessao,
      'status': status.name,
      'status_pagamento': statusPagamento.name,
      'observacoes': observacoes,
      'is_recorrente': isRecorrente,
      'frequencia': frequencia.name,
      'grupo_recorrencia_id': grupoRecorrenciaId,
    };
  }
}
