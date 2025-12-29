// lib/features/weather/data/repositories/weather_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/openweather_datasource.dart';

/// Implementación del repositorio de clima
/// Conecta el datasource con la capa de dominio
class WeatherRepositoryImpl implements WeatherRepository {

  WeatherRepositoryImpl({required this.dataSource});
  final OpenWeatherDataSource dataSource;

  @override
  Future<Either<String, Weather>> getCurrentWeather() async {
    try {
      final weatherModel = await dataSource.getCurrentWeather();

      // Convierte WeatherModel (data) a Weather (domain)
      final weather = Weather(
        temperature: weatherModel.temperature,
        description: weatherModel.description,
        icon: weatherModel.icon,
        humidity: weatherModel.humidity,
      );

      return Right(weather);
    } catch (e) {
      return Left('Error al obtener el clima: ${e.toString()}');
    }
  }
}