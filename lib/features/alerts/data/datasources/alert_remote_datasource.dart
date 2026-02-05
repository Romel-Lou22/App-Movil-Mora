import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/alert_model.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/alert.dart';

/// DataSource: Solo operaciones Supabase para alertas
class AlertRemoteDataSource {
  final SupabaseClient _supabase;

  AlertRemoteDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseConfig.supabase;

  /// Fetch genérico (Opción B)
  /// - onlyUnread: vista = false
  /// - tipo: filtra por tipo_alerta
  /// - startDate/endDate: rango por fecha_alerta (endDate inclusivo por día)
  Future<List<AlertModel>> fetchAlerts({
    required String parcelaId,
    bool onlyUnread = false,
    AlertType? tipo,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      var query = _supabase
          .from('alertas_historial')
          .select()
          .eq('parcela_id', parcelaId);

      if (onlyUnread) {
        query = query.eq('vista', false);
      }

      if (tipo != null) {
        query = query.eq('tipo_alerta', tipo.dbEnumValue);
      }

      if (startDate != null) {
        query = query.gte('fecha_alerta', startDate.toIso8601String());
      }

      if (endDate != null) {
        // endDate inclusivo (cubre todo el día final)
        final endExclusive = DateTime(endDate.year, endDate.month, endDate.day)
            .add(const Duration(days: 1));
        query = query.lt('fecha_alerta', endExclusive.toIso8601String());
      }

      final response = await query
          .order('fecha_alerta', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => AlertModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al consultar alertas: $e');
    }
  }

  /// Inserta muchas alertas (batch) y retorna lo insertado
  Future<List<AlertModel>> insertAlerts(List<AlertModel> alerts) async {
    try {
      if (alerts.isEmpty) return [];

      final payload = alerts.map((a) => a.toJsonForInsert()).toList();

      final response = await _supabase
          .from('alertas_historial')
          .insert(payload)
          .select();

      return (response as List)
          .map((json) => AlertModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al insertar alertas: $e');
    }
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

  /// Marca todas las alertas como vistas para una parcela
  Future<void> markAllAlertsAsRead(String parcelaId) async {
    try {
      await _supabase
          .from('alertas_historial')
          .update({'vista': true})
          .eq('parcela_id', parcelaId)
          .eq('vista', false);
    } catch (e) {
      throw Exception('Error al marcar todas como leídas: $e');
    }
  }

  /// Conteo de alertas sin leer (y activas según expiración local)
  Future<int> getUnreadAlertsCount(String parcelaId) async {
    try {
      final response = await _supabase
          .from('alertas_historial')
          .select('fecha_alerta, severidad, vista')
          .eq('parcela_id', parcelaId)
          .eq('vista', false);

      if (response is! List) return 0;

      int count = 0;
      final now = DateTime.now();

      for (final item in response) {
        final fechaRaw = item['fecha_alerta'] as String?;
        if (fechaRaw == null) continue;

        final fecha = DateTime.parse(fechaRaw);
        final diff = now.difference(fecha);

        final sevStr = item['severidad'] as String?;
        bool isActive;

        if (sevStr == null) {
          isActive = diff.inHours < 72;
        } else {
          switch (sevStr.toLowerCase()) {
            case 'critica':
              isActive = diff.inHours < 24;
              break;
            case 'alta':
              isActive = diff.inHours < 48;
              break;
            case 'media':
              isActive = diff.inHours < 72;
              break;
            case 'baja':
              isActive = diff.inDays < 7;
              break;
            default:
              isActive = diff.inHours < 72;
          }
        }

        if (isActive) count++;
      }

      return count;
    } catch (e) {
      throw Exception('Error al obtener conteo de alertas: $e');
    }
  }

  /// (Opcional) Eliminar alerta (si lo usas luego)
  Future<void> deleteAlert(String alertId) async {
    try {
      await _supabase.from('alertas_historial').delete().eq('id', alertId);
    } catch (e) {
      throw Exception('Error al eliminar alerta: $e');
    }
  }

  // ==== Wrappers compatibles con tu código actual (si aún los usas) ====

  Future<List<AlertModel>> getActiveAlerts(String parcelaId) async {
    final alerts = await fetchAlerts(
      parcelaId: parcelaId,
      onlyUnread: true,
      limit: 200,
    );
    return alerts.where((a) => a.isActive).toList();
  }

  Future<List<AlertModel>> getAlertsHistory({
    required String parcelaId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) {
    return fetchAlerts(
      parcelaId: parcelaId,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }

  Future<List<AlertModel>> getTodayAlerts(String parcelaId) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return getAlertsHistory(
      parcelaId: parcelaId,
      startDate: start,
      endDate: start,
      limit: 100,
    );
  }

  Future<List<AlertModel>> getLastWeekAlerts(String parcelaId) {
    final now = DateTime.now();
    return getAlertsHistory(
      parcelaId: parcelaId,
      startDate: now.subtract(const Duration(days: 7)),
      endDate: now,
      limit: 100,
    );
  }

  Future<List<AlertModel>> getLastMonthAlerts(String parcelaId) {
    final now = DateTime.now();
    final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
    return getAlertsHistory(
      parcelaId: parcelaId,
      startDate: oneMonthAgo,
      endDate: now,
      limit: 200,
    );
  }

  Future<List<AlertModel>> getAlertsByDate({
    required String parcelaId,
    required DateTime date,
  }) {
    final start = DateTime(date.year, date.month, date.day);
    return getAlertsHistory(
      parcelaId: parcelaId,
      startDate: start,
      endDate: start,
      limit: 100,
    );
  }

  Future<List<AlertModel>> getAlertsByType({
    required String parcelaId,
    required String tipoAlerta,
  }) async {
    // Si todavía te llega como String, lo soportamos aquí.
    // Idealmente esto debería ser AlertType y usar tipo.dbValue.
    try {
      final response = await _supabase
          .from('alertas_historial')
          .select()
          .eq('parcela_id', parcelaId)
          .eq('tipo_alerta', tipoAlerta)
          .order('fecha_alerta', ascending: false)
          .limit(50);

      return (response as List)
          .map((json) => AlertModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener alertas por tipo: $e');
    }
  }
}
