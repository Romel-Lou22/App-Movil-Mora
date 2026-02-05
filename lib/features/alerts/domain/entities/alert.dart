// lib/features/alerts/domain/entities/alert.dart
import 'package:equatable/equatable.dart';

/// Valores internos de la app (los que ya usas en tu UI/ML).
/// IMPORTANTE:
/// - dbValue = “interno” (compat con tu app/ML: ph_bajo, temp_alta, etc.)
/// - dbEnumValue = valor REAL que tu BD acepta (ENUM tipo_alerta).
enum AlertType {
  // Valores internos (app/ML)
  phBajo('ph_bajo'),
  phAlto('ph_alto'),
  humBaja('hum_baja'),
  humAlta('hum_alta'),
  tempBaja('temp_baja'),
  tempAlta('temp_alta'),
  nBajo('n_bajo'),
  nAlto('n_alto'),
  pBajo('p_bajo'),
  pAlto('p_alto'),
  kBajo('k_bajo'),
  kAlto('k_alto');

  final String dbValue;
  const AlertType(this.dbValue);

  /// Valor REAL para insertar/filtrar contra el ENUM de tu BD (tipo_alerta).
  /// Debe coincidir con lo que creaste en SQL:
  /// helada, calor_excesivo, sequia, exceso_humedad, nitrogeno_bajo, fosforo_bajo,
  /// potasio_bajo, ph_muy_acido, ph_muy_alcalino, ...
  ///
  /// NOTA:
  /// Si tu BD NO tiene nitrogeno_alto/fosforo_alto/potasio_alto,
  /// entonces NO podrás insertar esos tipos sin actualizar tu ENUM en BD.
  String get dbEnumValue {
    switch (this) {
      case AlertType.phBajo:
        return 'ph_muy_acido';
      case AlertType.phAlto:
        return 'ph_muy_alcalino';

      case AlertType.tempBaja:
        return 'helada';
      case AlertType.tempAlta:
        return 'calor_excesivo';

      case AlertType.humBaja:
        return 'sequia';
      case AlertType.humAlta:
        return 'exceso_humedad';

      case AlertType.nBajo:
        return 'nitrogeno_bajo';
      case AlertType.pBajo:
        return 'fosforo_bajo';
      case AlertType.kBajo:
        return 'potasio_bajo';

    // Si tu BD NO tiene estos enums, cambiar BD o manejar de otra forma.
      case AlertType.nAlto:
        return 'nitrogeno_alto';
      case AlertType.pAlto:
        return 'fosforo_alto';
      case AlertType.kAlto:
        return 'potasio_alto';
    }
  }

  /// ✅ Acepta:
  /// - valores internos/ML (ph_bajo, hum_alta, etc.)
  /// - valores reales de BD (ph_muy_acido, helada, sequia, etc.)
  static AlertType? tryParse(String value) {
    final v = value.trim().toLowerCase();

    // 1) Match directo por valores internos (dbValue)
    for (final t in AlertType.values) {
      if (t.dbValue == v) return t;
    }

    // 2) Mapear desde ENUM real de BD -> valores internos
    switch (v) {
    // pH
      case 'ph_muy_acido':
        return AlertType.phBajo;
      case 'ph_muy_alcalino':
        return AlertType.phAlto;

    // Temperatura
      case 'helada':
        return AlertType.tempBaja;
      case 'calor_excesivo':
        return AlertType.tempAlta;

    // Humedad
      case 'sequia':
        return AlertType.humBaja;
      case 'exceso_humedad':
        return AlertType.humAlta;

    // Nutrientes (BD)
      case 'nitrogeno_bajo':
        return AlertType.nBajo;
      case 'fosforo_bajo':
        return AlertType.pBajo;
      case 'potasio_bajo':
        return AlertType.kBajo;

    // Si tu BD también tiene altos:
      case 'nitrogeno_alto':
        return AlertType.nAlto;
      case 'fosforo_alto':
        return AlertType.pAlto;
      case 'potasio_alto':
        return AlertType.kAlto;

      default:
        return null;
    }
  }

  static AlertType fromDb(String value) {
    return tryParse(value) ??
        (throw ArgumentError('Unknown AlertType from DB: $value'));
  }
}

/// Severidad alineada a BD (baja, media, alta, critica)
enum AlertSeverity {
  baja('baja'),
  media('media'),
  alta('alta'),
  critica('critica');

  final String dbValue;
  const AlertSeverity(this.dbValue);

  static AlertSeverity? tryParse(String value) {
    final v = value.trim().toLowerCase();
    for (final s in AlertSeverity.values) {
      if (s.dbValue == v) return s;
    }
    return null;
  }

  static AlertSeverity fromDb(String value) {
    return tryParse(value) ??
        (throw ArgumentError('Unknown AlertSeverity from DB: $value'));
  }
}

/// Entidad (Dominio)
class Alert extends Equatable {
  final String id;
  final String parcelaId;

  final AlertType tipoAlerta;
  final AlertSeverity? severidad;

  final String parametro;
  final double valorDetectado;
  final String umbral;
  final String mensaje;
  final String? recomendacion;

  final bool vista;

  final DateTime fechaAlerta;
  final DateTime createdAt;

  const Alert({
    required this.id,
    required this.parcelaId,
    required this.tipoAlerta,
    this.severidad,
    required this.parametro,
    required this.valorDetectado,
    required this.umbral,
    required this.mensaje,
    this.recomendacion,
    required this.vista,
    required this.fechaAlerta,
    required this.createdAt,
  });

  bool get isActive => !vista;
  bool get isRead => vista;

  static const Object _sentinel = Object();

  Alert copyWith({
    String? id,
    String? parcelaId,
    AlertType? tipoAlerta,
    Object? severidad = _sentinel,
    String? parametro,
    double? valorDetectado,
    String? umbral,
    String? mensaje,
    Object? recomendacion = _sentinel,
    bool? vista,
    DateTime? fechaAlerta,
    DateTime? createdAt,
  }) {
    return Alert(
      id: id ?? this.id,
      parcelaId: parcelaId ?? this.parcelaId,
      tipoAlerta: tipoAlerta ?? this.tipoAlerta,
      severidad:
      severidad == _sentinel ? this.severidad : severidad as AlertSeverity?,
      parametro: parametro ?? this.parametro,
      valorDetectado: valorDetectado ?? this.valorDetectado,
      umbral: umbral ?? this.umbral,
      mensaje: mensaje ?? this.mensaje,
      recomendacion: recomendacion == _sentinel
          ? this.recomendacion
          : recomendacion as String?,
      vista: vista ?? this.vista,
      fechaAlerta: fechaAlerta ?? this.fechaAlerta,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    parcelaId,
    tipoAlerta,
    severidad,
    parametro,
    valorDetectado,
    umbral,
    mensaje,
    recomendacion,
    vista,
    fechaAlerta,
    createdAt,
  ];

  @override
  String toString() {
    // Si quieres ver el valor real que se guarda en BD:
    return 'Alert(id: $id, tipo: ${tipoAlerta.dbEnumValue}, parametro: $parametro, valor: $valorDetectado, vista: $vista)';
  }
}
