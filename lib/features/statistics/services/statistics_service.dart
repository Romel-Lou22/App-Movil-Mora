import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio para consultar estadísticas de alertas desde Supabase
class StatisticsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtener alertas agrupadas por semana y PARÁMETRO (no severidad)
  ///
  /// Retorna porcentajes sobre el total del mes:
  /// {
  ///   'semana_1': {'nitrogeno': 10.5, 'fosforo': 5.2, 'potasio': 8.1, 'ph': 3.5, 'humedad': 12.0, 'temperatura': 7.5},
  ///   'semana_2': {...},
  ///   ...
  /// }
  Future<Map<String, Map<String, double>>> getAlertsByWeekAndParameter({
    required String parcelaId,
    required int year,
    required int month,
  }) async {
    try {
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0, 23, 59, 59);

      // Consultar todas las alertas del mes
      final response = await _supabase
          .from('alertas_historial')
          .select('fecha_alerta, parametro')
          .eq('parcela_id', parcelaId)
          .gte('fecha_alerta', firstDay.toIso8601String())
          .lte('fecha_alerta', lastDay.toIso8601String())
          .order('fecha_alerta') as List<dynamic>;

      // Total de alertas del mes
      final totalAlertas = response.length;

      // Inicializar estructura
      final Map<String, Map<String, int>> weeklyCount = {
        'semana_1': {'nitrogeno': 0, 'fosforo': 0, 'potasio': 0, 'ph': 0, 'humedad': 0, 'temperatura': 0},
        'semana_2': {'nitrogeno': 0, 'fosforo': 0, 'potasio': 0, 'ph': 0, 'humedad': 0, 'temperatura': 0},
        'semana_3': {'nitrogeno': 0, 'fosforo': 0, 'potasio': 0, 'ph': 0, 'humedad': 0, 'temperatura': 0},
        'semana_4': {'nitrogeno': 0, 'fosforo': 0, 'potasio': 0, 'ph': 0, 'humedad': 0, 'temperatura': 0},
      };

      // Contar alertas por semana y parámetro
      for (var alert in response) {
        final fechaStr = alert['fecha_alerta'] as String;
        final fecha = DateTime.parse(fechaStr);
        final dayOfMonth = fecha.day;

        // Obtener parámetro y normalizarlo
        final parametroRaw = (alert['parametro'] as String).toLowerCase();
        final parametro = _normalizeParameter(parametroRaw);

        // Determinar semana
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
        if (weeklyCount[weekKey]!.containsKey(parametro)) {
          weeklyCount[weekKey]![parametro] = weeklyCount[weekKey]![parametro]! + 1;
        }
      }

      // Convertir a porcentajes
      final Map<String, Map<String, double>> weeklyPercentages = {};

      if (totalAlertas > 0) {
        weeklyCount.forEach((week, params) {
          weeklyPercentages[week] = {};
          params.forEach((param, count) {
            final percentage = (count / totalAlertas) * 100;
            weeklyPercentages[week]![param] = double.parse(percentage.toStringAsFixed(2));
          });
        });
      } else {
        // Si no hay alertas, todo es 0%
        weeklyPercentages['semana_1'] = {'nitrogeno': 0, 'fosforo': 0, 'potasio': 0, 'ph': 0, 'humedad': 0, 'temperatura': 0};
        weeklyPercentages['semana_2'] = {'nitrogeno': 0, 'fosforo': 0, 'potasio': 0, 'ph': 0, 'humedad': 0, 'temperatura': 0};
        weeklyPercentages['semana_3'] = {'nitrogeno': 0, 'fosforo': 0, 'potasio': 0, 'ph': 0, 'humedad': 0, 'temperatura': 0};
        weeklyPercentages['semana_4'] = {'nitrogeno': 0, 'fosforo': 0, 'potasio': 0, 'ph': 0, 'humedad': 0, 'temperatura': 0};
      }

      return weeklyPercentages;
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      rethrow;
    }
  }

  /// Normalizar nombre del parámetro desde la BD
  String _normalizeParameter(String parametro) {
    // Mapeo de nombres de BD a nombres cortos
    final Map<String, String> mapping = {
      'nitrógeno (n)': 'nitrogeno',
      'nitrogeno (n)': 'nitrogeno',
      'nitrógeno': 'nitrogeno',
      'nitrogeno': 'nitrogeno',
      'n': 'nitrogeno',

      'fósforo (p)': 'fosforo',
      'fosforo (p)': 'fosforo',
      'fósforo': 'fosforo',
      'fosforo': 'fosforo',
      'p': 'fosforo',

      'potasio (k)': 'potasio',
      'potasio': 'potasio',
      'k': 'potasio',

      'ph': 'ph',
      'ph (acidez)': 'ph',
      'acidez': 'ph',

      'humedad del suelo': 'humedad',
      'humedad': 'humedad',

      'temperatura': 'temperatura',
      'temperatura del aire': 'temperatura',
    };

    return mapping[parametro] ?? 'otro';
  }

  /// Obtener resumen del mes
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
          .select('fecha_alerta, severidad, tipo_alerta, parametro')
          .eq('parcela_id', parcelaId)
          .gte('fecha_alerta', firstDay.toIso8601String())
          .lte('fecha_alerta', lastDay.toIso8601String()) as List<dynamic>;

      int criticas = 0, altas = 0, medias = 0, bajas = 0;
      Map<String, int> tipoCount = {};
      Map<String, int> paramCount = {};
      Map<int, int> weekCount = {};

      for (var alert in response) {
        final severidad = (alert['severidad'] as String).toLowerCase();
        final tipo = alert['tipo_alerta'] as String;
        final parametro = alert['parametro'] as String;
        final fechaStr = alert['fecha_alerta'] as String;
        final fecha = DateTime.parse(fechaStr);
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

        tipoCount[tipo] = (tipoCount[tipo] ?? 0) + 1;
        paramCount[parametro] = (paramCount[parametro] ?? 0) + 1;
        weekCount[weekNumber] = (weekCount[weekNumber] ?? 0) + 1;
      }

      // Parámetro más afectado
      String parametroMasAfectado = 'ninguno';
      int maxParamCount = 0;
      paramCount.forEach((param, count) {
        if (count > maxParamCount) {
          maxParamCount = count;
          parametroMasAfectado = param;
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
        'parametro_mas_afectado': parametroMasAfectado,
        'semana_critica': semanaCritica,
      };
    } catch (e) {
      print('Error al obtener resumen: $e');
      rethrow;
    }
  }
}