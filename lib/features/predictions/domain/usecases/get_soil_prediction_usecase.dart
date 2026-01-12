import 'package:dartz/dartz.dart';
import '../entities/weather_data.dart';
import '../entities/soil_prediction.dart';
import '../repositories/prediction_repository.dart';

/// Caso de uso principal para obtener predicciones completas
///
/// Este caso de uso:
/// 1. Obtiene datos climáticos actuales de OpenWeather
/// 2. Obtiene predicción de nutrientes del suelo de HuggingFace
/// 3. Guarda ambos datos combinados en la base de datos
/// 4. Retorna los datos para mostrar en la UI
class GetSoilPredictionUseCase {
  final PredictionRepository repository;

  GetSoilPredictionUseCase({required this.repository});

  /// Ejecuta el caso de uso
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela a analizar
  ///
  /// Retorna:
  /// - Left: Mensaje de error si algo falla
  /// - Right: Tupla con (WeatherData, SoilPrediction)
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final result = await getSoilPredictionUseCase(parcelaId: 'uuid-123');
  ///
  /// result.fold(
  ///   (error) => print('Error: $error'),
  ///   (data) {
  ///     final (weather, soil) = data;
  ///     print('Temperatura: ${weather.temperatura}°C');
  ///     print('pH: ${soil.ph}');
  ///   },
  /// );
  /// ```
  Future<Either<String, (WeatherData, SoilPrediction)>> call({
    required String parcelaId,
  }) async {
    return await repository.getPredictionsAndSave(parcelaId: parcelaId);
  }

  /// Obtiene solo el clima actual (sin guardar)
  ///
  /// Útil para consultas rápidas sin persistencia
  Future<Either<String, WeatherData>> getWeatherOnly({
    required String parcelaId,
  }) async {
    return await repository.getCurrentWeatherOnly(parcelaId: parcelaId);
  }

  /// Obtiene solo la predicción de suelo (sin guardar)
  ///
  /// Útil para pruebas o consultas sin persistir
  Future<Either<String, SoilPrediction>> getSoilOnly({
    required String parcelaId,
  }) async {
    return await repository.getSoilPredictionOnly(parcelaId: parcelaId);
  }

  /// Obtiene el historial de predicciones guardadas
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  /// - [limit]: Cantidad máxima de registros (default: 30)
  Future<Either<String, List<(WeatherData, SoilPrediction)>>> getHistory({
    required String parcelaId,
    int limit = 30,
  }) async {
    return await repository.getHistory(
      parcelaId: parcelaId,
      limit: limit,
    );
  }

  /// Obtiene el último registro guardado
  ///
  /// Útil para mostrar "última actualización" sin consultar APIs externas
  Future<Either<String, (WeatherData, SoilPrediction)>> getLatest({
    required String parcelaId,
  }) async {
    return await repository.getLatestRecord(parcelaId: parcelaId);
  }
}