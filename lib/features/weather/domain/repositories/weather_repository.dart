// lib/features/weather/domain/repositories/weather_repository.dart

import 'package:dartz/dartz.dart';
import '../entities/weather.dart';

/// Interfaz abstracta del repositorio de clima
/// Define el contrato que debe cumplir cualquier implementación
abstract class WeatherRepository {
  /// Obtiene los datos del clima actual
  ///
  /// Retorna:
  /// - [Right(Weather)]: Si la operación fue exitosa
  /// - [Left(String)]: Si hubo un error (mensaje de error)
  Future<Either<String, Weather>> getCurrentWeather();
}