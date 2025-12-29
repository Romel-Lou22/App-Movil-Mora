import 'package:dartz/dartz.dart';
import '../entities/alert.dart';
import '../repositories/alert_repository.dart';

/// Use Case para crear alertas manualmente
///
/// Responsabilidad única: Crear alertas personalizadas o manuales
/// (no generadas automáticamente por el Random Forest)
class CreateAlertUseCase {
  final AlertRepository repository;

  CreateAlertUseCase(this.repository);

  /// Crea una alerta manual
  ///
  /// Parámetros:
  /// - [alert]: Alerta a crear
  ///
  /// Casos de uso:
  /// - Alertas creadas por el usuario
  /// - Recordatorios personalizados
  /// - Alertas del sistema
  ///
  /// Retorna:
  /// - Left: Mensaje de error
  /// - Right: Alerta creada con ID generado
  Future<Either<String, Alert>> call(Alert alert) async {
    // Validaciones básicas
    final validation = _validateAlert(alert);
    if (validation != null) {
      return Left(validation);
    }

    // Crear alerta
    return await repository.createAlert(alert);
  }

  /// Valida que la alerta tenga los campos requeridos
  String? _validateAlert(Alert alert) {
    if (alert.parcelaId.isEmpty) {
      return 'ID de parcela requerido';
    }

    if (alert.tipoAlerta.isEmpty) {
      return 'Tipo de alerta requerido';
    }

    if (alert.parametro.isEmpty) {
      return 'Parámetro requerido';
    }

    if (alert.valorDetectado < 0) {
      return 'Valor detectado inválido';
    }

    if (alert.umbral.isEmpty) {
      return 'Umbral requerido';
    }

    if (alert.mensaje.isEmpty) {
      return 'Mensaje requerido';
    }

    // Validar que el tipo de alerta sea válido
    final validTypes = [
      'ph_bajo', 'ph_alto',
      'hum_baja', 'hum_alta',
      'temp_baja', 'temp_alta',
      'n_bajo', 'n_alto',
      'p_bajo', 'p_alto',
      'k_bajo', 'k_alto',
    ];

    if (!validTypes.contains(alert.tipoAlerta)) {
      return 'Tipo de alerta no válido';
    }

    return null;
  }

  /// Crea una alerta de recordatorio personalizada
  ///
  /// Helper method para crear alertas de recordatorio más fácilmente
  Future<Either<String, Alert>> createReminder({
    required String parcelaId,
    required String mensaje,
    required String recomendacion,
  }) async {
    final alert = Alert(
      id: '', // Se generará automáticamente
      parcelaId: parcelaId,
      tipoAlerta: 'recordatorio',
      severidad: 'baja',
      parametro: 'Sistema',
      valorDetectado: 0,
      umbral: 'N/A',
      mensaje: mensaje,
      recomendacion: recomendacion,
      vista: false,
      fechaAlerta: DateTime.now(),
      createdAt: DateTime.now(),
    );

    return await call(alert);
  }

  /// Elimina una alerta
  ///
  /// Parámetros:
  /// - [alertId]: ID de la alerta a eliminar
  ///
  /// Retorna:
  /// - Left: Mensaje de error
  /// - Right: Unit (éxito)
  Future<Either<String, Unit>> deleteAlert(String alertId) async {
    if (alertId.isEmpty) {
      return const Left('ID de alerta inválido');
    }

    return await repository.deleteAlert(alertId);
  }
}