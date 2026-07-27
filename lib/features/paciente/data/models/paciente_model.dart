import 'package:contorno/features/paciente/domain/entities/paciente_entity.dart';
import 'package:contorno/features/paciente/domain/enums/paciente_enums.dart';

class PacienteModel extends PacienteEntity {
  PacienteModel({
    required super.id,
    required super.psicologoId,
    required super.nome,
    required super.telefone,
    required super.dataNascimento,
    required super.tipoAtendimento,
    required super.valorSessaoPadrao,
    super.contatoEmergenciaNome,
    super.contatoEmergenciaTelefone,
    super.status = StatusPaciente.ativo,
    super.temRecorrencia = false,
  });

  factory PacienteModel.fromEntity(PacienteEntity entity) {
    return PacienteModel(
      id: entity.id,
      psicologoId: entity.psicologoId,
      nome: entity.nome,
      telefone: entity.telefone,
      dataNascimento: entity.dataNascimento,
      tipoAtendimento: entity.tipoAtendimento,
      valorSessaoPadrao: entity.valorSessaoPadrao,
      contatoEmergenciaNome: entity.contatoEmergenciaNome,
      contatoEmergenciaTelefone: entity.contatoEmergenciaTelefone,
      status: entity.status,
      temRecorrencia: entity.temRecorrencia,
    );
  }

  factory PacienteModel.fromMap(Map<String, dynamic> map) {
    return PacienteModel(
      id: map['id'] as String,
      psicologoId: map['psicologo_id'] as String,
      nome: map['nome'] as String,
      telefone: map['telefone'] as String,
      dataNascimento: DateTime.parse(map['data_nascimento'] as String),
      tipoAtendimento: TipoAtendimento.values.firstWhere(
        (e) => e.name == map['tipo_atendimento'],
        orElse: () => TipoAtendimento.particular,
      ),
      valorSessaoPadrao: (map['valor_sessao_padrao'] as num).toDouble(),
      contatoEmergenciaNome: map['contato_emergencia_nome'] as String?,
      contatoEmergenciaTelefone: map['contato_emergencia_telefone'] as String?,
      status: StatusPaciente.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StatusPaciente.ativo,
      ),
      temRecorrencia: map['tem_recorrencia'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'psicologo_id': psicologoId,
      'nome': nome,
      'telefone': telefone,
      'data_nascimento': dataNascimento.toIso8601String(),
      'tipo_atendimento': tipoAtendimento.name,
      'valor_sessao_padrao': valorSessaoPadrao,
      'contato_emergencia_nome': contatoEmergenciaNome,
      'contato_emergencia_telefone': contatoEmergenciaTelefone,
      'status': status.name,
      'tem_recorrencia': temRecorrencia,
    };
  }
}
