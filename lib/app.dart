import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/routes/app_routes.dart';
// Core
import 'core/constants/app_colors.dart';
// ===== ALERTS IMPORTS - AGREGAR ESTOS =====
import 'features/alerts/data/datasources/alert_remote_datasource.dart';
import 'features/alerts/data/repositories/alert_repository_impl.dart';
import 'features/alerts/domain/usecases/create_alert_usecase.dart';
import 'features/alerts/domain/usecases/evaluate_thresholds_usecase.dart';
import 'features/alerts/domain/usecases/get_active_alerts_usecase.dart';
import 'features/alerts/domain/usecases/get_alerts_history_usecase.dart';
import 'features/alerts/domain/usecases/mark_alert_as_read_usecase.dart';
import 'features/alerts/presentation/providers/alert_provider.dart';
// Screens - Alerts - AGREGAR ESTE
import 'features/alerts/presentation/screens/alerts_screen.dart';
// ===== AUTH IMPORTS =====
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
// ==========================================
import 'package:flutter_localizations/flutter_localizations.dart';

// Screens - Auth
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
// Screens - Home
import 'features/home/presentation/screens/home_screen.dart';
// ===== WEATHER IMPORTS =====
import 'features/weather/data/datasources/openweather_datasource.dart';
import 'features/weather/data/repositories/weather_repository_impl.dart';
import 'features/weather/domain/usecases/get_current_weather_usecase.dart';
import 'features/weather/presentation/providers/weather_provider.dart';

/// Widget principal de la aplicación EcoMora
class EcoMoraApp extends StatelessWidget {
  const EcoMoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ===== AUTH PROVIDER =====
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

        // ===== WEATHER PROVIDER =====
        ChangeNotifierProvider(
          create: (_) {
            final dio = Dio();
            final dataSource = OpenWeatherDataSource(dio: dio);
            final repository = WeatherRepositoryImpl(dataSource: dataSource);
            final useCase = GetCurrentWeatherUseCase(repository: repository);

            return WeatherProvider(getCurrentWeatherUseCase: useCase);
          },
        ),

        // ===== ALERTS PROVIDER - AGREGAR ESTE BLOQUE =====
        ChangeNotifierProvider(
          create: (_) {
            // Crear instancias de las dependencias
            final dio = Dio();
            final dataSource = AlertRemoteDataSource();
            final repository = AlertRepositoryImpl(remoteDataSource: dataSource);

            // Crear los use cases
            final evaluateThresholdsUseCase = EvaluateThresholdsUseCase(repository);
            final getActiveAlertsUseCase = GetActiveAlertsUseCase(repository);
            final getAlertsHistoryUseCase = GetAlertsHistoryUseCase(repository);
            final markAlertAsReadUseCase = MarkAlertAsReadUseCase(repository);
            final createAlertUseCase = CreateAlertUseCase(repository);

            // Crear el provider con todos los use cases
            return AlertProvider(
              evaluateThresholdsUseCase: evaluateThresholdsUseCase,
              getActiveAlertsUseCase: getActiveAlertsUseCase,
              getAlertsHistoryUseCase: getAlertsHistoryUseCase,
              markAlertAsReadUseCase: markAlertAsReadUseCase,
              createAlertUseCase: createAlertUseCase,
            );
          },
        ),
        // ================================================
      ],
      child: MaterialApp(
        title: 'EcoMora',
        debugShowCheckedModeBanner: false,

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
          Locale('en', 'US'),
        ],
        locale: const Locale('es', 'ES'),

        // Tema de la aplicación
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            secondary: AppColors.secondary,
            error: AppColors.error,
            surface: AppColors.surface,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          fontFamily: 'Roboto',
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

          // === Ruta de Alertas - AGREGAR ESTA LÍNEA ===
          AppRoutes.alerts: (context) => const AlertsScreen(

          ),
          // ===========================================
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