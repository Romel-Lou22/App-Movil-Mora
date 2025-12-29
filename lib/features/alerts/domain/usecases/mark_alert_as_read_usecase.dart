import 'package:dartz/dartz.dart';
import '../repositories/alert_repository.dart';

/// Use Case para marcar alertas como leídas/vistas
///
/// Responsabilidad única: Actualizar el estado de vista de las alertas
class MarkAlertAsReadUseCase {
  final AlertRepository repository;

  MarkAlertAsReadUseCase(this.repository);

  /// Marca una alerta individual como leída
  ///
  /// Parámetros:
  /// - [alertId]: ID de la alerta a marcar
  ///
  /// Retorna:
  /// - Left: Mensaje de error
  /// - Right: Unit (éxito)
  Future<Either<String, Unit>> call(String alertId) async {
    // Validación
    if (alertId.isEmpty) {
      return const Left('ID de alerta inválido');
    }

    // Marcar como leída
    return await repository.markAlertAsRead(alertId);
  }

  /// Marca todas las alertas de una parcela como leídas
  ///
  /// Útil para el botón "Marcar todas como leídas"
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  ///
  /// Retorna:
  /// - Left: Mensaje de error
  /// - Right: Unit (éxito)
  Future<Either<String, Unit>> markAll(String parcelaId) async {
    // Validación
    if (parcelaId.isEmpty) {
      return const Left('ID de parcela inválido');
    }

    // Marcar todas como leídas
    return await repository.markAllAlertsAsRead(parcelaId);
  }

  /// Marca múltiples alertas como leídas
  ///
  /// Útil para selección múltiple en la UI
  ///
  /// Parámetros:
  /// - [alertIds]: Lista de IDs de alertas a marcar
  ///
  /// Retorna:
  /// - Left: Mensaje de error
  /// - Right: Unit (éxito)
  Future<Either<String, Unit>> markMultiple(List<String> alertIds) async {
    // Validación
    if (alertIds.isEmpty) {
      return const Left('No hay alertas para marcar');
    }

    // Marcar cada una (podría optimizarse con batch update)
    for (var alertId in alertIds) {
      final result = await repository.markAlertAsRead(alertId);

      // Si alguna falla, retornar el error
      if (result.isLeft()) {
        return result;
      }
    }

    return const Right(unit);
  }
}