// lib/features/weather/domain/repositories/weather_repository.dart

import 'package:dartz/dartz.dart';
import '../entities/weather.dart';

/// Interfaz abstracta del repositorio de clima
abstract class WeatherRepository {
  /// Obtiene los datos del clima actual para una ubicación específica
  Future<Either<String, Weather>> getCurrentWeather({
    required double lat,
    required double lon,
  });
}
