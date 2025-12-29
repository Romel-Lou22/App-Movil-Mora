import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

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

// ===== AGREGAR ESTOS IMPORTS =====
import 'features/weather/data/datasources/openweather_datasource.dart';
import 'features/weather/data/repositories/weather_repository_impl.dart';
import 'features/weather/domain/usecases/get_current_weather_usecase.dart';
import 'features/weather/presentation/providers/weather_provider.dart';
// ==================================

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
            final repository = AuthRepositoryImpl(
              remoteDataSource: AuthRemoteDataSourceImpl(),
            );

            return AuthProvider(
              loginUseCase: LoginUseCase(repository),
              registerUseCase: RegisterUseCase(repository),
              logoutUseCase: LogoutUseCase(repository),
            );
          },
        ),

        // ===== AGREGAR ESTE PROVIDER =====
        // Provider del Clima
        ChangeNotifierProvider(
          create: (_) {
            final dio = Dio();
            final dataSource = OpenWeatherDataSource(dio: dio);
            final repository = WeatherRepositoryImpl(dataSource: dataSource);
            final useCase = GetCurrentWeatherUseCase(repository: repository);

            return WeatherProvider(getCurrentWeatherUseCase: useCase);
          },
        ),
        // ==================================
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
        },

        // Manejo de rutas desconocidas
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          );
        },
      ),
    );
  }
}