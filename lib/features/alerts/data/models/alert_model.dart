import '../../domain/entities/alert.dart';

/// Modelo que representa una alerta desde la capa de datos
///
/// Extiende de Alert (entidad de dominio) y agrega funcionalidad
/// para convertir desde/hacia JSON (Supabase)
class AlertModel extends Alert {
  const AlertModel({
    required super.id,
    required super.parcelaId,
    required super.tipoAlerta,
    super.severidad,
    required super.parametro,
    required super.valorDetectado,
    required super.umbral,
    required super.mensaje,
    super.recomendacion,
    required super.vista,
    required super.fechaAlerta,
    required super.createdAt,
  });

  /// Factory constructor que crea un AlertModel desde JSON de Supabase
  ///
  /// Ejemplo de JSON de Supabase:
  /// ```json
  /// {
  ///   "id": "uuid-123",
  ///   "parcela_id": "uuid-456",
  ///   "tipo_alerta": "ph_bajo",
  ///   "severidad": "alta",
  ///   "parametro": "pH",
  ///   "valor_detectado": 4.8,
  ///   "umbral": "5.5 - 6.5",
  ///   "mensaje": "El pH del suelo está por debajo del rango óptimo",
  ///   "recomendacion": "Aplicar cal agrícola...",
  ///   "vista": false,
  ///   "fecha_alerta": "2024-12-28T10:30:00Z",
  ///   "created_at": "2024-12-28T10:30:00Z"
  /// }
  /// ```
  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      parcelaId: json['parcela_id'] as String,
      tipoAlerta: json['tipo_alerta'] as String,
      severidad: json['severidad'] as String?,
      parametro: json['parametro'] as String,
      valorDetectado: (json['valor_detectado'] as num).toDouble(),
      umbral: json['umbral'] as String,
      mensaje: json['mensaje'] as String,
      recomendacion: json['recomendacion'] as String?,
      vista: json['vista'] as bool? ?? false,
      fechaAlerta: DateTime.parse(json['fecha_alerta'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convierte el modelo a JSON para enviar a Supabase
  ///
  /// Usado al insertar nuevas alertas en la base de datos
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parcela_id': parcelaId,
      'tipo_alerta': tipoAlerta,
      'severidad': severidad,
      'parametro': parametro,
      'valor_detectado': valorDetectado,
      'umbral': umbral,
      'mensaje': mensaje,
      'recomendacion': recomendacion,
      'vista': vista,
      'fecha_alerta': fechaAlerta.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convierte el modelo a JSON para insertar (sin id, se genera automático)
  Map<String, dynamic> toJsonForInsert() {
    return {
      'parcela_id': parcelaId,
      'tipo_alerta': tipoAlerta,
      'severidad': severidad,
      'parametro': parametro,
      'valor_detectado': valorDetectado,
      'umbral': umbral,
      'mensaje': mensaje,
      'recomendacion': recomendacion,
      'vista': vista,
      'fecha_alerta': fechaAlerta.toIso8601String(),
    };
  }

  /// Factory constructor que crea un AlertModel desde la respuesta del Random Forest
  ///
  /// Ejemplo de item de alertas_detectadas:
  /// ```json
  /// {
  ///   "tipo": "ph_bajo",
  ///   "recomendacion": "Aplicar cal agrícola..."
  /// }
  /// ```
  factory AlertModel.fromRandomForestResponse({
    required String parcelaId,
    required String tipo,
    required String recomendacion,
    required Map<String, double> valoresInput,
  }) {
    // Mapear el tipo de alerta al parámetro y valor correspondiente
    final parametroInfo = _getParametroInfo(tipo, valoresInput);

    // Generar mensaje descriptivo
    final mensaje = _generateMensaje(tipo, parametroInfo['valor'] as double);

    // Mapear severidad (opcional)
    final severidad = _mapSeveridad(tipo);

    return AlertModel(
      id: '', // Se generará en Supabase
      parcelaId: parcelaId,
      tipoAlerta: tipo,
      severidad: severidad,
      parametro: parametroInfo['parametro'] as String,
      valorDetectado: parametroInfo['valor'] as double,
      umbral: parametroInfo['umbral'] as String,
      mensaje: mensaje,
      recomendacion: recomendacion,
      vista: false,
      fechaAlerta: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  /// Mapea el tipo de alerta al parámetro, valor y umbral
  static Map<String, dynamic> _getParametroInfo(
      String tipo,
      Map<String, double> valoresInput,
      ) {
    switch (tipo) {
      case 'ph_bajo':
      case 'ph_alto':
        return {
          'parametro': 'pH',
          'valor': valoresInput['pH'] ?? 0.0,
          'umbral': '5.5 - 6.5',
        };

      case 'hum_baja':
      case 'hum_alta':
        return {
          'parametro': 'Humedad del Suelo',
          'valor': valoresInput['humedad_suelo_%'] ?? 0.0,
          'umbral': '60 - 80%',
        };

      case 'temp_baja':
      case 'temp_alta':
        return {
          'parametro': 'Temperatura',
          'valor': valoresInput['temperatura_C'] ?? 0.0,
          'umbral': '10 - 25°C',
        };

      case 'n_bajo':
      case 'n_alto':
        return {
          'parametro': 'Nitrógeno (N)',
          'valor': valoresInput['N_ppm'] ?? 0.0,
          'umbral': '40 - 60 ppm',
        };

      case 'p_bajo':
      case 'p_alto':
        return {
          'parametro': 'Fósforo (P)',
          'valor': valoresInput['P_ppm'] ?? 0.0,
          'umbral': '40 - 60 ppm',
        };

      case 'k_bajo':
      case 'k_alto':
        return {
          'parametro': 'Potasio (K)',
          'valor': valoresInput['K_ppm'] ?? 0.0,
          'umbral': '200 - 300 ppm',
        };

      default:
        return {
          'parametro': 'Desconocido',
          'valor': 0.0,
          'umbral': 'N/A',
        };
    }
  }

  /// Genera un mensaje descriptivo según el tipo de alerta
  static String _generateMensaje(String tipo, double valor) {
    final valorStr = valor.toStringAsFixed(1);

    final mensajes = {
      'ph_bajo': 'El pH del suelo ($valorStr) está por debajo del rango óptimo',
      'ph_alto': 'El pH del suelo ($valorStr) está por encima del rango óptimo',
      'hum_baja': 'La humedad del suelo ($valorStr%) está muy baja',
      'hum_alta': 'La humedad del suelo ($valorStr%) está muy alta',
      'temp_baja': 'La temperatura ($valorStr°C) está muy baja',
      'temp_alta': 'La temperatura ($valorStr°C) está muy alta',
      'n_bajo': 'El nivel de nitrógeno ($valorStr ppm) está bajo',
      'n_alto': 'El nivel de nitrógeno ($valorStr ppm) está alto',
      'p_bajo': 'El nivel de fósforo ($valorStr ppm) está bajo',
      'p_alto': 'El nivel de fósforo ($valorStr ppm) está alto',
      'k_bajo': 'El nivel de potasio ($valorStr ppm) está bajo',
      'k_alto': 'El nivel de potasio ($valorStr ppm) está alto',
    };

    return mensajes[tipo] ?? 'Alerta detectada en los parámetros del cultivo';
  }

  /// Mapea el tipo de alerta a una severidad
  static String? _mapSeveridad(String tipo) {
    // Mapeo simple basado en el tipo de alerta
    final severidadMap = {
      'ph_bajo': 'alta',
      'ph_alto': 'alta',
      'hum_baja': 'critica',
      'hum_alta': 'media',
      'temp_baja': 'critica',
      'temp_alta': 'media',
      'n_bajo': 'media',
      'n_alto': 'baja',
      'p_bajo': 'media',
      'p_alto': 'baja',
      'k_bajo': 'media',
      'k_alto': 'baja',
    };

    return severidadMap[tipo];
  }

  /// Convierte la entidad Alert a AlertModel
  factory AlertModel.fromEntity(Alert alert) {
    return AlertModel(
      id: alert.id,
      parcelaId: alert.parcelaId,
      tipoAlerta: alert.tipoAlerta,
      severidad: alert.severidad,
      parametro: alert.parametro,
      valorDetectado: alert.valorDetectado,
      umbral: alert.umbral,
      mensaje: alert.mensaje,
      recomendacion: alert.recomendacion,
      vista: alert.vista,
      fechaAlerta: alert.fechaAlerta,
      createdAt: alert.createdAt,
    );
  }
}