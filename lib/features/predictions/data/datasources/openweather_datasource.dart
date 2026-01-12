import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/weather_data_model.dart';
import '../../../../core/config/supabase_config.dart';

/// DataSource que maneja las operaciones con OpenWeather API
///
/// Responsabilidades:
/// - Obtener coordenadas (lat/lon) de la parcela desde Supabase
/// - Consumir OpenWeather API para obtener clima actual
/// - Convertir la respuesta del API a WeatherDataModel
class OpenWeatherDataSource {
  final Dio _dio;
  final SupabaseClient _supabase;

  // Configuración de OpenWeather API
  static const String _apiKey = 'f3cf409a368f5d9b5ffbd8049bcfd53b';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  OpenWeatherDataSource({
    Dio? dio,
    SupabaseClient? supabase,
  })  : _dio = dio ?? Dio(),
        _supabase = supabase ?? SupabaseConfig.supabase;

  /// Obtiene los datos climáticos actuales para una parcela
  ///
  /// Pasos:
  /// 1. Obtiene las coordenadas (lat/lon) de la parcela desde Supabase
  /// 2. Llama a OpenWeather API con las coordenadas
  /// 3. Convierte la respuesta a WeatherDataModel
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  ///
  /// Retorna: WeatherDataModel con datos climáticos actuales
  ///
  /// Lanza excepción si:
  /// - No se encuentra la parcela
  /// - La parcela no tiene coordenadas
  /// - Falla la llamada al API
  Future<WeatherDataModel> getCurrentWeather(String parcelaId) async {
    try {
      // 1. Obtener coordenadas de la parcela
      final coordenadas = await _getParcelaCoordinates(parcelaId);

      final latitud = coordenadas['latitud'] as double;
      final longitud = coordenadas['longitud'] as double;

      // 2. Llamar a OpenWeather API
      final response = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {
          'lat': latitud,
          'lon': longitud,
          'appid': _apiKey,
          'units': 'metric', // Temperatura en Celsius
          'lang': 'es',      // Descripción en español
        },
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        // 3. Convertir respuesta a modelo
        return WeatherDataModel.fromOpenWeatherResponse(
          response.data as Map<String, dynamic>,
        );
      } else if (response.statusCode == 401) {
        throw Exception(
          'API Key de OpenWeather inválida. Verifica la configuración.',
        );
      } else if (response.statusCode == 404) {
        throw Exception(
          'No se encontraron datos climáticos para estas coordenadas.',
        );
      } else {
        throw Exception(
          'Error del API de OpenWeather: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'Tiempo de espera agotado al conectar con OpenWeather',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Sin conexión a internet. Verifica tu conexión.',
        );
      } else {
        throw Exception('Error de red al obtener clima: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error al obtener datos climáticos: $e');
    }
  }

  /// Obtiene las coordenadas (latitud, longitud) de una parcela desde Supabase
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  ///
  /// Retorna: Map con 'latitud' y 'longitud'
  ///
  /// Lanza excepción si:
  /// - No se encuentra la parcela
  /// - La parcela no tiene coordenadas configuradas
  Future<Map<String, dynamic>> _getParcelaCoordinates(String parcelaId) async {
    try {
      final response = await _supabase
          .from('parcelas')
          .select('latitud, longitud, nombre_parcela')
          .eq('id', parcelaId)
          .maybeSingle();

      if (response == null) {
        throw Exception(
          'No se encontró la parcela con ID: $parcelaId',
        );
      }

      final latitud = response['latitud'];
      final longitud = response['longitud'];

      if (latitud == null || longitud == null) {
        final nombreParcela = response['nombre_parcela'] ?? 'desconocida';
        throw Exception(
          'La parcela "$nombreParcela" no tiene coordenadas configuradas. '
              'Por favor, configura las coordenadas en la sección de parcelas.',
        );
      }

      return {
        'latitud': (latitud as num).toDouble(),
        'longitud': (longitud as num).toDouble(),
      };
    } catch (e) {
      if (e.toString().contains('no tiene coordenadas')) {
        rethrow;
      }
      throw Exception(
        'Error al obtener coordenadas de la parcela: $e',
      );
    }
  }
}