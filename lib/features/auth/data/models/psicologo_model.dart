import 'package:contorno/features/auth/domain/entities/psicologo_entity.dart';
import 'package:contorno/features/auth/domain/enums/auth_enums.dart';

class PsicologoModel extends PsicologoEntity {
  PsicologoModel({
    required super.id,
    required super.nome,
    required super.email,
    required super.tipoPessoa,
    required super.crp,
  });

  factory PsicologoModel.fromEntity(PsicologoEntity entity) {
    return PsicologoModel(
      id: entity.id,
      nome: entity.nome,
      email: entity.email,
      tipoPessoa: entity.tipoPessoa,
      crp: entity.crp,
    );
  }

  factory PsicologoModel.fromMap(Map<String, dynamic> map) {
    return PsicologoModel(
      id: map['id'] as String,
      nome: map['nome'] as String,
      email: map['email'] as String,
      tipoPessoa: TipoPessoa.values.firstWhere(
        (e) => e.name == map['tipo_pessoa'],
        orElse: () => TipoPessoa.fisica,
      ),
      crp: map['crp'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'tipo_pessoa': tipoPessoa.name,
      'crp': crp,
    };
  }
}
