import 'package:dartz/dartz.dart';
import '../entities/alert.dart';

/// Contrato del repositorio de alertas
///
/// Define las operaciones que deben implementarse para manejar alertas
/// Retorna Either<String, T> para manejo de errores:
/// - Left: Error (mensaje de error)
/// - Right: Éxito (datos)
abstract class AlertRepository {
  /// Evalúa los datos de una parcela y genera alertas automáticamente
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela a evaluar
  /// - [temperatura]: Temperatura actual en °C
  /// - [humedad]: Humedad relativa en %
  ///
  /// Retorna:
  /// - Left: Mensaje de error si falla
  /// - Right: Lista de alertas creadas
  Future<Either<String, List<Alert>>> evaluateAndCreateAlerts({
    required String parcelaId,
    required double temperatura,
    required double humedad,
  });

  /// Crea una alerta manualmente
  ///
  /// Útil para alertas creadas por el usuario o el sistema
  ///
  /// Parámetros:
  /// - [alert]: Alerta a crear
  ///
  /// Retorna:
  /// - Left: Mensaje de error si falla
  /// - Right: Alerta creada con ID generado
  Future<Either<String, Alert>> createAlert(Alert alert);

  /// Obtiene las alertas activas de una parcela
  ///
  /// Filtra alertas no vistas y no expiradas
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  ///
  /// Retorna:
  /// - Left: Mensaje de error si falla
  /// - Right: Lista de alertas activas
  Future<Either<String, List<Alert>>> getActiveAlerts(String parcelaId);

  /// Obtiene el historial de alertas con filtros opcionales por fecha
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  /// - [startDate]: Fecha inicio del rango (opcional)
  /// - [endDate]: Fecha fin del rango (opcional)
  /// - [limit]: Cantidad máxima de alertas (default: 50)
  ///
  /// Retorna:
  /// - Left: Mensaje de error si falla
  /// - Right: Lista de alertas históricas
  Future<Either<String, List<Alert>>> getAlertsHistory({
    required String parcelaId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  });

  /// Obtiene las alertas del día de hoy
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  ///
  /// Retorna:
  /// - Left: Mensaje de error si falla
  /// - Right: Lista de alertas de hoy
  Future<Either<String, List<Alert>>> getTodayAlerts(String parcelaId);

  /// Obtiene las alertas de la última semana
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  ///
  /// Retorna:
  /// - Left: Mensaje de error si falla
  /// - Right: Lista de alertas de la última semana
  Future<Either<String, List<Alert>>> getLastWeekAlerts(String parcelaId);

  /// Obtiene las alertas del último mes
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  ///
  /// Retorna:
  /// - Left: Mensaje de error si falla
  /// - Right: Lista de alertas del último mes
  Future<Either<String, List<Alert>>> getLastMonthAlerts(String parcelaId);

  /// Obtiene alertas de un día específico
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  /// - [date]: Fecha específica
  ///
  /// Retorna:
  /// - Left: Mensaje de error si falla
  /// - Right: Lista de alertas del día especificado
  Future<Either<String, List<Alert>>> getAlertsByDate({
    required String parcelaId,
    required DateTime date,
  });

  /// Marca una alerta como vista/leída
  ///
  /// Parámetros:
  /// - [alertId]: ID de la alerta
  ///
  /// Retorna:
  /// - Left: Mensaje de error si falla
  /// - Right: Unit (void) si es exitoso
  Future<Either<String, Unit>> markAlertAsRead(String alertId);

  /// Marca todas las alertas de una parcela como vistas
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  ///
  /// Retorna:
  /// - Left: Mensaje de error si falla
  /// - Right: Unit (void) si es exitoso
  Future<Either<String, Unit>> markAllAlertsAsRead(String parcelaId);

  /// Obtiene el conteo de alertas sin leer
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  ///
  /// Retorna:
  /// - Left: Mensaje de error si falla
  /// - Right: Cantidad de alertas sin leer
  Future<Either<String, int>> getUnreadAlertsCount(String parcelaId);

  /// Elimina una alerta específica
  ///
  /// Parámetros:
  /// - [alertId]: ID de la alerta a eliminar
  ///
  /// Retorna:
  /// - Left: Mensaje de error si falla
  /// - Right: Unit (void) si es exitoso
  Future<Either<String, Unit>> deleteAlert(String alertId);

  /// Obtiene alertas filtradas por tipo
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela
  /// - [tipoAlerta]: Tipo de alerta (ph_bajo, temp_alta, etc.)
  ///
  /// Retorna:
  /// - Left: Mensaje de error si falla
  /// - Right: Lista de alertas del tipo especificado
  Future<Either<String, List<Alert>>> getAlertsByType({
    required String parcelaId,
    required String tipoAlerta,
  });
}