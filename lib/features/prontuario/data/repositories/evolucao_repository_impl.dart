import 'package:contorno/features/prontuario/data/datasources/evolucao_datasource.dart';
import 'package:contorno/features/prontuario/data/models/evolucao_model.dart';
import 'package:contorno/features/prontuario/domain/entities/evolucao_entity.dart';
import 'package:contorno/features/prontuario/domain/repositories/evolucao_repository.dart';

class EvolucaoRepositoryImpl implements IEvolucaoRepository {
  final IEvolucaoDatasource datasource;

  EvolucaoRepositoryImpl(this.datasource);

  @override
  Future<void> cadastrarEvolucao(EvolucaoEntity evolucao) async {
    final model = EvolucaoModel.fromEntity(evolucao);
    await datasource.cadastrarEvolucao(model);
  }

  @override
  Future<List<EvolucaoEntity>> listarEvolucoesPorPaciente(String pacienteId) async {
    return await datasource.listarEvolucoesPorPaciente(pacienteId);
  }
}
