import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/alert_model.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/alert.dart';

/// DataSource: Solo operaciones Supabase para alertas
class AlertRemoteDataSource {
  final SupabaseClient _supabase;

  AlertRemoteDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseConfig.supabase;

  /// Fetch genérico
  /// - onlyUnread: vista = false
  /// - tipo: filtra por tipo_alerta
  /// - startDate/endDate: rango por created_at (fecha de creación real)
  Future<List<AlertModel>> fetchAlerts({
    required String parcelaId,
    bool onlyUnread = false,
    AlertType? tipo,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      debugPrint('🔍 ═══════════════════════════════════');
      debugPrint('🔍 FETCH ALERTS - Parámetros:');
      debugPrint('   📍 Parcela: $parcelaId');
      debugPrint('   👁️ Solo no vistas: $onlyUnread');
      debugPrint('   📊 Tipo: ${tipo?.dbEnumValue ?? "todos"}');
      debugPrint('   📅 Start: $startDate');
      debugPrint('   📅 End: $endDate');
      debugPrint('   🔢 Limit: $limit');

      var query = _supabase
          .from('alertas_historial')
          .select()
          .eq('parcela_id', parcelaId);

      // ✅ CRÍTICO: Filtrar por vista
      if (onlyUnread) {
        query = query.eq('vista', false);
        debugPrint('   🔒 Filtro aplicado: vista = false');
      }

      // Filtro por tipo
      if (tipo != null) {
        query = query.eq('tipo_alerta', tipo.dbEnumValue);
        debugPrint('   🔒 Filtro aplicado: tipo = ${tipo.dbEnumValue}');
      }

      // ✅ IMPORTANTE: Usar created_at (fecha real de creación) en lugar de fecha_alerta
      if (startDate != null) {
        final startUtc = startDate.toUtc().toIso8601String();
        query = query.gte('created_at', startUtc);
        debugPrint('   🔒 Filtro aplicado: created_at >= $startUtc');
      }

      if (endDate != null) {
        // endDate inclusivo (cubre todo el día final)
        final endExclusive = DateTime(endDate.year, endDate.month, endDate.day)
            .add(const Duration(days: 1))
            .toUtc()
            .toIso8601String();
        query = query.lt('created_at', endExclusive);
        debugPrint('   🔒 Filtro aplicado: created_at < $endExclusive');
      }

      // ✅ Ordenar por created_at (más recientes primero)
      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      final alerts = (response as List)
          .map((json) => AlertModel.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('   ✅ Alertas obtenidas: ${alerts.length}');

      if (alerts.isNotEmpty && alerts.length <= 5) {
        debugPrint('   📋 Primeras alertas:');
        for (var i = 0; i < alerts.length; i++) {
          debugPrint('      ${i + 1}. ${alerts[i].tipoAlerta.dbEnumValue} - Vista: ${alerts[i].vista} - Fecha: ${alerts[i].createdAt}');
        }
      }

      debugPrint('🔍 ═══════════════════════════════════');

      return alerts;
    } catch (e) {
      debugPrint('❌ Error al consultar alertas: $e');
      throw Exception('Error al consultar alertas: $e');
    }
  }

  /// Inserta muchas alertas (batch) y retorna lo insertado
  Future<List<AlertModel>> insertAlerts(List<AlertModel> alerts) async {
    try {
      if (alerts.isEmpty) return [];

      debugPrint('💾 ═══════════════════════════════════');
      debugPrint('💾 INSERTANDO ${alerts.length} ALERTAS');

      final payload = alerts.map((a) => a.toJsonForInsert()).toList();

      // Debug: mostrar el primer payload
      if (payload.isNotEmpty) {
        debugPrint('   📦 Ejemplo de payload:');
        debugPrint('      ${payload.first}');
      }

      final response = await _supabase
          .from('alertas_historial')
          .insert(payload)
          .select();

      final inserted = (response as List)
          .map((json) => AlertModel.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('   ✅ Alertas insertadas: ${inserted.length}');
      debugPrint('💾 ═══════════════════════════════════');

      return inserted;
    } catch (e) {
      debugPrint('❌ Error al insertar alertas: $e');
      throw Exception('Error al insertar alertas: $e');
    }
  }

  /// Marca una alerta como vista
  Future<void> markAlertAsRead(String alertId) async {
    try {
      debugPrint('✔️ Marcando alerta como vista: $alertId');

      await _supabase
          .from('alertas_historial')
          .update({'vista': true})
          .eq('id', alertId);

      debugPrint('   ✅ Alerta marcada como vista');
    } catch (e) {
      debugPrint('❌ Error al marcar alerta como leída: $e');
      throw Exception('Error al marcar alerta como leída: $e');
    }
  }

  /// Marca todas las alertas como vistas para una parcela
  Future<void> markAllAlertsAsRead(String parcelaId) async {
    try {
      debugPrint('✔️ Marcando TODAS las alertas como vistas para parcela: $parcelaId');

      await _supabase
          .from('alertas_historial')
          .update({'vista': true})
          .eq('parcela_id', parcelaId)
          .eq('vista', false); // Solo las que aún no están vistas

      debugPrint('   ✅ Todas las alertas marcadas como vistas');
    } catch (e) {
      debugPrint('❌ Error al marcar todas como leídas: $e');
      throw Exception('Error al marcar todas como leídas: $e');
    }
  }

  /// Conteo de alertas sin leer
  /// ✅ SIMPLIFICADO: Solo cuenta las que tienen vista = false
  Future<int> getUnreadAlertsCount(String parcelaId) async {
    try {
      debugPrint('🔢 Obteniendo conteo de alertas no vistas para: $parcelaId');

      final response = await _supabase
          .from('alertas_historial')
          .select()
          .eq('parcela_id', parcelaId)
          .eq('vista', false);

      final count = (response as List).length;

      debugPrint('   ✅ Alertas no vistas: $count');

      return count;
    } catch (e) {
      debugPrint('❌ Error al obtener conteo de alertas: $e');
      throw Exception('Error al obtener conteo de alertas: $e');
    }
  }

  /// (Opcional) Eliminar alerta (si lo usas luego)
  Future<void> deleteAlert(String alertId) async {
    try {
      debugPrint('🗑️ Eliminando alerta: $alertId');

      await _supabase.from('alertas_historial').delete().eq('id', alertId);

      debugPrint('   ✅ Alerta eliminada');
    } catch (e) {
      debugPrint('❌ Error al eliminar alerta: $e');
      throw Exception('Error al eliminar alerta: $e');
    }
  }

  // ==== Wrappers compatibles (ACTUALIZADOS) ====

  /// Obtiene alertas activas (no vistas)
  Future<List<AlertModel>> getActiveAlerts(String parcelaId) async {
    return fetchAlerts(
      parcelaId: parcelaId,
      onlyUnread: true, // ✅ Solo no vistas
      limit: 200,
    );
  }

  /// Obtiene historial completo (vistas y no vistas)
  Future<List<AlertModel>> getAlertsHistory({
    required String parcelaId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) {
    return fetchAlerts(
      parcelaId: parcelaId,
      onlyUnread: false, // ✅ Todas (vistas y no vistas)
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
      endDate: now,
      limit: 100,
    );
  }

  Future<List<AlertModel>> getLastWeekAlerts(String parcelaId) {
    final now = DateTime.now();
    return getAlertsHistory(
      parcelaId: parcelaId,
      startDate: now.subtract(const Duration(days: 6)),
      endDate: now,
      limit: 100,
    );
  }

  Future<List<AlertModel>> getLastMonthAlerts(String parcelaId) {
    final now = DateTime.now();
    return getAlertsHistory(
      parcelaId: parcelaId,
      startDate: now.subtract(const Duration(days: 29)),
      endDate: now,
      limit: 200,
    );
  }

  Future<List<AlertModel>> getAlertsByDate({
    required String parcelaId,
    required DateTime date,
  }) {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return getAlertsHistory(
      parcelaId: parcelaId,
      startDate: start,
      endDate: end,
      limit: 100,
    );
  }

  Future<List<AlertModel>> getAlertsByType({
    required String parcelaId,
    required String tipoAlerta,
  }) async {
    try {
      debugPrint('🔍 Obteniendo alertas por tipo: $tipoAlerta');

      final response = await _supabase
          .from('alertas_historial')
          .select()
          .eq('parcela_id', parcelaId)
          .eq('tipo_alerta', tipoAlerta)
          .order('created_at', ascending: false) // ✅ Usar created_at
          .limit(50);

      final alerts = (response as List)
          .map((json) => AlertModel.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('   ✅ Alertas encontradas: ${alerts.length}');

      return alerts;
    } catch (e) {
      debugPrint('❌ Error al obtener alertas por tipo: $e');
      throw Exception('Error al obtener alertas por tipo: $e');
    }
  }
}