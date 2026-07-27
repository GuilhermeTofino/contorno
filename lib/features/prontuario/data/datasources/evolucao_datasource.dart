import 'package:contorno/features/prontuario/data/models/evolucao_model.dart';

abstract class IEvolucaoDatasource {
  Future<List<EvolucaoModel>> listarEvolucoesPorPaciente(String pacienteId);
  Future<void> cadastrarEvolucao(EvolucaoModel evolucao);
}
