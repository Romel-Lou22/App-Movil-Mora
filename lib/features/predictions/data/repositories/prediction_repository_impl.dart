import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/weather_data.dart';
import '../../domain/entities/soil_prediction.dart';
import '../../domain/repositories/prediction_repository.dart';
import '../datasources/openweather_datasource.dart';
import '../datasources/huggingface_datasource.dart';
import '../models/weather_data_model.dart';
import '../models/soil_prediction_model.dart';
import '../../../../core/config/supabase_config.dart';

/// Implementación del repositorio de predicciones
///
/// Actúa como intermediario entre los DataSources y los Use Cases
/// Responsabilidades:
/// - Orquestar llamadas a OpenWeather y HuggingFace
/// - Combinar ambos resultados en un solo registro
/// - Guardar en Supabase (tabla datos_historicos)
/// - Manejar errores y convertir excepciones en mensajes amigables
class PredictionRepositoryImpl implements PredictionRepository {
  final OpenWeatherDataSource openWeatherDataSource;
  final HuggingFaceDataSource huggingFaceDataSource;
  final SupabaseClient _supabase;

  PredictionRepositoryImpl({
    required this.openWeatherDataSource,
    required this.huggingFaceDataSource,
    SupabaseClient? supabase,
  }) : _supabase = supabase ?? SupabaseConfig.supabase;

  @override
  Future<Either<String, (WeatherData, SoilPrediction)>> getPredictionsAndSave({
    required String parcelaId,
  }) async {
    try {
      debugPrint('🔄 Iniciando obtención de predicciones para parcela: $parcelaId');

      // 1. Obtener clima actual de OpenWeather
      debugPrint('☁️ Obteniendo datos climáticos de OpenWeather...');
      final weatherModel = await openWeatherDataSource.getCurrentWeather(parcelaId);
      debugPrint('✅ Clima obtenido: ${weatherModel.temperatura}°C, ${weatherModel.humedad}%');

      // 2. Obtener predicción de suelo de HuggingFace
      debugPrint('🌱 Prediciendo nutrientes del suelo con HuggingFace...');
      final soilModel = await huggingFaceDataSource.predictSoilNutrients(parcelaId);
      debugPrint('✅ Predicción obtenida: pH=${soilModel.ph}, N=${soilModel.nitrogeno}');

      // 3. Guardar AMBOS datos combinados en un solo registro
      debugPrint('💾 Guardando datos combinados en Supabase...');
      await _saveCombinedData(
        parcelaId: parcelaId,
        weather: weatherModel,
        soil: soilModel,
      );
      debugPrint('✅ Datos guardados exitosamente');

      // 4. Retornar ambos como tupla
      return Right((weatherModel, soilModel));
    } catch (e) {
      debugPrint('🔴 ERROR en getPredictionsAndSave: $e');
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, WeatherData>> getCurrentWeatherOnly({
    required String parcelaId,
  }) async {
    try {
      debugPrint('☁️ Obteniendo solo clima para parcela: $parcelaId');
      final weatherModel = await openWeatherDataSource.getCurrentWeather(parcelaId);
      return Right(weatherModel);
    } catch (e) {
      debugPrint('🔴 ERROR en getCurrentWeatherOnly: $e');
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, SoilPrediction>> getSoilPredictionOnly({
    required String parcelaId,
  }) async {
    try {
      debugPrint('🌱 Obteniendo solo predicción de suelo para parcela: $parcelaId');
      final soilModel = await huggingFaceDataSource.predictSoilNutrients(parcelaId);
      return Right(soilModel);
    } catch (e) {
      debugPrint('🔴 ERROR en getSoilPredictionOnly: $e');
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, List<(WeatherData, SoilPrediction)>>> getHistory({
    required String parcelaId,
    int limit = 30,
  }) async {
    try {
      debugPrint('📜 Obteniendo historial para parcela: $parcelaId (limit: $limit)');

      final response = await _supabase
          .from('datos_historicos')
          .select('temperatura, humedad, descripcion_clima, ph, nitrogeno, fosforo, potasio')
          .eq('parcela_id', parcelaId)
          .not('temperatura', 'is', null)
          .not('ph', 'is', null)
          .order('fecha_hora', ascending: false)
          .limit(limit);

      // 🔧 SOLUCIÓN: Castear explícitamente a List<Map<String, dynamic>>
      final records = (response as List).cast<Map<String, dynamic>>();

      if (records.isEmpty) {
        debugPrint('⚠️ No hay registros históricos para esta parcela');
        return const Right([]);
      }

      // Ahora 'record' es correctamente Map<String, dynamic>
      final history = records.map((record) {
        final weather = WeatherDataModel.fromSupabaseJson(record);
        final soil = SoilPredictionModel.fromSupabaseJson(record);
        return (weather as WeatherData, soil as SoilPrediction);
      }).toList();

      debugPrint('✅ Se obtuvieron ${history.length} registros históricos');
      return Right(history);
    } catch (e) {
      debugPrint('🔴 ERROR en getHistory: $e');
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, (WeatherData, SoilPrediction)>> getLatestRecord({
    required String parcelaId,
  }) async {
    try {
      debugPrint('🔍 Obteniendo último registro para parcela: $parcelaId');

      final response = await _supabase
          .from('datos_historicos')
          .select('temperatura, humedad, descripcion_clima, ph, nitrogeno, fosforo, potasio')
          .eq('parcela_id', parcelaId)
          .not('temperatura', 'is', null)
          .not('ph', 'is', null)
          .order('fecha_hora', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ No hay registros para esta parcela');
        return const Left('No hay datos previos para esta parcela');
      }

      final weather = WeatherDataModel.fromSupabaseJson(response);
      final soil = SoilPredictionModel.fromSupabaseJson(response);

      debugPrint('✅ Último registro obtenido exitosamente');
      return Right((weather, soil));
    } catch (e) {
      debugPrint('🔴 ERROR en getLatestRecord: $e');
      return Left(_handleError(e));
    }
  }

  /// Guarda los datos combinados (clima + suelo) en un solo registro
  ///
  /// Tabla: datos_historicos
  /// Campos guardados:
  /// - parcela_id
  /// - fecha_hora (ahora)
  /// - temperatura, humedad, descripcion_clima (OpenWeather)
  /// - ph, nitrogeno, fosforo, potasio (HuggingFace)
  /// - es_prediccion = true (porque pH/NPK son predichos)
  Future<void> _saveCombinedData({
    required String parcelaId,
    required WeatherDataModel weather,
    required SoilPredictionModel soil,
  }) async {
    try {
      final now = DateTime.now();

      // Combinar ambos Maps
      final combinedData = {
        'parcela_id': parcelaId,
        'fecha_hora': now.toIso8601String(),

        // Datos de clima (OpenWeather)
        ...weather.toSupabaseMap(),

        // Datos de suelo (HuggingFace)
        ...soil.toSupabaseMap(),

        // Marcamos como predicción porque pH/NPK son predichos por IA
        'es_prediccion': true,
        'created_at': now.toIso8601String(),
      };

      debugPrint('📦 Datos a guardar: $combinedData');

      await _supabase.from('datos_historicos').insert(combinedData);

      debugPrint('✅ Registro insertado exitosamente en datos_historicos');
    } catch (e) {
      throw Exception('Error al guardar datos combinados: $e');
    }
  }

  /// Maneja y formatea los errores
  ///
  /// Convierte excepciones técnicas en mensajes amigables para el usuario
  String _handleError(Object error) {
    debugPrint('🔴 ERROR ORIGINAL: $error');
    debugPrint('🔴 STACK TRACE: ${StackTrace.current}');

    final errorMessage = error.toString();

    // Errores de red
    if (errorMessage.contains('SocketException') ||
        errorMessage.contains('NetworkException') ||
        errorMessage.contains('Sin conexión a internet')) {
      return 'Sin conexión a internet. Verifica tu conexión.';
    }

    // Errores de timeout
    if (errorMessage.contains('TimeoutException') ||
        errorMessage.contains('Tiempo de espera agotado')) {
      return 'La operación tardó demasiado. Intenta nuevamente.';
    }

    // Errores de OpenWeather
    if (errorMessage.contains('OpenWeather')) {
      return 'Error al obtener datos climáticos. Intenta más tarde.';
    }

    // Errores de HuggingFace
    if (errorMessage.contains('HuggingFace')) {
      return 'Error al predecir nutrientes del suelo. Intenta más tarde.';
    }

    // Errores de coordenadas
    if (errorMessage.contains('coordenadas')) {
      return errorMessage.split('Exception: ').last;
    }

    // Errores de parcela no encontrada
    if (errorMessage.contains('No se encontró la parcela')) {
      return errorMessage.split('Exception: ').last;
    }

    // Errores de Supabase
    if (errorMessage.contains('Supabase')) {
      return 'Error al conectar con el servidor. Intenta más tarde.';
    }

    // Error genérico
    return 'Ocurrió un error inesperado. Intenta nuevamente.';
  }
}