import 'package:dartz/dartz.dart';
import '../entities/alert.dart';
import '../repositories/alert_repository.dart';

/// Use Case para obtener el historial de alertas (Opción B)
class GetAlertsHistoryUseCase {
  final AlertRepository repository;

  GetAlertsHistoryUseCase(this.repository);

  /// Historial completo (sin filtrar por vista)
  Future<Either<String, List<Alert>>> call({
    required String parcelaId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    if (parcelaId.isEmpty) return const Left('ID de parcela inválido');
    if (limit <= 0) return const Left('Límite debe ser mayor a 0');
    if (limit > 200) return const Left('Límite máximo es 200 alertas');

    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      return const Left('La fecha de inicio no puede ser posterior a la fecha de fin');
    }

    return repository.fetchAlerts(
      parcelaId: parcelaId,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }

  /// Alertas del día de hoy (incluye todo el día)
  Future<Either<String, List<Alert>>> fetchToday(String parcelaId) async {
    if (parcelaId.isEmpty) return const Left('ID de parcela inválido');

    final now = DateTime.now();
    final day = _dayStart(now);

    return repository.fetchAlerts(
      parcelaId: parcelaId,
      startDate: day,
      endDate: day, // ✅ end inclusivo (el datasource incluye el día completo)
      limit: 200,
    );
  }

  /// Últimos 7 días incluyendo hoy
  Future<Either<String, List<Alert>>> fetchLastWeek(String parcelaId) async {
    if (parcelaId.isEmpty) return const Left('ID de parcela inválido');

    final today = _dayStart(DateTime.now());
    final start = today.subtract(const Duration(days: 6)); // ✅ hoy + 6 días atrás

    return repository.fetchAlerts(
      parcelaId: parcelaId,
      startDate: start,
      endDate: today, // ✅ end inclusivo
      limit: 200,
    );
  }

  /// Últimos 30 días incluyendo hoy
  Future<Either<String, List<Alert>>> fetchLastMonth(String parcelaId) async {
    if (parcelaId.isEmpty) return const Left('ID de parcela inválido');

    final today = _dayStart(DateTime.now());
    final start = today.subtract(const Duration(days: 29)); // ✅ hoy + 29 días atrás

    return repository.fetchAlerts(
      parcelaId: parcelaId,
      startDate: start,
      endDate: today, // ✅ end inclusivo
      limit: 200,
    );
  }

  /// Alertas de un día específico (incluye todo el día)
  Future<Either<String, List<Alert>>> fetchByDate({
    required String parcelaId,
    required DateTime date,
  }) async {
    if (parcelaId.isEmpty) return const Left('ID de parcela inválido');

    final day = _dayStart(date);

    return repository.fetchAlerts(
      parcelaId: parcelaId,
      startDate: day,
      endDate: day, // ✅ end inclusivo
      limit: 200,
    );
  }

  /// Rango por fechas (INCLUYE el día endDate completo)
  Future<Either<String, List<Alert>>> fetchByDateRange({
    required String parcelaId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (parcelaId.isEmpty) return const Left('ID de parcela inválido');

    final start = _dayStart(startDate);
    final end = _dayStart(endDate); // ✅ end inclusivo

    if (start.isAfter(end)) {
      return const Left('La fecha de inicio no puede ser posterior a la fecha de fin');
    }

    return repository.fetchAlerts(
      parcelaId: parcelaId,
      startDate: start,
      endDate: end,
      limit: 200,
    );
  }


  /// Historial filtrado por tipo
  Future<Either<String, List<Alert>>> getByType({
    required String parcelaId,
    required AlertType tipoAlerta,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 200,
  }) async {
    if (parcelaId.isEmpty) return const Left('ID de parcela inválido');

    return repository.fetchAlerts(
      parcelaId: parcelaId,
      type: tipoAlerta,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }

  /// Agrupa por fecha (Hoy/Ayer/Fecha)
  Map<String, List<Alert>> groupByDate(List<Alert> alerts) {
    final now = DateTime.now();
    final today = _dayStart(now);
    final yesterday = today.subtract(const Duration(days: 1));

    final grouped = <String, List<Alert>>{};
    final months = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];

    for (final alert in alerts) {
      final local = alert.fechaAlerta.toLocal();
      final alertDay = _dayStart(local);

      final String key;
      if (alertDay == today) {
        key = 'Hoy';
      } else if (alertDay == yesterday) {
        key = 'Ayer';
      } else {
        key = '${alertDay.day} ${months[alertDay.month]} ${alertDay.year}';
      }

      grouped.putIfAbsent(key, () => <Alert>[]);
      grouped[key]!.add(alert);
    }

    return grouped;
  }

  /// Agrupa por tipo (enum) para estadísticas
  Map<AlertType, int> groupByType(List<Alert> alerts) {
    final grouped = <AlertType, int>{};
    for (final alert in alerts) {
      grouped[alert.tipoAlerta] = (grouped[alert.tipoAlerta] ?? 0) + 1;
    }
    return grouped;
  }

  /// Si necesitas keys string para UI/gráficos:
  Map<String, int> groupByTypeDbValue(List<Alert> alerts) {
    final grouped = <String, int>{};
    for (final alert in alerts) {
      final key = alert.tipoAlerta.dbValue;
      grouped[key] = (grouped[key] ?? 0) + 1;
    }
    return grouped;
  }

  /// Resumen por mes (Ej: "Ene 2026")
  Map<String, int> groupByMonth(List<Alert> alerts) {
    final grouped = <String, int>{};
    final months = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];

    for (final alert in alerts) {
      final local = alert.fechaAlerta.toLocal();
      final key = '${months[local.month]} ${local.year}';
      grouped[key] = (grouped[key] ?? 0) + 1;
    }

    return grouped;
  }

  DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);
}
