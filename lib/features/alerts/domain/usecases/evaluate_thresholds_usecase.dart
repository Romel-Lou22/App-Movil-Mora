import 'package:dartz/dartz.dart';
import '../entities/alert.dart';
import '../repositories/alert_engine_repository.dart';

/// Use Case: Generar y persistir alertas (HF + Supabase) a partir de features
class EvaluateThresholdsUseCase {
  final AlertEngineRepository engineRepository;

  EvaluateThresholdsUseCase(this.engineRepository);

  Future<Either<String, List<Alert>>> call({
    required String parcelaId,
    required Map<String, double> features,
  }) async {
    if (parcelaId.isEmpty) return const Left('ID de parcela inválido');

    const requiredKeys = {
      'pH',
      'temperatura_C',
      'humedad_suelo_pct',
      'N_ppm',
      'P_ppm',
      'K_ppm',
    };

    final missing = requiredKeys.where((k) => !features.containsKey(k)).toList();
    if (missing.isNotEmpty) {
      return Left('Faltan parámetros para evaluar: ${missing.join(', ')}');
    }

    final temp = features['temperatura_C']!;
    final hum = features['humedad_suelo_pct']!;
    if (temp < -50 || temp > 60) return const Left('Temperatura fuera de rango válido');
    if (hum < 0 || hum > 100) return const Left('Humedad fuera de rango válido (0-100%)');

    return engineRepository.generateAndPersistAlerts(
      parcelaId: parcelaId,
      features: features,
    );
  }
}
