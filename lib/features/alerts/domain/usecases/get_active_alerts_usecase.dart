import 'package:dartz/dartz.dart';
import '../entities/alert.dart';
import '../repositories/alert_repository.dart';

/// Use Case para obtener las alertas activas de una parcela
///
/// Responsabilidad única: Obtener alertas que están activas (no vistas y no expiradas)
/// para mostrar en la UI
class GetActiveAlertsUseCase {
  final AlertRepository repository;

  GetActiveAlertsUseCase(this.repository);

  /// Ejecuta la obtención de alertas activas
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  ///
  /// Filtra:
  /// - Alertas no marcadas como vistas
  /// - Alertas no expiradas (según su severidad)
  ///
  /// Ordenadas por fecha (más recientes primero)
  ///
  /// Retorna:
  /// - Left: Mensaje de error
  /// - Right: Lista de alertas activas (puede estar vacía)
  Future<Either<String, List<Alert>>> call(String parcelaId) async {
    // Validación
    if (parcelaId.isEmpty) {
      return const Left('ID de parcela inválido');
    }

    // Obtener alertas activas
    final result = await repository.getActiveAlerts(parcelaId);

    // Ordenar por fecha (más reciente primero) y severidad
    return result.fold(
          (error) => Left(error),
          (alerts) {
        // Ordenar primero por vista (no vistas primero), luego por fecha
        final sortedAlerts = List<Alert>.from(alerts)
          ..sort((a, b) {
            // Primero: alertas no vistas
            if (!a.vista && b.vista) return -1;
            if (a.vista && !b.vista) return 1;

            // Luego: por fecha (más reciente primero)
            return b.fechaAlerta.compareTo(a.fechaAlerta);
          });

        return Right(sortedAlerts);
      },
    );
  }

  /// Obtiene solo el conteo de alertas activas sin leer
  ///
  /// Útil para mostrar badges o notificaciones
  Future<Either<String, int>> getCount(String parcelaId) async {
    if (parcelaId.isEmpty) {
      return const Left('ID de parcela inválido');
    }

    return await repository.getUnreadAlertsCount(parcelaId);
  }
}