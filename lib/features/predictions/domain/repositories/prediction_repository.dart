import 'package:dartz/dartz.dart';
import '../entities/weather_data.dart';
import '../entities/soil_prediction.dart';

/// Contrato del repositorio de predicciones
///
/// Define las operaciones para obtener datos climáticos y predicciones de suelo
/// Retorna Either<String, T> para manejo de errores:
/// - Left: Error (mensaje de error)
/// - Right: Éxito (datos)
abstract class PredictionRepository {
  /// Obtiene datos climáticos actuales desde OpenWeather API
  /// y predicción de nutrientes del suelo desde HuggingFace,
  /// luego los guarda COMBINADOS en la base de datos
  ///
  /// Este es el método principal que:
  /// 1. Llama a OpenWeather para obtener temperatura/humedad actual
  /// 2. Llama a HuggingFace para predecir pH/NPK del suelo
  /// 3. Guarda ambos datos en UN SOLO registro de datos_historicos
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela a analizar
  ///
  /// Retorna:
  /// - Left: Mensaje de error si falla
  /// - Right: Tupla con (WeatherData, SoilPrediction)
  Future<Either<String, (WeatherData, SoilPrediction)>> getPredictionsAndSave({
    required String parcelaId,
  });

  /// Obtiene solo los datos climáticos actuales de OpenWeather
  /// (sin guardar en BD, solo para consulta)
  ///
  /// Útil si solo necesitas ver el clima sin hacer predicción de suelo
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela (para obtener lat/lon)
  ///
  /// Retorna:
  /// - Left: Mensaje de error si falla
  /// - Right: Datos climáticos actuales
  Future<Either<String, WeatherData>> getCurrentWeatherOnly({
    required String parcelaId,
  });

  /// Obtiene solo la predicción de nutrientes del suelo
  /// (sin guardar en BD, solo para consulta)
  ///
  /// Útil para pruebas o consultas rápidas
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  ///
  /// Retorna:
  /// - Left: Mensaje de error si falla
  /// - Right: Predicción de nutrientes del suelo
  Future<Either<String, SoilPrediction>> getSoilPredictionOnly({
    required String parcelaId,
  });

  /// Obtiene el historial de registros completos (clima + suelo)
  /// desde la base de datos
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  /// - [limit]: Cantidad máxima de registros (default: 30)
  ///
  /// Retorna:
  /// - Left: Mensaje de error si falla
  /// - Right: Lista de tuplas (WeatherData, SoilPrediction)
  Future<Either<String, List<(WeatherData, SoilPrediction)>>> getHistory({
    required String parcelaId,
    int limit = 30,
  });

  /// Obtiene el último registro guardado (más reciente)
  ///
  /// Útil para mostrar "última actualización" sin hacer nueva consulta a APIs
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  ///
  /// Retorna:
  /// - Left: Mensaje de error si falla o no hay datos
  /// - Right: Tupla con los datos más recientes
  Future<Either<String, (WeatherData, SoilPrediction)>> getLatestRecord({
    required String parcelaId,
  });
}