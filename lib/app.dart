import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/routes/app_routes.dart';
// Core
import 'core/constants/app_colors.dart';

// ===== PREDICTIONS IMPORTS =====
import 'features/predictions/data/datasources/openweather_datasource.dart' as predictions_ds;
import 'features/predictions/data/datasources/huggingface_datasource.dart';
import 'features/predictions/data/repositories/prediction_repository_impl.dart';
import 'features/predictions/domain/usecases/get_soil_prediction_usecase.dart';
import 'features/predictions/presentation/providers/prediction_provider.dart';
// Screens - Predictions
import 'features/predictions/presentation/screens/predictions_screen.dart';

import 'features/profile/presentation/screens/grafica_screen.dart';

// ===== ALERTS IMPORTS =====
import 'features/alerts/data/datasources/alert_remote_datasource.dart';
import 'features/alerts/data/repositories/alert_repository_impl.dart';
import 'features/alerts/domain/usecases/create_alert_usecase.dart';
import 'features/alerts/domain/usecases/evaluate_thresholds_usecase.dart';
import 'features/alerts/domain/usecases/get_active_alerts_usecase.dart';
import 'features/alerts/domain/usecases/get_alerts_history_usecase.dart';
import 'features/alerts/domain/usecases/mark_alert_as_read_usecase.dart';
import 'features/alerts/presentation/providers/alert_provider.dart';
// Screens - Alerts
import 'features/alerts/presentation/screens/alerts_screen.dart';

// ===== PARCELAS IMPORTS - ✅ AGREGADO =====
import 'features/parcelas/data/datasources/parcela_remote_datasource.dart';
import 'features/parcelas/data/repositories/parcela_repository_impl.dart';
import 'features/parcelas/domain/entities/parcela.dart';
import 'features/parcelas/domain/usecases/create_parcela_usecase.dart';
import 'features/parcelas/domain/usecases/delete_parcela_usecase.dart';
import 'features/parcelas/domain/usecases/get_parcela_by_id_usecase.dart';
import 'features/parcelas/domain/usecases/get_parcelas_usecase.dart';
import 'features/parcelas/domain/usecases/update_parcela_usecase.dart';
import 'features/parcelas/presentation/providers/parcela_provider.dart';
// Screens - Parcelas
import 'features/parcelas/presentation/screens/parcelas_list_screen.dart';
import 'features/parcelas/presentation/screens/add_parcela_screen.dart';
import 'features/parcelas/presentation/screens/edit_parcela_screen.dart';
// ===============================================

// ===== AUTH IMPORTS =====
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
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

        // ===== ALERTS PROVIDER =====
        ChangeNotifierProvider(
          create: (_) {
            final dio = Dio();
            final dataSource = AlertRemoteDataSource();
            final repository = AlertRepositoryImpl(remoteDataSource: dataSource);

            final evaluateThresholdsUseCase = EvaluateThresholdsUseCase(repository);
            final getActiveAlertsUseCase = GetActiveAlertsUseCase(repository);
            final getAlertsHistoryUseCase = GetAlertsHistoryUseCase(repository);
            final markAlertAsReadUseCase = MarkAlertAsReadUseCase(repository);
            final createAlertUseCase = CreateAlertUseCase(repository);

            return AlertProvider(
              evaluateThresholdsUseCase: evaluateThresholdsUseCase,
              getActiveAlertsUseCase: getActiveAlertsUseCase,
              getAlertsHistoryUseCase: getAlertsHistoryUseCase,
              markAlertAsReadUseCase: markAlertAsReadUseCase,
              createAlertUseCase: createAlertUseCase,
            );
          },
        ),

        // ===== PREDICTIONS PROVIDER =====
        ChangeNotifierProvider(
          create: (_) {
            final dio = Dio();
            final openWeatherDataSource = predictions_ds.OpenWeatherDataSource(dio: dio);
            final huggingFaceDataSource = HuggingFaceDataSource(dio: dio);

            final repository = PredictionRepositoryImpl(
              openWeatherDataSource: openWeatherDataSource,
              huggingFaceDataSource: huggingFaceDataSource,
            );

            final getSoilPredictionUseCase = GetSoilPredictionUseCase(
              repository: repository,
            );

            return PredictionProvider(
              getSoilPredictionUseCase: getSoilPredictionUseCase,
            );
          },
        ),

        // ===== PARCELAS PROVIDER - ✅ AGREGADO =====
        ChangeNotifierProvider(
          create: (_) {
            // Crear DataSource
            final dataSource = ParcelaRemoteDataSourceImpl();

            // Crear Repository
            final repository = ParcelaRepositoryImpl(
              remoteDataSource: dataSource,
            );

            // Crear UseCases
            final getParcelasUseCase = GetParcelasUseCase(repository);
            final getParcelaByIdUseCase = GetParcelaByIdUseCase(repository);
            final createParcelaUseCase = CreateParcelaUseCase(repository);
            final updateParcelaUseCase = UpdateParcelaUseCase(repository);
            final deleteParcelaUseCase = DeleteParcelaUseCase(repository);

            // Crear Provider con todos los UseCases
            return ParcelaProvider(
              getParcelasUseCase: getParcelasUseCase,
              getParcelaByIdUseCase: getParcelaByIdUseCase,
              createParcelaUseCase: createParcelaUseCase,
              updateParcelaUseCase: updateParcelaUseCase,
              deleteParcelaUseCase: deleteParcelaUseCase,
            );
          },
        ),
        // ====================================================
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

          // === Ruta de Alertas ===
          AppRoutes.alerts: (context) => const AlertsScreen(),

          // === Rutas de Parcelas - ✅ AGREGADO ===
          AppRoutes.parcelas: (context) => const ParcelasListScreen(),
          AppRoutes.addParcela: (context) => const AddParcelaScreen(),
          AppRoutes.editParcela: (context) {
            // Obtener la parcela pasada como argumento
            final parcela = ModalRoute.of(context)!.settings.arguments;
            return EditParcelaScreen(parcela: parcela as Parcela);
          },
          // ================================================

          AppRoutes.predictions: (context) => const PredictionsScreen(),
          AppRoutes.profile: (context) => const GraficaScreen(),
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