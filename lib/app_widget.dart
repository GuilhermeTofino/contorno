import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:contorno/core/inject/inject.dart';
import 'package:contorno/core/routes/app_router.dart';
import 'package:contorno/core/theme/app_theme.dart';
import 'package:contorno/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:contorno/core/theme/theme_controller.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>(),
      child: AnimatedBuilder(
        animation: themeController,
        builder: (context, child) {
          return MaterialApp.router(
            title: 'Contorno Psi',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            routerConfig: appRouter,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('pt', 'BR')],
          );
        },
      ),
    );
  }
}
