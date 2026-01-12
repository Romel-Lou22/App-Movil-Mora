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
  });

  /// Factory constructor que crea un SoilPredictionModel desde la respuesta de HuggingFace API
  ///
  /// Ejemplo de JSON de HuggingFace (endpoint /predict/suelo):
  /// ```json
  /// {
  ///   "ph": 6.23,
  ///   "nitrogeno": 3.73,
  ///   "fosforo": 3.31,
  ///   "potasio": 153.64
  /// }
  /// ```
  factory SoilPredictionModel.fromHuggingFaceResponse(
      Map<String, dynamic> json,
      ) {
    return SoilPredictionModel(
      ph: (json['ph'] as num).toDouble(),
      nitrogeno: (json['nitrogeno'] as num).toDouble(),
      fosforo: (json['fosforo'] as num).toDouble(),
      potasio: (json['potasio'] as num).toDouble(),
    );
  }

  /// Factory constructor que crea un SoilPredictionModel desde JSON de Supabase
  ///
  /// Ejemplo de JSON de Supabase (tabla datos_historicos):
  /// ```json
  /// {
  ///   "ph": 6.23,
  ///   "nitrogeno": 3.73,
  ///   "fosforo": 3.31,
  ///   "potasio": 153.64
  /// }
  /// ```
  factory SoilPredictionModel.fromSupabaseJson(Map<String, dynamic> json) {
    return SoilPredictionModel(
      ph: (json['ph'] as num).toDouble(),
      nitrogeno: (json['nitrogeno'] as num).toDouble(),
      fosforo: (json['fosforo'] as num).toDouble(),
      potasio: (json['potasio'] as num).toDouble(),
    );
  }

  /// Convierte el modelo a un Map para guardar en Supabase
  ///
  /// Incluye los campos de nutrientes del suelo:
  /// - ph
  /// - nitrogeno
  /// - fosforo
  /// - potasio
  Map<String, dynamic> toSupabaseMap() {
    return {
      'ph': ph,
      'nitrogeno': nitrogeno,
      'fosforo': fosforo,
      'potasio': potasio,
    };
  }

  /// Convierte la entidad SoilPrediction a SoilPredictionModel
  factory SoilPredictionModel.fromEntity(SoilPrediction entity) {
    return SoilPredictionModel(
      ph: entity.ph,
      nitrogeno: entity.nitrogeno,
      fosforo: entity.fosforo,
      potasio: entity.potasio,
    );
  }

  /// Crea una copia del modelo con campos modificados
  @override
  SoilPredictionModel copyWith({
    double? ph,
    double? nitrogeno,
    double? fosforo,
    double? potasio,
  }) {
    return SoilPredictionModel(
      ph: ph ?? this.ph,
      nitrogeno: nitrogeno ?? this.nitrogeno,
      fosforo: fosforo ?? this.fosforo,
      potasio: potasio ?? this.potasio,
    );
  }
}