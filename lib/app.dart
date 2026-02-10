import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/routes/app_routes.dart';
import 'core/constants/app_colors.dart';

// ===== SPLASH IMPORTS =====
import 'features/splash/presentation/screens/splash_screen.dart';

// ===== PREDICTIONS IMPORTS =====
import 'features/alerts/data/datasources/alert_engine_remote_datasource.dart';
import 'features/alerts/data/repositories/alert_engine_repository_impl.dart';
import 'features/predictions/data/datasources/openweather_datasource.dart' as predictions_ds;
import 'features/predictions/data/datasources/huggingface_datasource.dart';
import 'features/predictions/data/repositories/prediction_repository_impl.dart';
import 'features/predictions/domain/usecases/get_soil_prediction_usecase.dart';
import 'features/predictions/presentation/providers/prediction_provider.dart';
import 'features/predictions/presentation/screens/predictions_screen.dart';

import 'features/profile/presentation/screens/grafica_screen.dart';

// ===== ALERTS IMPORTS =====
import 'features/alerts/data/datasources/alert_remote_datasource.dart';
import 'features/alerts/data/repositories/alert_repository_impl.dart';
import 'features/alerts/domain/usecases/evaluate_thresholds_usecase.dart';
import 'features/alerts/domain/usecases/get_active_alerts_usecase.dart';
import 'features/alerts/domain/usecases/get_alerts_history_usecase.dart';
import 'features/alerts/domain/usecases/mark_alert_as_read_usecase.dart';
import 'features/alerts/presentation/providers/alert_provider.dart';
import 'features/alerts/presentation/screens/alerts_screen.dart';

// ===== PARCELAS IMPORTS =====
import 'features/parcelas/data/datasources/parcela_remote_datasource.dart';
import 'features/parcelas/data/repositories/parcela_repository_impl.dart';
import 'features/parcelas/domain/entities/parcela.dart';
import 'features/parcelas/domain/usecases/create_parcela_usecase.dart';
import 'features/parcelas/domain/usecases/delete_parcela_usecase.dart';
import 'features/parcelas/domain/usecases/get_parcela_by_id_usecase.dart';
import 'features/parcelas/domain/usecases/get_parcelas_usecase.dart';
import 'features/parcelas/domain/usecases/update_parcela_usecase.dart';
import 'features/parcelas/presentation/providers/parcela_provider.dart';
import 'features/parcelas/presentation/screens/parcelas_list_screen.dart';
import 'features/parcelas/presentation/screens/add_parcela_screen.dart';
import 'features/parcelas/presentation/screens/edit_parcela_screen.dart';

// ===== AUTH IMPORTS =====
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';

// ===== HOME IMPORTS =====
import 'features/home/presentation/screens/home_screen.dart';
import 'features/home/presentation/screens/main_shell_screen.dart';

//==Loading Screen Imports==
import 'features/loading/presentation/screens/data_loading_screen.dart';

// ===== STATISTICS IMPORTS ===== 👈 NUEVO
import 'features/statistics/presentation/pages/statistics_page.dart';
import 'features/statistics/presentation/providers/statistics_provider.dart';
import 'features/statistics/services/statistics_service.dart';

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
    debugPrint('🏗️ [APP] Construyendo EcoMoraApp con MultiProvider');

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
            final alertsDb = AlertRemoteDataSource();
            final alertsRepository = AlertRepositoryImpl(remoteDataSource: alertsDb);
            final engineDs = AlertEngineRemoteDataSource(dio: dio, alertsDb: alertsDb);
            final engineRepository = AlertEngineRepositoryImpl(remote: engineDs);
            final evaluateThresholdsUseCase = EvaluateThresholdsUseCase(engineRepository);
            final getActiveAlertsUseCase = GetActiveAlertsUseCase(alertsRepository);
            final getAlertsHistoryUseCase = GetAlertsHistoryUseCase(alertsRepository);
            final markAlertAsReadUseCase = MarkAlertAsReadUseCase(alertsRepository);

            return AlertProvider(
              evaluateThresholdsUseCase: evaluateThresholdsUseCase,
              getActiveAlertsUseCase: getActiveAlertsUseCase,
              getAlertsHistoryUseCase: getAlertsHistoryUseCase,
              markAlertAsReadUseCase: markAlertAsReadUseCase,
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

        // ===== PARCELAS PROVIDER =====
        ChangeNotifierProvider(
          create: (_) {
            final dataSource = ParcelaRemoteDataSourceImpl();
            final repository = ParcelaRepositoryImpl(
              remoteDataSource: dataSource,
            );

            final getParcelasUseCase = GetParcelasUseCase(repository);
            final getParcelaByIdUseCase = GetParcelaByIdUseCase(repository);
            final createParcelaUseCase = CreateParcelaUseCase(repository);
            final updateParcelaUseCase = UpdateParcelaUseCase(repository);
            final deleteParcelaUseCase = DeleteParcelaUseCase(repository);

            return ParcelaProvider(
              getParcelasUseCase: getParcelasUseCase,
              getParcelaByIdUseCase: getParcelaByIdUseCase,
              createParcelaUseCase: createParcelaUseCase,
              updateParcelaUseCase: updateParcelaUseCase,
              deleteParcelaUseCase: deleteParcelaUseCase,
            );
          },
        ),

        // ===== STATISTICS PROVIDER ===== 👈 NUEVO
        ChangeNotifierProvider(
          create: (_) {
            debugPrint('🏗️ [PROVIDER] Creando StatisticsProvider');
            final service = StatisticsService();

            return StatisticsProvider(service: service);
          },
        ),
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

        home: const SplashScreen(),

        // Definición de rutas
        routes: {
          // === Rutas de Autenticación ===
          AppRoutes.login: (context) {
            debugPrint('🎬 [ROUTE] Navegando a LoginScreen');
            return const LoginScreen();
          },
          AppRoutes.register: (context) {
            debugPrint('🎬 [ROUTE] Navegando a RegisterScreen');
            return const RegisterScreen();
          },
          AppRoutes.loading: (context) {
            debugPrint('🎬 [ROUTE] Navegando a DataLoadingScreen');
            return const DataLoadingScreen();
          },

          // === Rutas Principales ===
          AppRoutes.home: (context) {
            debugPrint('🎬 [ROUTE] Navegando a MainShellScreen');
            return const MainShellScreen();
          },

          // === Ruta de Alertas ===
          AppRoutes.alerts: (context) {
            debugPrint('🎬 [ROUTE] Navegando a AlertsScreen');
            return const AlertsScreen();
          },

          // === Rutas de Parcelas ===
          AppRoutes.parcelas: (context) {
            debugPrint('🎬 [ROUTE] Navegando a ParcelasListScreen');
            return const ParcelasListScreen();
          },
          AppRoutes.addParcela: (context) {
            debugPrint('🎬 [ROUTE] Navegando a AddParcelaScreen');
            return const AddParcelaScreen();
          },
          AppRoutes.editParcela: (context) {
            debugPrint('🎬 [ROUTE] Navegando a EditParcelaScreen');
            final parcela = ModalRoute.of(context)!.settings.arguments;
            return EditParcelaScreen(parcela: parcela as Parcela);
          },

          // === Otras rutas ===
          AppRoutes.predictions: (context) {
            debugPrint('🎬 [ROUTE] Navegando a PredictionsScreen');
            return const PredictionsScreen();
          },

          AppRoutes.statistics: (context) {
            debugPrint('🎬 [ROUTE] Navegando a StatisticsPage');
            return const StatisticsPage();
          },
        },

        onUnknownRoute: (settings) {
          debugPrint('⚠️ [ROUTE] Ruta desconocida: ${settings.name}');
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          );
        },
      ),
    );
  }
}