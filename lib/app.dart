import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/routes/app_routes.dart';
// Core
import 'core/constants/app_colors.dart';
// Data
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
// Domain
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
// Providers
import 'features/auth/presentation/providers/auth_provider.dart';
// Screens - Auth
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
// Screens - Home
import 'features/home/presentation/screens/home_screen.dart';

/// Widget principal de la aplicación EcoMora
class EcoMoraApp extends StatelessWidget {
  const EcoMoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider de Autenticación
        ChangeNotifierProvider(
          create: (_) {
            // Crear una única instancia del repositorio
            final repository = AuthRepositoryImpl(
              remoteDataSource: AuthRemoteDataSourceImpl(),
            );

            // Crear el provider con ambos use cases
            return AuthProvider(
              loginUseCase: LoginUseCase(repository),
              registerUseCase: RegisterUseCase(repository),
              logoutUseCase: LogoutUseCase(repository),
            );
          },
        ),

        // TODO: Agregar más providers cuando los necesites:
        // ChangeNotifierProvider(create: (_) => WeatherProvider(...)),
        // ChangeNotifierProvider(create: (_) => AlertsProvider(...)),
        // ChangeNotifierProvider(create: (_) => ParcelasProvider(...)),
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
            surface: AppColors.surface,
          ),

          // AppBar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.secondary,
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

        // Ruta inicial
        initialRoute: AppRoutes.initial,

        // Definición de rutas
        routes: {
          // === Rutas de Autenticación ===
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),

          // === Rutas Principales ===
          AppRoutes.home: (context) => const HomeScreen(),

          // TODO: Agregar más rutas cuando crees las pantallas:
          // AppRoutes.predictions: (context) => const PredictionsScreen(),
          // AppRoutes.alerts: (context) => const AlertsScreen(),
          // AppRoutes.parcelas: (context) => const ParcelasScreen(),
          // AppRoutes.profile: (context) => const ProfileScreen(),
        },

        // Manejo de rutas desconocidas (opcional pero recomendado)
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          );
        },
      ),
    );
  }
}