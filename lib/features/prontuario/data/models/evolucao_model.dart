import 'package:contorno/features/prontuario/domain/entities/evolucao_entity.dart';

class EvolucaoModel extends EvolucaoEntity {
  EvolucaoModel({
    required super.id,
    required super.psicologoId,
    required super.pacienteId,
    required super.dataHora,
    required super.texto,
    super.createdAt,
  });

  factory EvolucaoModel.fromEntity(EvolucaoEntity entity) {
    return EvolucaoModel(
      id: entity.id,
      psicologoId: entity.psicologoId,
      pacienteId: entity.pacienteId,
      dataHora: entity.dataHora,
      texto: entity.texto,
      createdAt: entity.createdAt,
    );
  }

  factory EvolucaoModel.fromMap(Map<String, dynamic> map) {
    return EvolucaoModel(
      id: map['id'] as String,
      psicologoId: map['psicologo_id'] as String,
      pacienteId: map['paciente_id'] as String,
      dataHora: DateTime.parse(map['data_hora'] as String),
      texto: map['texto'] as String,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'psicologo_id': psicologoId,
      'paciente_id': pacienteId,
      'data_hora': dataHora.toIso8601String(),
      'texto': texto,
    };
  }
}
