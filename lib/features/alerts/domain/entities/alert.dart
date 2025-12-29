import 'package:equatable/equatable.dart';

/// Entidad que representa una alerta en el dominio de la aplicación
///
/// Esta es la representación pura del negocio, sin dependencias externas
class Alert extends Equatable {
  /// ID único de la alerta
  final String id;

  /// ID de la parcela asociada
  final String parcelaId;

  /// Tipo de alerta (ph_bajo, hum_baja, temp_alta, etc.)
  final String tipoAlerta;

  /// Severidad de la alerta (baja, media, alta, critica)
  /// Puede ser null si no se usa severidad
  final String? severidad;

  /// Parámetro medido (pH, Humedad, Temperatura, N, P, K)
  final String parametro;

  /// Valor detectado del parámetro
  final double valorDetectado;

  /// Umbral del parámetro (formato texto: "5.5 - 6.5")
  final String umbral;

  /// Mensaje descriptivo de la alerta
  final String mensaje;

  /// Recomendación para solucionar el problema
  final String? recomendacion;

  /// Indica si la alerta ha sido vista por el usuario
  final bool vista;

  /// Fecha y hora en que se generó la alerta
  final DateTime fechaAlerta;

  /// Fecha de creación en la base de datos
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

  /// Crea una copia de la alerta con campos modificados
  Alert copyWith({
    String? id,
    String? parcelaId,
    String? tipoAlerta,
    String? severidad,
    String? parametro,
    double? valorDetectado,
    String? umbral,
    String? mensaje,
    String? recomendacion,
    bool? vista,
    DateTime? fechaAlerta,
    DateTime? createdAt,
  }) {
    return Alert(
      id: id ?? this.id,
      parcelaId: parcelaId ?? this.parcelaId,
      tipoAlerta: tipoAlerta ?? this.tipoAlerta,
      severidad: severidad ?? this.severidad,
      parametro: parametro ?? this.parametro,
      valorDetectado: valorDetectado ?? this.valorDetectado,
      umbral: umbral ?? this.umbral,
      mensaje: mensaje ?? this.mensaje,
      recomendacion: recomendacion ?? this.recomendacion,
      vista: vista ?? this.vista,
      fechaAlerta: fechaAlerta ?? this.fechaAlerta,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Verifica si la alerta sigue activa (no ha expirado)
  bool get isActive {
    final now = DateTime.now();
    final difference = now.difference(fechaAlerta);

    // Determinar tiempo de expiración según severidad
    if (severidad == null) return difference.inHours < 72; // 3 días por defecto

    switch (severidad!.toLowerCase()) {
      case 'critica':
        return difference.inHours < 24; // 24 horas
      case 'alta':
        return difference.inHours < 48; // 48 horas
      case 'media':
        return difference.inHours < 72; // 72 horas
      case 'baja':
        return difference.inDays < 7; // 7 días
      default:
        return difference.inHours < 72;
    }
  }

  /// Obtiene el emoji según el tipo de alerta
  String get emoji {
    if (tipoAlerta.contains('ph')) return '⚗️';
    if (tipoAlerta.contains('hum')) return '💧';
    if (tipoAlerta.contains('temp')) return '🌡️';
    if (tipoAlerta.contains('n_')) return '🌿';
    if (tipoAlerta.contains('p_')) return '🌾';
    if (tipoAlerta.contains('k_')) return '🌱';
    return '⚠️';
  }

  /// Obtiene el color según severidad
  String get colorCode {
    if (severidad == null) return '#FFA500'; // Naranja por defecto

    switch (severidad!.toLowerCase()) {
      case 'critica':
        return '#DC2626'; // Rojo
      case 'alta':
        return '#F59E0B'; // Naranja
      case 'media':
        return '#FCD34D'; // Amarillo
      case 'baja':
        return '#10B981'; // Verde
      default:
        return '#FFA500';
    }
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
    return 'Alert(id: $id, tipo: $tipoAlerta, parametro: $parametro, valor: $valorDetectado, vista: $vista)';
  }
}