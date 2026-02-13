// lib/features/alerts/domain/entities/alert.dart
import 'package:equatable/equatable.dart';

/// Valores internos de la app (los que ya usas en tu UI/ML).
enum AlertType {
  // ... (todo tu código actual se mantiene igual)
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
      case AlertType.nAlto:
        return 'nitrogeno_alto';
      case AlertType.pAlto:
        return 'fosforo_alto';
      case AlertType.kAlto:
        return 'potasio_alto';
    }
  }

  static AlertType? tryParse(String value) {
    final v = value.trim().toLowerCase();

    for (final t in AlertType.values) {
      if (t.dbValue == v) return t;
    }

    switch (v) {
      case 'ph_muy_acido':
        return AlertType.phBajo;
      case 'ph_muy_alcalino':
        return AlertType.phAlto;
      case 'helada':
        return AlertType.tempBaja;
      case 'calor_excesivo':
        return AlertType.tempAlta;
      case 'sequia':
        return AlertType.humBaja;
      case 'exceso_humedad':
        return AlertType.humAlta;
      case 'nitrogeno_bajo':
        return AlertType.nBajo;
      case 'fosforo_bajo':
        return AlertType.pBajo;
      case 'potasio_bajo':
        return AlertType.kBajo;
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

  // ✅ Nueva lógica: isActive considera TANTO vista como expiración
  bool get isActive {
    // Si ya fue vista, no está activa
    if (vista) return false;

    // Si no está vista, verificar si expiró por tiempo
    return !isExpired;
  }

  // ✅ Nueva propiedad: verifica si la alerta expiró por tiempo
  bool get isExpired {
    final now = DateTime.now();
    final age = now.difference(createdAt);

    // Duración según severidad
    switch (severidad) {
      case AlertSeverity.critica:
        return age.inHours >= 24; // Expira en 24 horas
      case AlertSeverity.alta:
        return age.inHours >= 48; // Expira en 48 horas (2 días)
      case AlertSeverity.media:
        return age.inDays >= 7; // Expira en 7 días
      case AlertSeverity.baja:
        return age.inDays >= 14; // Expira en 14 días
      case null:
        return age.inDays >= 7; // Default: 7 días
    }
  }

  bool get isRead => vista;

  // ✅ Propiedad útil: tiempo restante antes de expirar
  Duration? get timeUntilExpiration {
    if (vista) return null;

    final now = DateTime.now();
    final age = now.difference(createdAt);

    Duration maxAge;
    switch (severidad) {
      case AlertSeverity.critica:
        maxAge = const Duration(hours: 24);
        break;
      case AlertSeverity.alta:
        maxAge = const Duration(hours: 48);
        break;
      case AlertSeverity.media:
        maxAge = const Duration(days: 7);
        break;
      case AlertSeverity.baja:
        maxAge = const Duration(days: 14);
        break;
      case null:
        maxAge = const Duration(days: 7);
    }

    final remaining = maxAge - age;
    return remaining.isNegative ? Duration.zero : remaining;
  }

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
    return 'Alert(id: $id, tipo: ${tipoAlerta.dbEnumValue}, parametro: $parametro, valor: $valorDetectado, vista: $vista, expirada: $isExpired)';
  }
}