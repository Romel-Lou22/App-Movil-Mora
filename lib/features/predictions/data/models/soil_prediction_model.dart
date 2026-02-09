import '../../domain/entities/soil_prediction.dart';

/// Modelo que representa predicción de suelo desde la capa de datos
///
/// Extiende de SoilPrediction (entidad de dominio) y agrega funcionalidad
/// para convertir desde/hacia JSON (HuggingFace API y Supabase)
class SoilPredictionModel extends SoilPrediction {
  const SoilPredictionModel({
    required super.ph,
    required super.nitrogeno,
    required super.fosforo,
    required super.potasio,
    super.humedad, // ✅ nuevo (opcional, no rompe nada)
  });

  factory SoilPredictionModel.fromHuggingFaceResponse(Map<String, dynamic> json) {
    return SoilPredictionModel(
      ph: (json['ph'] as num).toDouble(),
      nitrogeno: (json['nitrogeno'] as num).toDouble(),
      fosforo: (json['fosforo'] as num).toDouble(),
      potasio: (json['potasio'] as num).toDouble(),
      // ✅ humedad NO viene del API -> se queda null
    );
  }

  factory SoilPredictionModel.fromSupabaseJson(Map<String, dynamic> json) {
    return SoilPredictionModel(
      ph: (json['ph'] as num).toDouble(),
      nitrogeno: (json['nitrogeno'] as num).toDouble(),
      fosforo: (json['fosforo'] as num).toDouble(),
      potasio: (json['potasio'] as num).toDouble(),
      // ✅ humedad solo si tu tabla la guarda (si no, déjalo fuera)
      // humedad: (json['humedad'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'ph': ph,
      'nitrogeno': nitrogeno,
      'fosforo': fosforo,
      'potasio': potasio,
      // ✅ NO guardo humedad para no obligarte a cambiar BD
      // Si quieres guardarla, descomenta y crea la columna:
      // 'humedad': humedad,
    };
  }

  factory SoilPredictionModel.fromEntity(SoilPrediction entity) {
    return SoilPredictionModel(
      ph: entity.ph,
      nitrogeno: entity.nitrogeno,
      fosforo: entity.fosforo,
      potasio: entity.potasio,
      humedad: entity.humedad, // ✅ nuevo (si viene null, ok)
    );
  }

  @override
  SoilPredictionModel copyWith({
    double? ph,
    double? nitrogeno,
    double? fosforo,
    double? potasio,
    double? humedad, // ✅ nuevo (firma compatible con el padre)
  }) {
    return SoilPredictionModel(
      ph: ph ?? this.ph,
      nitrogeno: nitrogeno ?? this.nitrogeno,
      fosforo: fosforo ?? this.fosforo,
      potasio: potasio ?? this.potasio,
      humedad: humedad ?? this.humedad,
    );
  }
}
