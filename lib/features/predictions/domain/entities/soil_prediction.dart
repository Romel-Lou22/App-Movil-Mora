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

  const SoilPrediction({
    required this.ph,
    required this.nitrogeno,
    required this.fosforo,
    required this.potasio,
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

  // ========== VALIDACIONES DE RANGOS ÓPTIMOS ==========

  /// Verifica si el pH está en rango óptimo
  bool get phIsOptimal => ph >= phMin && ph <= phMax;

  /// Verifica si el pH está bajo
  bool get phIsLow => ph < phMin;

  /// Verifica si el pH está alto
  bool get phIsHigh => ph > phMax;

  /// Verifica si el Nitrógeno está en rango óptimo
  bool get nitrogenoIsOptimal => nitrogeno >= nitrogenoMin && nitrogeno <= nitrogenoMax;

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

  /// Verifica si todos los nutrientes están en rango óptimo
  bool get allOptimal =>
      phIsOptimal &&
          nitrogenoIsOptimal &&
          fosforoIsOptimal &&
          potasioIsOptimal;

  // ========== RECOMENDACIONES ==========

  /// Obtiene recomendación para el pH
  String? get phRecommendation {
    if (phIsLow) {
      return 'Aplicar cal agrícola para elevar el pH del suelo';
    }
    if (phIsHigh) {
      return 'Aplicar azufre elemental para reducir el pH del suelo';
    }
    return null;
  }

  /// Obtiene recomendación para el Nitrógeno
  String? get nitrogenoRecommendation {
    if (nitrogenoIsLow) {
      return 'Aplicar fertilizante nitrogenado (urea o sulfato de amonio)';
    }
    if (nitrogenoIsHigh) {
      return 'Reducir aplicación de nitrógeno, riesgo de crecimiento vegetativo excesivo';
    }
    return null;
  }

  /// Obtiene recomendación para el Fósforo
  String? get fosforoRecommendation {
    if (fosforoIsLow) {
      return 'Aplicar superfosfato simple o roca fosfórica';
    }
    if (fosforoIsHigh) {
      return 'No aplicar fósforo, puede bloquear absorción de otros nutrientes';
    }
    return null;
  }

  /// Obtiene recomendación para el Potasio
  String? get potasioRecommendation {
    if (potasioIsLow) {
      return 'Aplicar sulfato de potasio o cloruro de potasio';
    }
    if (potasioIsHigh) {
      return 'No aplicar potasio, puede afectar absorción de magnesio';
    }
    return null;
  }

  /// Obtiene todas las recomendaciones disponibles
  List<String> get allRecommendations {
    final recommendations = <String>[];

    if (phRecommendation != null) recommendations.add('⚗️ pH: $phRecommendation');
    if (nitrogenoRecommendation != null) recommendations.add('🌿 N: $nitrogenoRecommendation');
    if (fosforoRecommendation != null) recommendations.add('🌾 P: $fosforoRecommendation');
    if (potasioRecommendation != null) recommendations.add('🌱 K: $potasioRecommendation');

    return recommendations;
  }

  /// Crea una copia con campos modificados
  SoilPrediction copyWith({
    double? ph,
    double? nitrogeno,
    double? fosforo,
    double? potasio,
  }) {
    return SoilPrediction(
      ph: ph ?? this.ph,
      nitrogeno: nitrogeno ?? this.nitrogeno,
      fosforo: fosforo ?? this.fosforo,
      potasio: potasio ?? this.potasio,
    );
  }

  @override
  List<Object?> get props => [
    ph,
    nitrogeno,
    fosforo,
    potasio,
  ];

  @override
  String toString() {
    return 'SoilPrediction(pH: ${ph.toStringAsFixed(2)}, N: ${nitrogeno.toStringAsFixed(2)}, P: ${fosforo.toStringAsFixed(2)}, K: ${potasio.toStringAsFixed(2)})';
  }
}