import 'package:dartz/dartz.dart';
import '../entities/alert.dart';
import '../repositories/alert_repository.dart';

/// Use Case para evaluar umbrales y generar alertas automáticamente
///
/// Responsabilidad única: Evaluar los datos de una parcela y crear alertas
/// basadas en los umbrales definidos por el modelo Random Forest
class EvaluateThresholdsUseCase {
  final AlertRepository repository;

  EvaluateThresholdsUseCase(this.repository);

  /// Ejecuta la evaluación de umbrales
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela a evaluar
  /// - [temperatura]: Temperatura actual en °C (desde OpenWeather)
  /// - [humedad]: Humedad relativa en % (desde OpenWeather)
  ///
  /// Proceso:
  /// 1. Obtiene los últimos datos de la parcela (pH, N, P, K)
  /// 2. Combina con temperatura y humedad
  /// 3. Envía al Random Forest
  /// 4. Recibe alertas detectadas
  /// 5. Guarda en base de datos
  ///
  /// Retorna:
  /// - Left: Mensaje de error
  /// - Right: Lista de alertas generadas (puede estar vacía si no hay alertas)
  Future<Either<String, List<Alert>>> call({
    required String parcelaId,
    required double temperatura,
    required double humedad,
  }) async {
    // Validaciones básicas
    if (parcelaId.isEmpty) {
      return const Left('ID de parcela inválido');
    }

    if (temperatura < -50 || temperatura > 60) {
      return const Left('Temperatura fuera de rango válido');
    }

    if (humedad < 0 || humedad > 100) {
      return const Left('Humedad fuera de rango válido (0-100%)');
    }

    // Ejecutar evaluación
    return await repository.evaluateAndCreateAlerts(
      parcelaId: parcelaId,
      temperatura: temperatura,
      humedad: humedad,
    );
  }
}