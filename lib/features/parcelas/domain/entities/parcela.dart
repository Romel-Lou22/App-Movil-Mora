import 'package:equatable/equatable.dart';

/// Entidad de Parcela (Domain Layer)
/// Representa una parcela agrícola en la lógica de negocio
/// NO depende de ningún framework o librería externa (excepto Equatable)
class Parcela extends Equatable {
  /// ID único de la parcela en Supabase
  final String id;

  /// ID del usuario propietario
  final String usuarioId;

  /// Nombre de la parcela (ej: "Parcela Norte", "Lote Sur")
  final String nombreParcela;

  /// Latitud de la ubicación (opcional)
  /// Null si usa ubicación por defecto
  final double? latitud;

  /// Longitud de la ubicación (opcional)
  /// Null si usa ubicación por defecto
  final double? longitud;

  /// Si usa las coordenadas por defecto de Tisaleo
  final bool usaUbicacionDefault;

  /// Área de la parcela en hectáreas (opcional)
  final double? areaHectareas;

  /// Si la parcela está activa (true) o desactivada (false)
  /// Usado para borrado lógico
  final bool activa;

  /// Fecha de creación de la parcela
  final DateTime? fechaCreacion;

  /// Fecha de creación del registro
  final DateTime? createdAt;

  /// Fecha de última actualización
  final DateTime? updatedAt;

  const Parcela({
    required this.id,
    required this.usuarioId,
    required this.nombreParcela,
    this.latitud,
    this.longitud,
    this.usaUbicacionDefault = false,
    this.areaHectareas,
    this.activa = true,
    required this.fechaCreacion,
    this.createdAt,
    this.updatedAt,
  });

  /// Parcela vacía (para estados iniciales)
  static const empty = Parcela(
    id: '',
    usuarioId: '',
    nombreParcela: '',
    fechaCreacion: null,
  );

  /// Verifica si la parcela está vacía
  bool get isEmpty => this == Parcela.empty;

  /// Verifica si la parcela NO está vacía
  bool get isNotEmpty => this != Parcela.empty;

  /// Verifica si la parcela tiene ubicación específica
  bool get tieneUbicacion => latitud != null && longitud != null;

  /// Obtiene la ubicación como String legible
  String get ubicacionDisplay {
    if (usaUbicacionDefault) {
      return 'Tisaleo (general)';
    } else if (tieneUbicacion) {
      return '${latitud!.toStringAsFixed(5)}, ${longitud!.toStringAsFixed(5)}';
    } else {
      return 'Sin ubicación';
    }
  }

  /// Obtiene el área como String legible
  String get areaDisplay {
    if (areaHectareas != null) {
      return '${areaHectareas!.toStringAsFixed(2)} ha';
    }
    return 'No especificada';
  }

  /// Coordenadas por defecto de Tisaleo, Tungurahua, Ecuador
  static const double DEFAULT_LATITUDE = -1.34627;
  static const double DEFAULT_LONGITUDE = -78.66877;

  /// Obtiene la latitud efectiva (propia o por defecto)
  double get latitudEfectiva {
    if (usaUbicacionDefault) {
      return DEFAULT_LATITUDE;
    }
    return latitud ?? DEFAULT_LATITUDE;
  }

  /// Obtiene la longitud efectiva (propia o por defecto)
  double get longitudEfectiva {
    if (usaUbicacionDefault) {
      return DEFAULT_LONGITUDE;
    }
    return longitud ?? DEFAULT_LONGITUDE;
  }

  /// Copia la parcela con algunos campos modificados
  Parcela copyWith({
    String? id,
    String? usuarioId,
    String? nombreParcela,
    double? latitud,
    double? longitud,
    bool? usaUbicacionDefault,
    double? areaHectareas,
    bool? activa,
    DateTime? fechaCreacion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Parcela(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      nombreParcela: nombreParcela ?? this.nombreParcela,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      usaUbicacionDefault: usaUbicacionDefault ?? this.usaUbicacionDefault,
      areaHectareas: areaHectareas ?? this.areaHectareas,
      activa: activa ?? this.activa,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    usuarioId,
    nombreParcela,
    latitud,
    longitud,
    usaUbicacionDefault,
    areaHectareas,
    activa,
    fechaCreacion,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'Parcela(id: $id, nombre: $nombreParcela, activa: $activa, ubicacion: $ubicacionDisplay)';
  }
}