import 'package:flutter/material.dart';
import '../../domain/entities/weather_data.dart';
import '../../domain/entities/soil_prediction.dart';
import '../../domain/usecases/get_soil_prediction_usecase.dart';

/// Estados posibles del provider
enum PredictionStatus {
  initial,    // Estado inicial
  loading,    // Cargando datos
  success,    // Operación exitosa
  error,      // Error en operación
}

/// Provider que maneja el estado de las predicciones
///
/// Responsabilidades:
/// - Obtener clima actual y predicción de suelo
/// - Manejar estado de carga y errores
/// - Mantener datos en memoria
/// - Proveer métodos para refrescar datos
class PredictionProvider extends ChangeNotifier {
  // Use Case
  final GetSoilPredictionUseCase getSoilPredictionUseCase;

  PredictionProvider({
    required this.getSoilPredictionUseCase,
  });

  // ========== ESTADO ==========

  /// Estado general del provider
  PredictionStatus _status = PredictionStatus.initial;

  /// Mensaje de error si algo falla
  String _errorMessage = '';

  /// Datos climáticos actuales
  WeatherData? _currentWeather;

  /// Predicción de nutrientes del suelo actual
  SoilPrediction? _currentSoilPrediction;

  /// Historial de registros (opcional, para futuro)
  List<(WeatherData, SoilPrediction)> _history = [];

  /// Timestamp de la última actualización
  DateTime? _lastUpdate;

  // ========== GETTERS ==========

  /// Estado actual
  PredictionStatus get status => _status;

  /// Mensaje de error
  String get errorMessage => _errorMessage;

  /// Indica si está cargando
  bool get isLoading => _status == PredictionStatus.loading;

  /// Indica si hay un error
  bool get hasError => _status == PredictionStatus.error;

  /// Indica si hay datos disponibles
  bool get hasData => _currentWeather != null && _currentSoilPrediction != null;

  /// Datos climáticos actuales
  WeatherData? get currentWeather => _currentWeather;

  /// Predicción de suelo actual
  SoilPrediction? get currentSoilPrediction => _currentSoilPrediction;

  /// Historial de registros
  List<(WeatherData, SoilPrediction)> get history => _history;

  /// Última actualización
  DateTime? get lastUpdate => _lastUpdate;

  /// Texto formateado de última actualización
  String get lastUpdateText {
    if (_lastUpdate == null) return 'Sin datos';

    final now = DateTime.now();
    final difference = now.difference(_lastUpdate!);

    if (difference.inMinutes < 1) {
      return 'Hace unos segundos';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }

  // ========== MÉTODOS PRINCIPALES ==========

  /// Obtiene predicciones completas (clima + suelo) y las guarda en BD
  ///
  /// Este es el método principal que se llama desde la UI
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela a analizar
  /// - [onPredictionComplete]: Callback opcional que se ejecuta después de guardar
  bool _isFetching = false;
  Future<void> fetchPredictions(
      String parcelaId, {
        Future<void> Function(WeatherData weather, SoilPrediction soil)? onPredictionComplete,
      }) async {
    // 🔥 Si ya está ejecutándose, ignorar
    if (_isFetching) {
      print('⏳ fetchPredictions ya en ejecución, ignorando llamada duplicada');
      return;
    }

    _isFetching = true; // 🔥 Marcar como ejecutándose
    print('🔄 ===================================');
    print('🔄 INICIANDO FETCHPREDICTIONS');
    print('📍 Parcela: $parcelaId');

    _status = PredictionStatus.loading;
    _errorMessage = '';
    notifyListeners();

    final result = await getSoilPredictionUseCase(parcelaId: parcelaId);

    result.fold(
          (error) {
        print('❌ ERROR al obtener predicciones: $error');
        _status = PredictionStatus.error;
        _errorMessage = error;
        _currentWeather = null;
        _currentSoilPrediction = null;
        _lastUpdate = null;
        notifyListeners();
      },
          (data) async {
        final (weather, soil) = data;

        print('✅ Clima obtenido: ${weather.temperatura}°C, ${weather.humedad}%');
        print('✅ Predicción LSTM obtenida: pH=${soil.ph}, N=${soil.nitrogeno}, P=${soil.fosforo}, K=${soil.potasio}');
        print('💾 Datos guardados en Supabase (datos_historicos)');

        _status = PredictionStatus.success;
        _currentWeather = weather;
        _currentSoilPrediction = soil;
        _errorMessage = '';
        _lastUpdate = DateTime.now();
        notifyListeners();

        // 🆕 LLAMAR AL CALLBACK PARA EVALUAR ALERTAS
        if (onPredictionComplete != null) {
          print('🚨 Ejecutando callback para evaluar alertas...');
          try {
            await onPredictionComplete(weather, soil);
            print('✅ Callback de alertas completado');
          } catch (e) {
            print('⚠️ Error en callback de alertas: $e');
            // No lanzamos el error para no romper el flujo
          }
        } else {
          print('⚠️ No se proporcionó callback para alertas');
        }

        _isFetching = false; // 🔥 Liberar

        print('🔄 FETCHPREDICTIONS COMPLETADO');
        print('🔄 ===================================');
      },
    );
  }

  /// Refresca los datos (vuelve a consultar APIs y guardar)
  ///
  /// Útil para el botón "Actualizar"
  Future<void> refresh(
      String parcelaId, {
        Future<void> Function(WeatherData weather, SoilPrediction soil)? onPredictionComplete,
      }) async {
    await fetchPredictions(parcelaId, onPredictionComplete: onPredictionComplete);
  }

  /// Obtiene solo los datos climáticos (sin guardar)
  ///
  /// Útil para consultas rápidas sin persistencia
  Future<void> fetchWeatherOnly(String parcelaId) async {
    _status = PredictionStatus.loading;
    notifyListeners();

    final result = await getSoilPredictionUseCase.getWeatherOnly(
      parcelaId: parcelaId,
    );

    result.fold(
          (error) {
        _status = PredictionStatus.error;
        _errorMessage = error;
        notifyListeners();
      },
          (weather) {
        _status = PredictionStatus.success;
        _currentWeather = weather;
        _errorMessage = '';
        notifyListeners();
      },
    );
  }

  /// Obtiene solo la predicción de suelo (sin guardar)
  ///
  /// Útil para pruebas o consultas sin persistir
  Future<void> fetchSoilOnly(String parcelaId) async {
    _status = PredictionStatus.loading;
    notifyListeners();

    final result = await getSoilPredictionUseCase.getSoilOnly(
      parcelaId: parcelaId,
    );

    result.fold(
          (error) {
        _status = PredictionStatus.error;
        _errorMessage = error;
        notifyListeners();
      },
          (soil) {
        _status = PredictionStatus.success;
        _currentSoilPrediction = soil;
        _errorMessage = '';
        notifyListeners();
      },
    );
  }

  /// Obtiene el historial de predicciones guardadas
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  /// - [limit]: Cantidad máxima de registros (default: 30)
  Future<void> fetchHistory({
    required String parcelaId,
    int limit = 30,
  }) async {
    final result = await getSoilPredictionUseCase.getHistory(
      parcelaId: parcelaId,
      limit: limit,
    );

    result.fold(
          (error) {
        _errorMessage = error;
        _history = [];
        notifyListeners();
      },
          (historyData) {
        _history = historyData;
        notifyListeners();
      },
    );
  }

  /// Obtiene el último registro guardado (sin consultar APIs)
  ///
  /// Útil para mostrar datos previos mientras se cargan nuevos
  Future<void> fetchLatestRecord(String parcelaId) async {
    final result = await getSoilPredictionUseCase.getLatest(
      parcelaId: parcelaId,
    );

    result.fold(
          (error) {
        // No hacer nada si no hay datos previos
        debugPrint('No hay datos previos: $error');
      },
          (data) {
        final (weather, soil) = data;
        _currentWeather = weather;
        _currentSoilPrediction = soil;
        notifyListeners();
      },
    );
  }

  // ========== MÉTODOS DE UTILIDAD ==========

  /// Verifica si los datos están desactualizados
  ///
  /// Considera desactualizados si:
  /// - Han pasado más de 1 hora desde la última actualización
  bool get isDataOutdated {
    if (_lastUpdate == null) return true;

    final now = DateTime.now();
    final difference = now.difference(_lastUpdate!);

    return difference.inHours >= 1;
  }

  /// Obtiene un resumen del estado del cultivo
  ///
  /// Retorna un mensaje descriptivo basado en las condiciones
  String get cultiveHealthSummary {
    if (!hasData) return 'Sin datos disponibles';

    final weather = _currentWeather!;
    final soil = _currentSoilPrediction!;

    // Contar condiciones óptimas
    int optimalConditions = 0;
    if (weather.isOptimalTemperature) optimalConditions++;
    if (weather.isOptimalHumidity) optimalConditions++;
    if (soil.phIsOptimal) optimalConditions++;
    if (soil.nitrogenoIsOptimal) optimalConditions++;
    if (soil.fosforoIsOptimal) optimalConditions++;
    if (soil.potasioIsOptimal) optimalConditions++;

    // Generar mensaje según cantidad de condiciones óptimas
    if (optimalConditions == 6) {
      return '✅ Excelente - Todas las condiciones son óptimas';
    } else if (optimalConditions >= 4) {
      return '👍 Bueno - La mayoría de condiciones son óptimas';
    } else if (optimalConditions >= 2) {
      return '⚠️ Regular - Algunas condiciones requieren atención';
    } else {
      return '🚨 Crítico - Se requiere acción inmediata';
    }
  }

  /// Obtiene todas las recomendaciones combinadas
  List<String> get allRecommendations {
    if (_currentSoilPrediction == null) return [];
    return _currentSoilPrediction!.allRecommendations;
  }

  /// Limpia el mensaje de error
  void clearError() {
    _status = PredictionStatus.initial;
    _errorMessage = '';
    notifyListeners();
  }

  /// Limpia todos los datos del provider
  void clear() {
    _status = PredictionStatus.initial;
    _errorMessage = '';
    _currentWeather = null;
    _currentSoilPrediction = null;
    _history = [];
    _lastUpdate = null;
    notifyListeners();
  }
}