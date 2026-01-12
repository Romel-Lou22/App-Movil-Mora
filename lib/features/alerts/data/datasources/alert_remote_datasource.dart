import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/alert_model.dart';
import '../../../../core/config/supabase_config.dart';

/// DataSource que maneja todas las operaciones relacionadas con alertas
///
/// Responsabilidades:
/// - Consumir el Random Forest API de Hugging Face
/// - Leer datos históricos de Supabase
/// - Guardar alertas en Supabase
/// - Consultar alertas activas e historial (con filtros por fecha)
/// - Marcar alertas como vistas
class AlertRemoteDataSource {
  final Dio _dio;
  final SupabaseClient _supabase;

  // Configuración del Random Forest API
  static const String _randomForestBaseUrl =
      'https://roca22-intelligent-alerts-rf.hf.space';

  AlertRemoteDataSource({
    Dio? dio,
    SupabaseClient? supabase,
  })  : _dio = dio ?? Dio(),
        _supabase = supabase ?? SupabaseConfig.supabase;

  /// Evalúa los datos de una parcela y genera alertas usando el Random Forest
  ///
  /// Pasos:
  /// 1. Obtiene los últimos datos de la parcela (pH, N, P, K, temp, humedad)
  /// 2. Envía los datos al modelo Random Forest
  /// 3. Procesa las alertas detectadas
  /// 4. Guarda las nuevas alertas en Supabase
  ///
  /// Retorna la lista de alertas creadas
  Future<List<AlertModel>> evaluateAndCreateAlerts({
    required String parcelaId,
    required double temperatura,
    required double humedad,
  }) async {
    try {
      // 1. Obtener los últimos datos de la parcela desde Supabase
      final datosHistoricos = await _getLatestDatosHistoricos(parcelaId);

      if (datosHistoricos == null) {
        throw Exception(
          'No se encontraron datos históricos para la parcela $parcelaId',
        );
      }

      // 2. Preparar los datos para el Random Forest
      final requestData = {
        'pH': datosHistoricos['ph'] ?? 6.0,
        'temperatura_C': temperatura,
        'humedad_suelo_pct': humedad,
        'N_ppm': datosHistoricos['nitrogeno'] ?? 0.0,
        'P_ppm': datosHistoricos['fosforo'] ?? 0.0,
        'K_ppm': datosHistoricos['potasio'] ?? 0.0,
      };

      // 3. Llamar al Random Forest
      final alertasDetectadas = await _callRandomForestAPI(requestData);

      // 4. Convertir las alertas detectadas a modelos
      final alertModels = <AlertModel>[];

      for (var alertaData in alertasDetectadas) {
        final alertModel = AlertModel.fromRandomForestResponse(
          parcelaId: parcelaId,
          tipo: alertaData['tipo'] as String,
          recomendacion: alertaData['recomendacion'] as String,
          valoresInput: {
            'pH': requestData['pH'] as double,
            'temperatura_C': requestData['temperatura_C'] as double,
            'humedad_suelo_%': requestData['humedad_suelo_pct'] as double,
            'N_ppm': requestData['N_ppm'] as double,
            'P_ppm': requestData['P_ppm'] as double,
            'K_ppm': requestData['K_ppm'] as double,
          },
        );
        alertModels.add(alertModel);
      }

      // 5. Guardar las alertas en Supabase (solo si hay alertas)
      if (alertModels.isNotEmpty) {
        await _saveAlertsToSupabase(alertModels);
      }

      return alertModels;
    } on DioException catch (e) {
      throw Exception('Error de red al evaluar alertas: ${e.message}');
    } catch (e) {
      throw Exception('Error al evaluar alertas: $e');
    }
  }

  /// Obtiene los últimos datos históricos de una parcela
  Future<Map<String, dynamic>?> _getLatestDatosHistoricos(
      String parcelaId,
      ) async {
    try {
      final response = await _supabase
          .from('datos_historicos')
          .select('ph, nitrogeno, fosforo, potasio, humedad')
          .eq('parcela_id', parcelaId)
          .order('fecha_hora', ascending: false)
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception(
        'Error al obtener datos históricos de Supabase: $e',
      );
    }
  }

  /// Llama al API de Random Forest en Hugging Face
  Future<List<Map<String, dynamic>>> _callRandomForestAPI(
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await _dio.post(
        '$_randomForestBaseUrl/predict',
        data: data,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final alertasDetectadas = responseData['alertas_detectadas'] as List;

        return alertasDetectadas
            .map((e) => e as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception(
          'Error del Random Forest API: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error al llamar al Random Forest API: $e');
    }
  }

  /// Guarda múltiples alertas en Supabase
  Future<void> _saveAlertsToSupabase(List<AlertModel> alerts) async {
    try {
      final alertsJson = alerts.map((a) => a.toJsonForInsert()).toList();

      await _supabase.from('alertas_historial').insert(alertsJson);
    } catch (e) {
      throw Exception('Error al guardar alertas en Supabase: $e');
    }
  }

  /// Crea una alerta manual en Supabase
  Future<AlertModel> createAlert(AlertModel alert) async {
    try {
      final response = await _supabase
          .from('alertas_historial')
          .insert(alert.toJsonForInsert())
          .select()
          .single();

      return AlertModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear alerta: $e');
    }
  }

  /// Obtiene las alertas activas de una parcela
  ///
  /// Filtra por:
  /// - Parcela específica
  /// - Alertas no vistas (vista = false)
  /// - Ordenadas por fecha (más recientes primero)
  Future<List<AlertModel>> getActiveAlerts(String parcelaId) async {
    try {
      final response = await _supabase
          .from('alertas_historial')
          .select()
          .eq('parcela_id', parcelaId)
          .eq('vista', false)
          .order('fecha_alerta', ascending: false);

      final alerts = (response as List)
          .map((json) => AlertModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Filtrar solo las alertas que siguen activas (no expiradas)
      return alerts.where((alert) => alert.isActive).toList();
    } catch (e) {
      throw Exception('Error al obtener alertas activas: $e');
    }
  }

  /// Obtiene el historial de alertas con filtros opcionales por fecha
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  /// - [startDate]: Fecha inicio (opcional)
  /// - [endDate]: Fecha fin (opcional)
  /// - [limit]: Cantidad máxima de alertas (default: 50)
  Future<List<AlertModel>> getAlertsHistory({
    required String parcelaId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      var query = _supabase
          .from('alertas_historial')
          .select()
          .eq('parcela_id', parcelaId);

      // Aplicar filtro de fecha inicio si existe
      if (startDate != null) {
        query = query.gte('fecha_alerta', startDate.toIso8601String());
      }

      // Aplicar filtro de fecha fin si existe
      if (endDate != null) {
        // Agregar 1 día para incluir todo el día final
        final endDateTime = endDate.add(const Duration(days: 1));
        query = query.lt('fecha_alerta', endDateTime.toIso8601String());
      }

      final response = await query
          .order('fecha_alerta', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => AlertModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener historial de alertas: $e');
    }
  }

  /// Obtiene las alertas del día de hoy
  Future<List<AlertModel>> getTodayAlerts(String parcelaId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return await getAlertsHistory(
      parcelaId: parcelaId,
      startDate: startOfDay,
      endDate: startOfDay,
      limit: 100,
    );
  }

  /// Obtiene las alertas de la última semana
  Future<List<AlertModel>> getLastWeekAlerts(String parcelaId) async {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));

    return await getAlertsHistory(
      parcelaId: parcelaId,
      startDate: oneWeekAgo,
      endDate: now,
      limit: 100,
    );
  }

  /// Obtiene las alertas del último mes
  Future<List<AlertModel>> getLastMonthAlerts(String parcelaId) async {
    final now = DateTime.now();
    final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);

    return await getAlertsHistory(
      parcelaId: parcelaId,
      startDate: oneMonthAgo,
      endDate: now,
      limit: 200,
    );
  }

  /// Obtiene alertas de un día específico
  Future<List<AlertModel>> getAlertsByDate({
    required String parcelaId,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);

    return await getAlertsHistory(
      parcelaId: parcelaId,
      startDate: startOfDay,
      endDate: startOfDay,
      limit: 100,
    );
  }

  /// Marca una alerta como vista
  Future<void> markAlertAsRead(String alertId) async {
    try {
      await _supabase
          .from('alertas_historial')
          .update({'vista': true})
          .eq('id', alertId);
    } catch (e) {
      throw Exception('Error al marcar alerta como leída: $e');
    }
  }

  /// Marca todas las alertas de una parcela como vistas
  Future<void> markAllAlertsAsRead(String parcelaId) async {
    try {
      await _supabase
          .from('alertas_historial')
          .update({'vista': true})
          .eq('parcela_id', parcelaId)
          .eq('vista', false);
    } catch (e) {
      throw Exception('Error al marcar todas las alertas como leídas: $e');
    }
  }

  /// Obtiene el conteo de alertas activas sin leer
  Future<int> getUnreadAlertsCount(String parcelaId) async {
    try {
      final response = await _supabase
          .from('alertas_historial')
          .select('id, fecha_alerta, severidad') // Solo los campos necesarios
          .eq('parcela_id', parcelaId)
          .eq('vista', false);

      if (response == null || response is! List) {
        return 0;
      }

      // Contar alertas activas manualmente sin convertir a modelo completo
      int count = 0;
      final now = DateTime.now();

      for (var item in response) {
        try {
          // Validar que tenga los campos mínimos
          if (item['fecha_alerta'] == null) continue;

          final fechaAlerta = DateTime.parse(item['fecha_alerta'] as String);
          final severidad = item['severidad'] as String?;

          // Verificar si la alerta está activa (no expirada)
          final difference = now.difference(fechaAlerta);

          bool isActive = false;
          if (severidad == null) {
            isActive = difference.inHours < 72; // 3 días por defecto
          } else {
            switch (severidad.toLowerCase()) {
              case 'critica':
                isActive = difference.inHours < 24;
                break;
              case 'alta':
                isActive = difference.inHours < 48;
                break;
              case 'media':
                isActive = difference.inHours < 72;
                break;
              case 'baja':
                isActive = difference.inDays < 7;
                break;
              default:
                isActive = difference.inHours < 72;
            }
          }

          if (isActive) count++;
        } catch (e) {
          // Si hay error parseando una alerta, continuar con la siguiente
          continue;
        }
      }

      return count;
    } catch (e) {
      throw Exception('Error al obtener conteo de alertas: $e');
    }
  }

  /// Elimina una alerta específica
  Future<void> deleteAlert(String alertId) async {
    try {
      await _supabase
          .from('alertas_historial')
          .delete()
          .eq('id', alertId);
    } catch (e) {
      throw Exception('Error al eliminar alerta: $e');
    }
  }

  /// Obtiene alertas por tipo específico
  Future<List<AlertModel>> getAlertsByType({
    required String parcelaId,
    required String tipoAlerta,
  }) async {
    try {
      final response = await _supabase
          .from('alertas_historial')
          .select()
          .eq('parcela_id', parcelaId)
          .eq('tipo_alerta', tipoAlerta)
          .order('fecha_alerta', ascending: false)
          .limit(20);

      return (response as List)
          .map((json) => AlertModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener alertas por tipo: $e');
    }
  }
}