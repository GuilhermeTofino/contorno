class EvolucaoEntity {
  final String id;
  final String psicologoId;
  final String pacienteId;
  final DateTime dataHora;
  final String texto;
  final DateTime? createdAt;

  EvolucaoEntity({
    required this.id,
    required this.psicologoId,
    required this.pacienteId,
    required this.dataHora,
    required this.texto,
    this.createdAt,
  }) {
    if (psicologoId.trim().isEmpty) {
      throw ArgumentError('O ID do psicólogo é obrigatório.');
    }
    if (pacienteId.trim().isEmpty) {
      throw ArgumentError('O ID do paciente é obrigatório.');
    }
    if (texto.trim().isEmpty) {
      throw ArgumentError('O texto da evolução clínica não pode ser vazio.');
    }
  }
}
