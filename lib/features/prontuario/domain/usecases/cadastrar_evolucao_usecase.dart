import 'package:contorno/features/prontuario/domain/entities/evolucao_entity.dart';
import 'package:contorno/features/prontuario/domain/repositories/evolucao_repository.dart';

class CadastrarEvolucaoUseCase {
  final IEvolucaoRepository repository;

  CadastrarEvolucaoUseCase(this.repository);

  Future<void> call(EvolucaoEntity evolucao) async {
    if (evolucao.texto.trim().isEmpty) {
      throw ArgumentError('O texto da anotação clínica é obrigatório.');
    }
    await repository.cadastrarEvolucao(evolucao);
  }
}
