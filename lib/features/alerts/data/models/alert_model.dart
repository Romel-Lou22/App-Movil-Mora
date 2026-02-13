// lib/features/alerts/data/models/alert_model.dart
import '../../domain/entities/alert.dart';

/// Modelo de datos para Alertas (Supabase <-> Dominio)
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

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at'] as String?;
    final fechaAlertaRaw = json['fecha_alerta'] as String?;
    final sevStr = json['severidad'] as String?;

    return AlertModel(
      id: json['id'] as String,
      parcelaId: json['parcela_id'] as String,

      tipoAlerta: AlertType.fromDb(json['tipo_alerta'] as String),
      severidad: sevStr == null ? null : AlertSeverity.tryParse(sevStr),

      parametro: json['parametro'] as String,
      valorDetectado: (json['valor_detectado'] as num).toDouble(),
      umbral: json['umbral'] as String,
      mensaje: json['mensaje'] as String,
      recomendacion: json['recomendacion'] as String?,
      vista: json['vista'] as bool? ?? false,

      // ✅ FIX: Convertir de UTC a hora local
      fechaAlerta: fechaAlertaRaw != null
          ? DateTime.parse(fechaAlertaRaw).toLocal()
          : DateTime.now(),
      createdAt: createdAtRaw != null
          ? DateTime.parse(createdAtRaw).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parcela_id': parcelaId,
      'tipo_alerta': tipoAlerta.dbEnumValue,
      'severidad': severidad?.dbValue,
      'parametro': parametro,
      'valor_detectado': valorDetectado,
      'umbral': umbral,
      'mensaje': mensaje,
      'recomendacion': recomendacion,
      'vista': vista,
      // ✅ FIX: Convertir a UTC antes de guardar
      'fecha_alerta': fechaAlerta.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  /// Insert: NO mandes id ni created_at (DB los genera)
  Map<String, dynamic> toJsonForInsert() {
    return {
      'parcela_id': parcelaId,
      'tipo_alerta': tipoAlerta.dbEnumValue,
      'severidad': severidad?.dbValue,
      'parametro': parametro,
      'valor_detectado': valorDetectado,
      'umbral': umbral,
      'mensaje': mensaje,
      'recomendacion': recomendacion,
      'vista': vista,
      // ✅ FIX: Convertir a UTC antes de guardar
      'fecha_alerta': fechaAlerta.toUtc().toIso8601String(),
    };
  }

  /// Desde respuesta del Random Forest (API HF)
  factory AlertModel.fromRandomForestResponse({
    required String parcelaId,
    required String tipo,
    required String? recomendacion,
    required Map<String, double> valoresInput,
  }) {
    final alertType = AlertType.fromDb(tipo);
    final parametroInfo = _getParametroInfo(alertType, valoresInput);
    final mensaje = _generateMensaje(alertType, (parametroInfo['valor'] as double));
    final sev = _mapSeveridad(alertType);

    // ✅ Usar DateTime.now() que ya está en hora local
    final now = DateTime.now();

    return AlertModel(
      id: '',
      parcelaId: parcelaId,
      tipoAlerta: alertType,
      severidad: sev,
      parametro: parametroInfo['parametro'] as String,
      valorDetectado: parametroInfo['valor'] as double,
      umbral: parametroInfo['umbral'] as String,
      mensaje: mensaje,
      recomendacion: recomendacion,
      vista: false,
      fechaAlerta: now,
      createdAt: now,
    );
  }

  static Map<String, dynamic> _getParametroInfo(
      AlertType tipo,
      Map<String, double> valoresInput,
      ) {
    final ph = valoresInput['pH'] ?? valoresInput['ph'] ?? 0.0;
    final humSuelo = valoresInput['humedad_suelo_%'] ??
        valoresInput['humedad_suelo_pct'] ??
        0.0;

    double v(String k) => valoresInput[k] ?? 0.0;

    switch (tipo) {
      case AlertType.phBajo:
      case AlertType.phAlto:
        return {
          'parametro': 'pH',
          'valor': ph,
          'umbral': '5.5 - 6.5',
        };

      case AlertType.humBaja:
      case AlertType.humAlta:
        return {
          'parametro': 'Humedad del Suelo',
          'valor': humSuelo,
          'umbral': '60 - 80%',
        };

      case AlertType.tempBaja:
      case AlertType.tempAlta:
        return {
          'parametro': 'Temperatura',
          'valor': v('temperatura_C'),
          'umbral': '10 - 25°C',
        };

      case AlertType.nBajo:
      case AlertType.nAlto:
        return {
          'parametro': 'Nitrógeno (N)',
          'valor': v('N_ppm'),
          'umbral': '40 - 60 ppm',
        };

      case AlertType.pBajo:
      case AlertType.pAlto:
        return {
          'parametro': 'Fósforo (P)',
          'valor': v('P_ppm'),
          'umbral': '40 - 60 ppm',
        };

      case AlertType.kBajo:
      case AlertType.kAlto:
        return {
          'parametro': 'Potasio (K)',
          'valor': v('K_ppm'),
          'umbral': '200 - 300 ppm',
        };
    }
  }

  static String _generateMensaje(AlertType tipo, double valor) {
    final v = valor.toStringAsFixed(1);

    switch (tipo) {
      case AlertType.phBajo:
        return 'El pH del suelo ($v) está por debajo del rango óptimo';
      case AlertType.phAlto:
        return 'El pH del suelo ($v) está por encima del rango óptimo';

      case AlertType.humBaja:
        return 'La humedad del suelo ($v%) está muy baja';
      case AlertType.humAlta:
        return 'La humedad del suelo ($v%) está muy alta';

      case AlertType.tempBaja:
        return 'La temperatura ($v°C) está muy baja';
      case AlertType.tempAlta:
        return 'La temperatura ($v°C) está muy alta';

      case AlertType.nBajo:
        return 'El nivel de nitrógeno ($v ppm) está bajo';
      case AlertType.nAlto:
        return 'El nivel de nitrógeno ($v ppm) está alto';

      case AlertType.pBajo:
        return 'El nivel de fósforo ($v ppm) está bajo';
      case AlertType.pAlto:
        return 'El nivel de fósforo ($v ppm) está alto';

      case AlertType.kBajo:
        return 'El nivel de potasio ($v ppm) está bajo';
      case AlertType.kAlto:
        return 'El nivel de potasio ($v ppm) está alto';
    }
  }

  static AlertSeverity? _mapSeveridad(AlertType tipo) {
    switch (tipo) {
      case AlertType.humBaja:
      case AlertType.tempBaja:
        return AlertSeverity.critica;

      case AlertType.phBajo:
      case AlertType.phAlto:
        return AlertSeverity.alta;

      case AlertType.humAlta:
      case AlertType.tempAlta:
      case AlertType.nBajo:
      case AlertType.pBajo:
      case AlertType.kBajo:
        return AlertSeverity.media;

      case AlertType.nAlto:
      case AlertType.pAlto:
      case AlertType.kAlto:
        return AlertSeverity.baja;
    }
  }

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