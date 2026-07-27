import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:contorno/features/agenda/data/datasources/agenda_datasource.dart';
import 'package:contorno/features/agenda/data/datasources/supabase/agenda_datasource_supabase_impl.dart';
import 'package:contorno/features/agenda/data/repositories/agenda_repository_impl.dart';
import 'package:contorno/features/agenda/domain/repositories/agenda_repository.dart';
import 'package:contorno/features/agenda/domain/usecases/cadastrar_agendamento_usecase.dart';
import 'package:contorno/features/agenda/domain/usecases/listar_agendamentos_por_data_usecase.dart';
import 'package:contorno/features/agenda/domain/usecases/listar_todos_agendamentos_usecase.dart';
import 'package:contorno/features/agenda/presentation/cubit/agenda_cubit.dart';
import 'package:contorno/features/auth/data/datasources/auth_datasource.dart';
import 'package:contorno/features/auth/data/datasources/supabase/auth_datasource_supabase_impl.dart';
import 'package:contorno/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:contorno/features/auth/data/services/mock_crp_validator_service_impl.dart';
import 'package:contorno/features/auth/domain/repositories/auth_repository.dart';
import 'package:contorno/features/auth/domain/services/crp_validator_service.dart';
import 'package:contorno/features/auth/domain/usecases/cadastrar_psicologo_usecase.dart';
import 'package:contorno/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:contorno/features/auth/domain/usecases/login_usecase.dart';
import 'package:contorno/features/auth/domain/usecases/logout_usecase.dart';
import 'package:contorno/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:contorno/features/paciente/data/datasources/paciente_datasource.dart';
import 'package:contorno/features/paciente/data/datasources/supabase/paciente_datasource_supabase_impl.dart';
import 'package:contorno/features/paciente/data/repositories/paciente_repository_impl.dart';
import 'package:contorno/features/paciente/domain/repositories/paciente_repository.dart';
import 'package:contorno/features/paciente/domain/usecases/cadastrar_paciente_usecase.dart';
import 'package:contorno/features/paciente/domain/usecases/listar_pacientes_ativos_usecase.dart';
import 'package:contorno/features/paciente/presentation/cubit/paciente_cubit.dart';
import 'package:contorno/features/prontuario/data/datasources/evolucao_datasource.dart';
import 'package:contorno/features/prontuario/data/datasources/supabase/evolucao_datasource_supabase_impl.dart';
import 'package:contorno/features/prontuario/data/repositories/evolucao_repository_impl.dart';
import 'package:contorno/features/prontuario/domain/repositories/evolucao_repository.dart';
import 'package:contorno/features/prontuario/domain/usecases/cadastrar_evolucao_usecase.dart';
import 'package:contorno/features/prontuario/domain/usecases/listar_evolucoes_por_paciente_usecase.dart';
import 'package:contorno/features/prontuario/presentation/cubit/evolucao_cubit.dart';

final getIt = GetIt.instance;

void initInject() {
  // Supabase Client
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // --- AUTH MODULE ---
  // Services
  getIt.registerLazySingleton<ICrpValidatorService>(
    () => MockCrpValidatorServiceImpl(),
  );

  // Datasource
  getIt.registerLazySingleton<IAuthDatasource>(
    () => AuthDatasourceSupabaseImpl(getIt<SupabaseClient>()),
  );

  // Repository
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(getIt<IAuthDatasource>()),
  );

  // Use Cases
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerLazySingleton<CadastrarPsicologoUseCase>(
    () => CadastrarPsicologoUseCase(
      repository: getIt<IAuthRepository>(),
      crpValidatorService: getIt<ICrpValidatorService>(),
    ),
  );
  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(getIt<IAuthRepository>()),
  );

  // Auth Cubit (Global Singleton)
  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      loginUseCase: getIt<LoginUseCase>(),
      cadastrarPsicologoUseCase: getIt<CadastrarPsicologoUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
    ),
  );

  // --- PACIENTE MODULE ---
  // Datasource
  getIt.registerLazySingleton<IPacienteDatasource>(
    () => PacienteDatasourceSupabaseImpl(getIt<SupabaseClient>()),
  );

  // Repository
  getIt.registerLazySingleton<IPacienteRepository>(
    () => PacienteRepositoryImpl(getIt<IPacienteDatasource>()),
  );

  // Use Cases
  getIt.registerLazySingleton<CadastrarPacienteUseCase>(
    () => CadastrarPacienteUseCase(getIt<IPacienteRepository>()),
  );
  getIt.registerLazySingleton<ListarPacientesAtivosUseCase>(
    () => ListarPacientesAtivosUseCase(getIt<IPacienteRepository>()),
  );

  // Cubits / Blocs (Factory)
  getIt.registerFactory<PacienteCubit>(
    () => PacienteCubit(
      cadastrarPacienteUseCase: getIt<CadastrarPacienteUseCase>(),
      listarPacientesAtivosUseCase: getIt<ListarPacientesAtivosUseCase>(),
    ),
  );

  // --- AGENDA MODULE ---
  // Datasource
  getIt.registerLazySingleton<IAgendaDatasource>(
    () => AgendaDatasourceSupabaseImpl(getIt<SupabaseClient>()),
  );

  // Repository
  getIt.registerLazySingleton<IAgendaRepository>(
    () => AgendaRepositoryImpl(getIt<IAgendaDatasource>()),
  );

  // Use Cases
  getIt.registerLazySingleton<ListarAgendamentosPorDataUseCase>(
    () => ListarAgendamentosPorDataUseCase(getIt<IAgendaRepository>()),
  );
  getIt.registerLazySingleton<ListarTodosAgendamentosUseCase>(
    () => ListarTodosAgendamentosUseCase(getIt<IAgendaRepository>()),
  );
  getIt.registerLazySingleton<CadastrarAgendamentoUseCase>(
    () => CadastrarAgendamentoUseCase(getIt<IAgendaRepository>()),
  );

  // Cubit (Factory)
  getIt.registerFactory<AgendaCubit>(
    () => AgendaCubit(
      listarAgendamentosPorDataUseCase: getIt<ListarAgendamentosPorDataUseCase>(),
      listarTodosAgendamentosUseCase: getIt<ListarTodosAgendamentosUseCase>(),
      cadastrarAgendamentoUseCase: getIt<CadastrarAgendamentoUseCase>(),
      agendaRepository: getIt<IAgendaRepository>(),
    ),
  );

  // --- PRONTUARIO MODULE ---
  // Datasource
  getIt.registerLazySingleton<IEvolucaoDatasource>(
    () => EvolucaoDatasourceSupabaseImpl(getIt<SupabaseClient>()),
  );

  // Repository
  getIt.registerLazySingleton<IEvolucaoRepository>(
    () => EvolucaoRepositoryImpl(getIt<IEvolucaoDatasource>()),
  );

  // Use Cases
  getIt.registerLazySingleton<ListarEvolucoesPorPacienteUseCase>(
    () => ListarEvolucoesPorPacienteUseCase(getIt<IEvolucaoRepository>()),
  );
  getIt.registerLazySingleton<CadastrarEvolucaoUseCase>(
    () => CadastrarEvolucaoUseCase(getIt<IEvolucaoRepository>()),
  );

  // Cubit (Factory)
  getIt.registerFactory<EvolucaoCubit>(
    () => EvolucaoCubit(
      listarEvolucoesPorPacienteUseCase: getIt<ListarEvolucoesPorPacienteUseCase>(),
      cadastrarEvolucaoUseCase: getIt<CadastrarEvolucaoUseCase>(),
    ),
  );
}
