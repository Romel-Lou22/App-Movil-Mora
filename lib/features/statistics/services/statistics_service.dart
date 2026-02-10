import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio para consultar estadísticas de alertas desde Supabase
class StatisticsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtener alertas agrupadas por semana y severidad
  ///
  /// Retorna un Map con la estructura:
  /// {
  ///   'semana_1': {'critica': 2, 'alta': 1, 'media': 0, 'baja': 1},
  ///   'semana_2': {'critica': 5, 'alta': 2, 'media': 1, 'baja': 0},
  ///   ...
  /// }
  Future<Map<String, Map<String, int>>> getAlertsByWeekAndSeverity({
    required String parcelaId,
    required int year,
    required int month,
  }) async {
    try {
      // Calcular primer y último día del mes
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0, 23, 59, 59);

      // Consultar alertas del mes
      final response = await _supabase
          .from('alertas_historial')
          .select('fecha_alerta, severidad')
          .eq('parcela_id', parcelaId)
          .gte('fecha_alerta', firstDay.toIso8601String())
          .lte('fecha_alerta', lastDay.toIso8601String())
          .order('fecha_alerta');

      // Agrupar por semana
      final Map<String, Map<String, int>> weeklyData = {
        'semana_1': {'critica': 0, 'alta': 0, 'media': 0, 'baja': 0},
        'semana_2': {'critica': 0, 'alta': 0, 'media': 0, 'baja': 0},
        'semana_3': {'critica': 0, 'alta': 0, 'media': 0, 'baja': 0},
        'semana_4': {'critica': 0, 'alta': 0, 'media': 0, 'baja': 0},
      };

      for (var alert in response) {
        final fechaAlerta =
        DateTime.parse(alert['fecha_alerta'] as String);
        final dayOfMonth = fechaAlerta.day;
        final severidad = alert['severidad'].toString().toLowerCase();

        // Determinar semana (1-7 = sem1, 8-14 = sem2, etc.)
        String weekKey;
        if (dayOfMonth <= 7) {
          weekKey = 'semana_1';
        } else if (dayOfMonth <= 14) {
          weekKey = 'semana_2';
        } else if (dayOfMonth <= 21) {
          weekKey = 'semana_3';
        } else {
          weekKey = 'semana_4';
        }

        // Incrementar contador
        if (weeklyData[weekKey]!.containsKey(severidad)) {
          weeklyData[weekKey]![severidad] = weeklyData[weekKey]![severidad]! + 1;
        }
      }

      return weeklyData;
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      rethrow;
    }
  }

  /// Obtener resumen del mes (totales)
  ///
  /// Retorna:
  /// {
  ///   'total': 29,
  ///   'criticas': 12,
  ///   'altas': 8,
  ///   'medias': 6,
  ///   'bajas': 3,
  ///   'tipo_mas_frecuente': 'helada',
  ///   'semana_critica': 2
  /// }
  Future<Map<String, dynamic>> getMonthSummary({
    required String parcelaId,
    required int year,
    required int month,
  }) async {
    try {
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0, 23, 59, 59);

      final response = await _supabase
          .from('alertas_historial')
          .select('fecha_alerta, severidad, tipo_alerta')
          .eq('parcela_id', parcelaId)
          .gte('fecha_alerta', firstDay.toIso8601String())
          .lte('fecha_alerta', lastDay.toIso8601String());

      // Contar por severidad
      int criticas = 0, altas = 0, medias = 0, bajas = 0;
      Map<String, int> tipoCount = {};
      Map<int, int> weekCount = {};

      for (var alert in response) {
        final severidad = alert['severidad'].toString().toLowerCase();
        final tipo = alert['tipo_alerta'].toString();
        final fecha =
        DateTime.parse(alert['fecha_alerta'] as String);

        final weekNumber = ((fecha.day - 1) ~/ 7) + 1;

        // Contar severidad
        switch (severidad) {
          case 'critica':
            criticas++;
            break;
          case 'alta':
            altas++;
            break;
          case 'media':
            medias++;
            break;
          case 'baja':
            bajas++;
            break;
        }

        // Contar tipo
        tipoCount[tipo] = (tipoCount[tipo] ?? 0) + 1;

        // Contar por semana
        weekCount[weekNumber] = (weekCount[weekNumber] ?? 0) + 1;
      }

      // Tipo más frecuente
      String tipoMasFrecuente = 'ninguno';
      int maxCount = 0;
      tipoCount.forEach((tipo, count) {
        if (count > maxCount) {
          maxCount = count;
          tipoMasFrecuente = tipo;
        }
      });

      // Semana más crítica
      int semanaCritica = 1;
      int maxWeekCount = 0;
      weekCount.forEach((week, count) {
        if (count > maxWeekCount) {
          maxWeekCount = count;
          semanaCritica = week;
        }
      });

      return {
        'total': response.length,
        'criticas': criticas,
        'altas': altas,
        'medias': medias,
        'bajas': bajas,
        'tipo_mas_frecuente': tipoMasFrecuente,
        'semana_critica': semanaCritica,
      };
    } catch (e) {
      print('Error al obtener resumen: $e');
      rethrow;
    }
  }
}