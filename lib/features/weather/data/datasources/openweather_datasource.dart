// lib/features/weather/data/datasources/openweather_datasource.dart

import 'package:dio/dio.dart';
import '../models/weather_model.dart';

/// DataSource que maneja las peticiones HTTP a OpenWeather API
class OpenWeatherDataSource {
  final Dio _dio;

  // Credenciales y configuración de la API
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = 'f3cf409a368f5d9b5ffbd8049bcfd53b';

  // Coordenadas fijas de Tisaleo, Ecuador
  static const String _lat = '-1.34627';
  static const String _lon = '-78.66877';

  OpenWeatherDataSource({Dio? dio}) : _dio = dio ?? Dio();

  /// Obtiene los datos del clima actual desde la API
  ///
  /// Retorna un [WeatherModel] con los datos actuales
  /// Lanza una excepción si la petición falla
  Future<WeatherModel> getCurrentWeather() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {
          'lat': _lat,
          'lon': _lon,
          'appid': _apiKey,
          'units': 'metric', // Para obtener temperatura en Celsius
          'lang': 'es', // Descripciones en español
        },
      );

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Error al obtener datos del clima: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}