import 'package:equatable/equatable.dart';

/// Entidad que representa la predicción de nutrientes del suelo
///
/// Datos predichos por el modelo de ML de HuggingFace
class SoilPrediction extends Equatable {
  /// Nivel de pH del suelo (0-14)
  final double ph;

  /// Nivel de Nitrógeno en ppm (partes por millón)
  final double nitrogeno;

  /// Nivel de Fósforo en ppm (partes por millón)
  final double fosforo;

  /// Nivel de Potasio en ppm (partes por millón)
  final double potasio;

  /// Humedad (%) - viene de otro provider (clima), por eso es opcional
  final double? humedad;

  const SoilPrediction({
    required this.ph,
    required this.nitrogeno,
    required this.fosforo,
    required this.potasio,
    this.humedad,
  });

  // ========== RANGOS ÓPTIMOS PARA CULTIVO DE MORA ==========

  /// Rango óptimo de pH: 5.5 - 6.5
  static const double phMin = 5.5;
  static const double phMax = 6.5;

  /// Rango óptimo de Nitrógeno (N): 40 - 60 ppm
  static const double nitrogenoMin = 40.0;
  static const double nitrogenoMax = 60.0;

  /// Rango óptimo de Fósforo (P): 40 - 60 ppm
  static const double fosforoMin = 40.0;
  static const double fosforoMax = 60.0;

  /// Rango óptimo de Potasio (K): 200 - 300 ppm
  static const double potasioMin = 200.0;
  static const double potasioMax = 300.0;

  /// Rango óptimo de Humedad (%)
  /// Nota: Ajusta si tu criterio es distinto.
  static const double humedadMin = 60.0;
  static const double humedadMax = 80.0;

  // ========== VALIDACIONES DE RANGOS ÓPTIMOS ==========

  /// Verifica si el pH está en rango óptimo
  bool get phIsOptimal => ph >= phMin && ph <= phMax;

  /// Verifica si el pH está bajo
  bool get phIsLow => ph < phMin;

  /// Verifica si el pH está alto
  bool get phIsHigh => ph > phMax;

  /// Verifica si el Nitrógeno está en rango óptimo
  bool get nitrogenoIsOptimal =>
      nitrogeno >= nitrogenoMin && nitrogeno <= nitrogenoMax;

  /// Verifica si el Nitrógeno está bajo
  bool get nitrogenoIsLow => nitrogeno < nitrogenoMin;

  /// Verifica si el Nitrógeno está alto
  bool get nitrogenoIsHigh => nitrogeno > nitrogenoMax;

  /// Verifica si el Fósforo está en rango óptimo
  bool get fosforoIsOptimal => fosforo >= fosforoMin && fosforo <= fosforoMax;

  /// Verifica si el Fósforo está bajo
  bool get fosforoIsLow => fosforo < fosforoMin;

  /// Verifica si el Fósforo está alto
  bool get fosforoIsHigh => fosforo > fosforoMax;

  /// Verifica si el Potasio está en rango óptimo
  bool get potasioIsOptimal => potasio >= potasioMin && potasio <= potasioMax;

  /// Verifica si el Potasio está bajo
  bool get potasioIsLow => potasio < potasioMin;

  /// Verifica si el Potasio está alto
  bool get potasioIsHigh => potasio > potasioMax;

  // ========== HUMEDAD (NUEVO) ==========

  /// Verifica si hay dato de humedad
  bool get humedadHasData => humedad != null;

  /// Verifica si la Humedad está en rango óptimo
  bool get humedadIsOptimal =>
      humedad != null && humedad! >= humedadMin && humedad! <= humedadMax;

  /// Verifica si la Humedad está baja
  bool get humedadIsLow => humedad != null && humedad! < humedadMin;

  /// Verifica si la Humedad está alta
  bool get humedadIsHigh => humedad != null && humedad! > humedadMax;

  /// Verifica si todos los nutrientes están en rango óptimo
  /// (lo dejo exactamente como lo tenías: solo nutrientes)
  bool get allOptimal =>
      phIsOptimal && nitrogenoIsOptimal && fosforoIsOptimal && potasioIsOptimal;

  // ========== RECOMENDACIONES ==========

  /// ---- En vez de "recomendaciones", devuelve "importancia/impacto" ----

  /// Importancia del pH cuando está fuera de rango
  String? get phRecommendation {
    if (phIsLow) {
      return 'pH bajo: puede aumentar Mn/Al solubles hasta niveles tóxicos y reducir disponibilidad de P; esto afecta raíces, absorción de nutrientes y vigor.';
    }
    if (phIsHigh) {
      return 'pH alto: puede reducir disponibilidad de micronutrientes (Fe, Zn, Mn) y también inmovilizar P; puede causar clorosis y menor crecimiento.';
    }
    return null;
  }

  /// Importancia del Nitrógeno cuando está fuera de rango
  String? get nitrogenoRecommendation {
    if (nitrogenoIsLow) {
      return 'N bajo: el N es clave para clorofila/proteínas; suele causar hojas pálidas (clorosis), menor crecimiento, menor rendimiento y peor calidad.';
    }
    if (nitrogenoIsHigh) {
      return 'N alto: puede disparar vigor vegetativo; en mora puede aumentar riesgo de enfermedades en el dosel y reducir firmeza/calidad del fruto; si es tardío, aumenta riesgo de daño por frío.';
    }
    return null;
  }

  /// Importancia del Fósforo cuando está fuera de rango
  String? get fosforoRecommendation {
    if (fosforoIsLow) {
      return 'P bajo: el P es clave en ATP (energía), raíces y floración/fructificación; puede reducir vigor y producción; en mora puede verse como hojas viejas púrpuras.';
    }
    if (fosforoIsHigh) {
      return 'P alto: rara vez “quema” por sí solo, pero puede inducir deficiencias de Fe/Zn (antagonismo) y provocar clorosis y menor desempeño.';
    }
    return null;
  }

  /// Importancia del Potasio cuando está fuera de rango
  String? get potasioRecommendation {
    if (potasioIsLow) {
      return 'K bajo: el K regula estomas/osmosis, enzimas y transporte de azúcares; puede causar necrosis marginal en hojas viejas y afectar calidad y tolerancia a estrés.';
    }
    if (potasioIsHigh) {
      return 'K alto: el exceso puede competir con Mg y Ca (antagonismo), induciendo deficiencias secundarias que afectan fisiología y calidad.';
    }
    return null;
  }

  /// (Opcional pero recomendado) Importancia de la Humedad (ambiental) cuando está fuera de rango
  String? get humedadRecommendation {
    if (humedad == null) return null;

    if (humedadIsLow) {
      return 'Humedad baja: puede aumentar la demanda evaporativa; si falta agua disponible, sube el riesgo de estrés hídrico (menor tamaño/rendimiento/calidad de fruto).';
    }
    if (humedadIsHigh) {
      return 'Humedad alta: favorece microclimas húmedos y aumenta presión de hongos (p. ej. Botrytis/podredumbre gris) en flor y fruto.';
    }
    return null;
  }

  /// Obtiene todas las recomendaciones disponibles
  List<String> get allRecommendations {
    final recommendations = <String>[];

    if (phRecommendation != null) recommendations.add('⚗️ pH: $phRecommendation');
    if (nitrogenoRecommendation != null)
      recommendations.add('🌿 N: $nitrogenoRecommendation');
    if (fosforoRecommendation != null)
      recommendations.add('🌾 P: $fosforoRecommendation');
    if (potasioRecommendation != null)
      recommendations.add('🌱 K: $potasioRecommendation');
    if (humedadRecommendation != null) recommendations.add('💧 Humedad: $humedadRecommendation');

    return recommendations;
  }

  /// Crea una copia con campos modificados
  SoilPrediction copyWith({
    double? ph,
    double? nitrogeno,
    double? fosforo,
    double? potasio,
    double? humedad,
  }) {
    return SoilPrediction(
      ph: ph ?? this.ph,
      nitrogeno: nitrogeno ?? this.nitrogeno,
      fosforo: fosforo ?? this.fosforo,
      potasio: potasio ?? this.potasio,
      humedad: humedad ?? this.humedad,
    );
  }

  @override
  List<Object?> get props => [
    ph,
    nitrogeno,
    fosforo,
    potasio,
    humedad,
  ];

  @override
  String toString() {
    final humedadStr =
    humedad == null ? 'null' : '${humedad!.toStringAsFixed(2)}%';
    return 'SoilPrediction(pH: ${ph.toStringAsFixed(2)}, N: ${nitrogeno.toStringAsFixed(2)}, P: ${fosforo.toStringAsFixed(2)}, K: ${potasio.toStringAsFixed(2)}, Humedad: $humedadStr)';
  }
}
