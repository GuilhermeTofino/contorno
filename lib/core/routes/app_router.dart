import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:contorno/core/inject/inject.dart';
import 'package:contorno/features/auth/presentation/pages/cadastro_page.dart';
import 'package:contorno/features/auth/presentation/pages/login_page.dart';
import 'package:contorno/features/home/presentation/pages/home_page.dart';
import 'package:contorno/features/paciente/presentation/cubit/paciente_cubit.dart';
import 'package:contorno/features/paciente/presentation/pages/cadastrar_paciente_page.dart';
import 'package:contorno/features/splash/presentation/pages/splash_page.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/cadastro',
      builder: (context, state) => const CadastroPage(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/cadastrar-paciente',
      builder: (context, state) => BlocProvider<PacienteCubit>(
        create: (_) => getIt<PacienteCubit>(),
        child: const CadastrarPacientePage(),
      ),
    ),
  ],
);
