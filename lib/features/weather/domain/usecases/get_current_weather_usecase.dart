// lib/features/weather/domain/usecases/get_current_weather_usecase.dart

import 'package:dartz/dartz.dart';
import '../entities/weather.dart';
import '../repositories/weather_repository.dart';

/// Caso de uso para obtener el clima actual
/// Encapsula la lógica de negocio
class GetCurrentWeatherUseCase {

  GetCurrentWeatherUseCase({required this.repository});
  final WeatherRepository repository;

  /// Ejecuta el caso de uso
  /// Retorna Either con error (Left) o datos (Right)
  Future<Either<String, Weather>> call() async {
    return await repository.getCurrentWeather();
  }
}