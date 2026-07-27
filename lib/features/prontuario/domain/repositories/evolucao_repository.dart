import 'package:contorno/features/prontuario/domain/entities/evolucao_entity.dart';

abstract class IEvolucaoRepository {
  Future<List<EvolucaoEntity>> listarEvolucoesPorPaciente(String pacienteId);
  Future<void> cadastrarEvolucao(EvolucaoEntity evolucao);
}
