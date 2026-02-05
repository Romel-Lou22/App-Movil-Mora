import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/soil_prediction_model.dart';
import '../../../../core/config/supabase_config.dart';

/// DataSource que maneja las operaciones con HuggingFace API
///
/// Responsabilidades:
/// - Obtener datos reales desde el API de Sensor (CSV)
/// - Preparar array de 96 valores (24 timesteps × 4 features)
/// - Consumir HuggingFace API para predicción de nutrientes
/// - Convertir la respuesta del API a SoilPredictionModel
class HuggingFaceDataSource {
  final Dio _dio;
  final SupabaseClient _supabase;

  // Configuración de HuggingFace API
  static const String _huggingFaceUrl =
      'https://roca22-api-clima-prediccionv.hf.space';

  // Configuración del API de Sensor
  static const String _sensorApiUrl =
      'https://mora-soil-lstm-api.vercel.app';

  HuggingFaceDataSource({
    Dio? dio,
    SupabaseClient? supabase,
  })  : _dio = dio ?? Dio(),
        _supabase = supabase ?? SupabaseConfig.supabase;

  /// Predice los nutrientes del suelo para una parcela
  Future<SoilPredictionModel> predictSoilNutrients(String parcelaId) async {
    try {
      // 1. Preparar los 96 valores (24 timesteps × 4 features)
      final features = await _prepare24Timesteps(parcelaId);

      // 2. Logs detallados del payload
      debugPrint('📦 ===== DETALLES DE LA PETICIÓN =====');
      debugPrint('📦 URL: $_huggingFaceUrl/predict/suelo');
      debugPrint('📦 Total de features: ${features.length}');
      debugPrint('📦 Primeros 20 valores: ${features.take(20).toList()}');
      debugPrint('📦 Últimos 4 valores: ${features.skip(features.length - 4).toList()}');

      final payload = {'features': features};
      final payloadStr = payload.toString();
      debugPrint('📦 Payload (primeros 200 chars): ${payloadStr.substring(0, payloadStr.length > 200 ? 200 : payloadStr.length)}...');

      // 3. Llamar a HuggingFace API
      debugPrint('🚀 Enviando petición a HuggingFace...');

      final response = await _dio.post(
        '$_huggingFaceUrl/predict/suelo',
        data: payload,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) {
            debugPrint('📥 Status recibido: $status');
            return status! < 500;
          },
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      debugPrint('✅ Respuesta recibida: Status ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ Datos recibidos: ${response.data}');
        return SoilPredictionModel.fromHuggingFaceResponse(
          response.data as Map<String, dynamic>,
        );
      } else if (response.statusCode == 503) {
        debugPrint('⚠️ Error 503: El servicio está temporalmente no disponible');
        throw Exception(
          'El servicio de predicción está iniciándose. Por favor, intenta nuevamente en unos segundos.',
        );
      } else {
        debugPrint('❌ Error inesperado del API: ${response.statusCode}');
        throw Exception(
          'Error del API de HuggingFace: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('🔴 DioException capturado:');
      debugPrint('   Tipo: ${e.type}');
      debugPrint('   Mensaje: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'Tiempo de espera agotado al conectar con HuggingFace',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Sin conexión a internet. Verifica tu conexión.',
        );
      } else {
        throw Exception('Error de red al predecir nutrientes: ${e.message}');
      }
    } catch (e) {
      debugPrint('🔴 Excepción general: $e');
      throw Exception('Error al predecir nutrientes del suelo: $e');
    }
  }

  /// Prepara array de 96 valores para el modelo de ML
  ///
  /// ESTRATEGIA ACTUALIZADA:
  /// 1. Intenta obtener 24 registros desde el API de Sensor (CSV real)
  /// 2. Si falla, genera datos sintéticos como fallback
  Future<List<double>> _prepare24Timesteps(String parcelaId) async {
    try {
      // ⭐ PRIORIDAD 1: Obtener datos REALES del API de Sensor
      debugPrint('🌱 ===== OBTENIENDO DATOS DEL SENSOR =====');
      final sensorData = await _getDataFromSensorAPI(24);

      if (sensorData.isNotEmpty) {
        debugPrint('✅ Se obtuvieron ${sensorData.length} registros REALES del sensor');
        return _convertToFeatureArray(sensorData);
      } else {
        throw Exception('El API del sensor no devolvió datos');
      }
    } catch (e) {
      // FALLBACK: Si falla el API del sensor, usar sintéticos
      debugPrint('⚠️ No se pudieron obtener datos del sensor: $e');
      debugPrint('⚠️ Usando 24 registros sintéticos como fallback...');

      final synthetic = _generateSyntheticData(24);
      return _convertToFeatureArray(synthetic);
    }
  }

  /// ⭐ NUEVO: Obtiene datos REALES desde el API de Sensor (CSV)
  ///
  /// Llama al endpoint /sensor-data del API desplegado en Vercel
  ///
  /// Parámetros:
  /// - [count]: Cantidad de registros a obtener (default: 24)
  ///
  /// Retorna: Lista de Maps con datos reales del CSV
  Future<List<Map<String, dynamic>>> _getDataFromSensorAPI(int count) async {
    try {
      debugPrint('📡 Llamando al API de Sensor...');
      debugPrint('   URL: $_sensorApiUrl/sensor-data?count=$count&mode=sequential');

      final response = await _dio.get(
        '$_sensorApiUrl/sensor-data',
        queryParameters: {
          'count': count,
          'mode': 'sequential', // Modo secuencial (avanza en el tiempo)
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = response.data as Map<String, dynamic>;

        debugPrint('✅ Respuesta del Sensor API:');
        debugPrint('   - Success: ${jsonResponse['success']}');
        debugPrint('   - Count: ${jsonResponse['count']}');
        debugPrint('   - Current Index: ${jsonResponse['current_index']}');
        debugPrint('   - Total Records: ${jsonResponse['total_records']}');
        debugPrint('   - Message: ${jsonResponse['message']}');

        final dataList = jsonResponse['data'] as List;

        // Convertir a formato compatible
        final sensorData = dataList.map((item) {
          final record = item as Map<String, dynamic>;
          return {
            'ph': record['ph'],
            'nitrogeno': record['nitrogeno'],
            'fosforo': record['fosforo'],
            'potasio': record['potasio'],
          };
        }).toList();

        debugPrint('✅ ${sensorData.length} registros procesados del sensor');

        // Mostrar primeros 3 registros para verificar
        if (sensorData.isNotEmpty) {
          debugPrint('📊 Primeros 3 registros del sensor:');
          for (int i = 0; i < (sensorData.length > 3 ? 3 : sensorData.length); i++) {
            final r = sensorData[i];
            debugPrint('   [$i] pH: ${r['ph']}, N: ${r['nitrogeno']}, P: ${r['fosforo']}, K: ${r['potasio']}');
          }
        }

        return sensorData;
      } else {
        throw Exception(
          'El API del sensor respondió con status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('🔴 Error al llamar al API del sensor:');
      debugPrint('   Tipo: ${e.type}');
      debugPrint('   Mensaje: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Timeout al conectar con el API del sensor');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No se pudo conectar con el API del sensor');
      } else {
        throw Exception('Error de red con el API del sensor: ${e.message}');
      }
    } catch (e) {
      debugPrint('🔴 Excepción al obtener datos del sensor: $e');
      throw Exception('Error al obtener datos del sensor: $e');
    }
  }

  /// Convierte lista de registros a array de 96 valores
  ///
  /// Formato de entrada:
  /// [
  ///   {'ph': 6.5, 'nitrogeno': 45, 'fosforo': 30, 'potasio': 25},
  ///   {'ph': 6.4, 'nitrogeno': 44, 'fosforo': 29, 'potasio': 24},
  ///   ...
  /// ]
  ///
  /// Formato de salida:
  /// [6.5, 45, 30, 25, 6.4, 44, 29, 24, ...]
  List<double> _convertToFeatureArray(List<Map<String, dynamic>> records) {
    final features = <double>[];

    for (final record in records) {
      features.add((record['ph'] as num).toDouble());
      features.add((record['nitrogeno'] as num).toDouble());
      features.add((record['fosforo'] as num).toDouble());
      features.add((record['potasio'] as num).toDouble());
    }

    debugPrint('🔢 Array de features generado: ${features.length} valores');
    return features;
  }

  /// Genera datos sintéticos como FALLBACK
  ///
  /// Solo se usa si el API del sensor falla
  ///
  /// Rangos de valores generados:
  /// - pH: 6.0 - 6.7
  /// - Nitrógeno: 40 - 50 ppm
  /// - Fósforo: 25 - 35 ppm
  /// - Potasio: 20 - 30 ppm
  List<Map<String, dynamic>> _generateSyntheticData(int count) {
    final random = Random();
    final syntheticData = <Map<String, dynamic>>[];

    debugPrint('⚠️ ===== GENERANDO DATOS SINTÉTICOS =====');
    debugPrint('⚠️ Cantidad: $count registros');

    for (int i = 0; i < count; i++) {
      syntheticData.add({
        'ph': 6.0 + random.nextDouble() * 0.7,        // 6.0 - 6.7
        'nitrogeno': 40.0 + random.nextDouble() * 10, // 40 - 50
        'fosforo': 25.0 + random.nextDouble() * 10,   // 25 - 35
        'potasio': 20.0 + random.nextDouble() * 10,   // 20 - 30
      });
    }

    debugPrint('⚠️ Datos sintéticos generados exitosamente');
    return syntheticData;
  }
}