import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // ← AGREGAR ESTE IMPORT
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/soil_prediction_model.dart';
import '../../../../core/config/supabase_config.dart';

/// DataSource que maneja las operaciones con HuggingFace API
///
/// Responsabilidades:
/// - Obtener últimos 24 registros históricos de suelo desde Supabase
/// - Si no hay 24 registros, generar datos sintéticos
/// - Preparar array de 96 valores (24 timesteps × 4 features)
/// - Consumir HuggingFace API para predicción de nutrientes
/// - Convertir la respuesta del API a SoilPredictionModel
class HuggingFaceDataSource {
  final Dio _dio;
  final SupabaseClient _supabase;

  // Configuración de HuggingFace API
  static const String _baseUrl =
      'https://roca22-api-clima-prediccionv.hf.space';

  HuggingFaceDataSource({
    Dio? dio,
    SupabaseClient? supabase,
  })  : _dio = dio ?? Dio(),
        _supabase = supabase ?? SupabaseConfig.supabase;

  /// Predice los nutrientes del suelo para una parcela
  ///
  /// Pasos:
  /// 1. Obtiene últimos 24 registros históricos (o genera sintéticos)
  /// 2. Prepara array de 96 valores [pH1, N1, P1, K1, pH2, N2, P2, K2, ...]
  /// 3. Llama a HuggingFace API /predict/suelo
  /// 4. Convierte la respuesta a SoilPredictionModel
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  ///
  /// Retorna: SoilPredictionModel con predicción de nutrientes
  ///
  /// Lanza excepción si falla la llamada al API
  Future<SoilPredictionModel> predictSoilNutrients(String parcelaId) async {
    try {
      // 1. Preparar los 96 valores (24 timesteps × 4 features)
      final features = await _prepare24Timesteps(parcelaId);

      // 2. Logs detallados del payload
      debugPrint('📦 ===== DETALLES DE LA PETICIÓN =====');
      debugPrint('📦 URL: $_baseUrl/predict/suelo');
      debugPrint('📦 Total de features: ${features.length}');
      debugPrint('📦 Primeros 20 valores: ${features.take(20).toList()}');
      debugPrint('📦 Últimos 4 valores: ${features.skip(features.length - 4).toList()}');

      final payload = {'features': features};
      final payloadStr = payload.toString();
      debugPrint('📦 Payload (primeros 200 chars): ${payloadStr.substring(0, payloadStr.length > 200 ? 200 : payloadStr.length)}...');

      // 3. Llamar a HuggingFace API
      debugPrint('🚀 Enviando petición a HuggingFace...');

      final response = await _dio.post(
        '$_baseUrl/predict/suelo',
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
        // 4. Convertir respuesta a modelo
        debugPrint('✅ Datos recibidos: ${response.data}');
        return SoilPredictionModel.fromHuggingFaceResponse(
          response.data as Map<String, dynamic>,
        );
      } else if (response.statusCode == 503) {
        debugPrint('⚠️ Error 503: El servicio está temporalmente no disponible');
        debugPrint('💡 Esto puede pasar si el Space de HuggingFace está "despertando"');
        debugPrint('💡 Recomendación: Espera 30-60 segundos e intenta nuevamente');
        throw Exception(
          'El servicio de predicción está iniciándose. Por favor, intenta nuevamente en unos segundos.',
        );
      } else {
        debugPrint('❌ Error inesperado del API: ${response.statusCode}');
        debugPrint('❌ Respuesta: ${response.data}');
        throw Exception(
          'Error del API de HuggingFace: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('🔴 DioException capturado:');
      debugPrint('   Tipo: ${e.type}');
      debugPrint('   Mensaje: ${e.message}');
      debugPrint('   Response: ${e.response?.data}');

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
  /// Formato: [pH1, N1, P1, K1, pH2, N2, P2, K2, ..., pH24, N24, P24, K24]
  ///
  /// Estrategia:
  /// 1. Intenta obtener 24 registros históricos de Supabase
  /// 2. Si no hay suficientes, completa con datos sintéticos
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  ///
  /// Retorna: Lista de 96 valores double
  Future<List<double>> _prepare24Timesteps(String parcelaId) async {
    try {
      // Intentar obtener registros históricos reales
      final historicos = await _getHistoricalData(parcelaId);

      if (historicos.length >= 24) {
        // Tenemos suficientes datos históricos
        debugPrint('✅ Se encontraron ${historicos.length} registros históricos');
        return _convertToFeatureArray(historicos.take(24).toList());
      } else {
        // No hay suficientes datos, generar sintéticos
        debugPrint('⚠️ Solo hay ${historicos.length} registros históricos.');
        debugPrint('⚠️ Generando ${24 - historicos.length} registros sintéticos...');

        final synthetic = _generateSyntheticData(24 - historicos.length);
        final combined = [...historicos, ...synthetic];

        return _convertToFeatureArray(combined);
      }
    } catch (e) {
      // Si falla todo, usar solo datos sintéticos
      debugPrint('⚠️ No se pudieron obtener datos históricos: $e');
      debugPrint('⚠️ Usando 24 registros sintéticos completos...');

      final synthetic = _generateSyntheticData(24);
      return _convertToFeatureArray(synthetic);
    }
  }

  /// Obtiene registros históricos de suelo desde Supabase
  ///
  /// Filtra por:
  /// - parcela_id
  /// - Registros que tengan pH, N, P, K no nulos
  /// - Orden descendente por fecha (más recientes primero)
  /// - Límite de 24 registros
  Future<List<Map<String, dynamic>>> _getHistoricalData(
      String parcelaId,
      ) async {
    try {
      final response = await _supabase
          .from('datos_historicos')
          .select('ph, nitrogeno, fosforo, potasio')
          .eq('parcela_id', parcelaId)
          .not('ph', 'is', null)
          .not('nitrogeno', 'is', null)
          .not('fosforo', 'is', null)
          .not('potasio', 'is', null)
          .order('fecha_hora', ascending: false)
          .limit(24);

      return (response as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Error al obtener datos históricos: $e');
    }
  }

  /// Convierte lista de registros históricos a array de 96 valores
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

    return features;
  }

  /// Genera datos sintéticos con valores típicos para mora en Tisaleo
  ///
  /// Rangos de valores generados:
  /// - pH: 6.0 - 6.7
  /// - Nitrógeno: 40 - 50 ppm
  /// - Fósforo: 25 - 35 ppm
  /// - Potasio: 20 - 30 ppm
  ///
  /// Parámetros:
  /// - [count]: Cantidad de timesteps a generar
  ///
  /// Retorna: Lista de Maps con datos sintéticos
  List<Map<String, dynamic>> _generateSyntheticData(int count) {
    final random = Random();
    final syntheticData = <Map<String, dynamic>>[];

    for (int i = 0; i < count; i++) {
      syntheticData.add({
        'ph': 6.0 + random.nextDouble() * 0.7,        // 6.0 - 6.7
        'nitrogeno': 40.0 + random.nextDouble() * 10, // 40 - 50
        'fosforo': 25.0 + random.nextDouble() * 10,   // 25 - 35
        'potasio': 20.0 + random.nextDouble() * 10,   // 20 - 30
      });
    }

    return syntheticData;
  }
}