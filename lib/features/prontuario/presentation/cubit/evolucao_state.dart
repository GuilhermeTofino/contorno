import 'package:contorno/features/prontuario/domain/entities/evolucao_entity.dart';

abstract class EvolucaoState {}

class EvolucaoInitial extends EvolucaoState {}

class EvolucaoLoading extends EvolucaoState {}

class EvolucaoLoaded extends EvolucaoState {
  final List<EvolucaoEntity> evolucoes;

  EvolucaoLoaded(this.evolucoes);
}

class EvolucaoSuccess extends EvolucaoState {
  final String message;

  EvolucaoSuccess({this.message = 'Evolução registrada com sucesso!'});
}

class EvolucaoError extends EvolucaoState {
  final String message;

  EvolucaoError(this.message);
}
