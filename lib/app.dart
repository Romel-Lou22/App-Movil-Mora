import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import 'core/constants/app_colors.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
// Data
import 'features/auth/data/repositories/auth_repository_impl.dart';
// Domain
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
// Features
import 'features/auth/presentation/screens/login_screen.dart';

/// Widget principal de la aplicación EcoMora
class EcoMoraApp extends StatelessWidget {
  const EcoMoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider de Autenticación
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUseCase: LoginUseCase(
              AuthRepositoryImpl(
                remoteDataSource: AuthRemoteDataSourceImpl(),
              ),
            ),
          ),
        ),

        // TODO: Agregar más providers cuando los necesites:
        // ChangeNotifierProvider(create: (_) => WeatherProvider(...)),
        // ChangeNotifierProvider(create: (_) => AlertsProvider(...)),
        // etc.
      ],
      child: MaterialApp(
        title: 'EcoMora',
        debugShowCheckedModeBanner: false,

        // Tema de la aplicación
        theme: ThemeData(
          // Colores principales
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,

          // Color scheme
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            secondary: AppColors.secondary,
            error: AppColors.error,
            background: AppColors.background,
            surface: AppColors.surface,
          ),

          // AppBar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),

          // Fuente predeterminada
          fontFamily: 'Roboto',

          // Text theme
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),

          // Elevación predeterminada
          useMaterial3: true,
        ),

        // Pantalla inicial
        home: const LoginScreen(),

        // TODO: Agregar rutas cuando tengas más pantallas
        // routes: {
        //   '/login': (context) => const LoginScreen(),
        //   '/register': (context) => const RegisterScreen(),
        //   '/home': (context) => const HomeScreen(),
        // },
      ),
    );
  }
}