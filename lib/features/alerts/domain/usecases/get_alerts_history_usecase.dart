import 'package:dartz/dartz.dart';
import '../entities/alert.dart';
import '../repositories/alert_repository.dart';

/// Use Case para obtener el historial completo de alertas
///
/// Responsabilidad única: Obtener el historial de alertas con filtros por fecha
class GetAlertsHistoryUseCase {
  final AlertRepository repository;

  GetAlertsHistoryUseCase(this.repository);

  /// Ejecuta la obtención del historial de alertas con filtros opcionales
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  /// - [startDate]: Fecha inicio del rango (opcional)
  /// - [endDate]: Fecha fin del rango (opcional)
  /// - [limit]: Cantidad máxima de alertas (default: 50)
  ///
  /// Retorna todas las alertas ordenadas por fecha (más recientes primero)
  ///
  /// Retorna:
  /// - Left: Mensaje de error
  /// - Right: Lista completa de alertas históricas
  Future<Either<String, List<Alert>>> call({
    required String parcelaId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    // Validaciones
    if (parcelaId.isEmpty) {
      return const Left('ID de parcela inválido');
    }

    if (limit <= 0) {
      return const Left('Límite debe ser mayor a 0');
    }

    if (limit > 200) {
      return const Left('Límite máximo es 200 alertas');
    }

    // Validar que startDate no sea después de endDate
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      return const Left('La fecha de inicio no puede ser posterior a la fecha de fin');
    }

    // Obtener historial
    return await repository.getAlertsHistory(
      parcelaId: parcelaId,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }

  /// Obtiene las alertas del día de hoy
  ///
  /// Atajo rápido para ver las alertas de hoy
  Future<Either<String, List<Alert>>> fetchToday(String parcelaId) async {
    if (parcelaId.isEmpty) {
      return const Left('ID de parcela inválido');
    }

    return await repository.getTodayAlerts(parcelaId);
  }

  /// Obtiene las alertas de la última semana
  ///
  /// Atajo rápido para ver alertas de los últimos 7 días
  Future<Either<String, List<Alert>>> fetchLastWeek(String parcelaId) async {
    if (parcelaId.isEmpty) {
      return const Left('ID de parcela inválido');
    }

    return await repository.getLastWeekAlerts(parcelaId);
  }

  /// Obtiene las alertas del último mes
  ///
  /// Atajo rápido para ver alertas de los últimos 30 días
  Future<Either<String, List<Alert>>> fetchLastMonth(String parcelaId) async {
    if (parcelaId.isEmpty) {
      return const Left('ID de parcela inválido');
    }

    return await repository.getLastMonthAlerts(parcelaId);
  }

  /// Obtiene alertas de un día específico
  ///
  /// Útil cuando el usuario selecciona una fecha del calendario
  Future<Either<String, List<Alert>>> fetchByDate({
    required String parcelaId,
    required DateTime date,
  }) async {
    if (parcelaId.isEmpty) {
      return const Left('ID de parcela inválido');
    }

    return await repository.getAlertsByDate(
      parcelaId: parcelaId,
      date: date,
    );
  }

  /// Obtiene alertas por rango de fechas personalizado
  ///
  /// Permite al usuario seleccionar desde qué fecha hasta qué fecha
  Future<Either<String, List<Alert>>> fetchByDateRange({
    required String parcelaId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (parcelaId.isEmpty) {
      return const Left('ID de parcela inválido');
    }

    if (startDate.isAfter(endDate)) {
      return const Left('La fecha de inicio no puede ser posterior a la fecha de fin');
    }

    return await repository.getAlertsHistory(
      parcelaId: parcelaId,
      startDate: startDate,
      endDate: endDate,
      limit: 200, // Más límite para rangos personalizados
    );
  }

  /// Obtiene el historial filtrado por tipo de alerta
  ///
  /// Útil para ver solo alertas de pH, temperatura, etc.
  Future<Either<String, List<Alert>>> getByType({
    required String parcelaId,
    required String tipoAlerta,
  }) async {
    if (parcelaId.isEmpty) {
      return const Left('ID de parcela inválido');
    }

    if (tipoAlerta.isEmpty) {
      return const Left('Tipo de alerta inválido');
    }

    return await repository.getAlertsByType(
      parcelaId: parcelaId,
      tipoAlerta: tipoAlerta,
    );
  }

  /// Agrupa las alertas por fecha para mostrar en secciones
  ///
  /// Retorna un Map<String, List<Alert>> donde la key es la fecha
  /// Ejemplo: {"Hoy": [...], "Ayer": [...], "28 Dic 2024": [...]}
  Map<String, List<Alert>> groupByDate(List<Alert> alerts) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final grouped = <String, List<Alert>>{};

    for (var alert in alerts) {
      final alertDate = DateTime(
        alert.fechaAlerta.year,
        alert.fechaAlerta.month,
        alert.fechaAlerta.day,
      );

      String dateKey;
      if (alertDate == today) {
        dateKey = 'Hoy';
      } else if (alertDate == yesterday) {
        dateKey = 'Ayer';
      } else {
        // Formato: "28 Dic 2024"
        final months = [
          '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
          'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
        ];
        dateKey = '${alertDate.day} ${months[alertDate.month]} ${alertDate.year}';
      }

      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(alert);
    }

    return grouped;
  }

  /// Agrupa las alertas por tipo para estadísticas
  ///
  /// Retorna un Map<String, int> con el conteo de cada tipo
  /// Ejemplo: {"ph_bajo": 5, "temp_alta": 3, ...}
  Map<String, int> groupByType(List<Alert> alerts) {
    final grouped = <String, int>{};

    for (var alert in alerts) {
      grouped[alert.tipoAlerta] = (grouped[alert.tipoAlerta] ?? 0) + 1;
    }

    return grouped;
  }

  /// Obtiene un resumen de alertas por mes
  ///
  /// Retorna Map<String, int> con formato "Dic 2024": cantidad
  Map<String, int> groupByMonth(List<Alert> alerts) {
    final grouped = <String, int>{};
    final months = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];

    for (var alert in alerts) {
      final key = '${months[alert.fechaAlerta.month]} ${alert.fechaAlerta.year}';
      grouped[key] = (grouped[key] ?? 0) + 1;
    }

    return grouped;
  }
}