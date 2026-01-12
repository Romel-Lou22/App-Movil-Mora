import '../../domain/entities/parcela.dart';

/// Modelo de Parcela (Data Layer)
/// Extiende la entidad de dominio y agrega funcionalidad de serialización
/// Maneja la conversión entre JSON (Supabase) y la entidad de negocio
class ParcelaModel extends Parcela {
  const ParcelaModel({
    required super.id,
    required super.usuarioId,
    required super.nombreParcela,
    super.latitud,
    super.longitud,
    super.usaUbicacionDefault,
    super.areaHectareas,
    super.activa,
    required super.fechaCreacion,
    super.createdAt,
    super.updatedAt,
  });

  /// Crea un ParcelaModel desde JSON (respuesta de Supabase)
  ///
  /// Ejemplo de JSON de Supabase:
  /// ```json
  /// {
  ///   "id": "abc-123",
  ///   "usuario_id": "user-456",
  ///   "nombre_parcela": "Parcela Norte",
  ///   "latitud": -1.3667,
  ///   "longitud": -78.6833,
  ///   "usa_ubicacion_default": false,
  ///   "area_hectareas": 2.5,
  ///   "activa": true,
  ///   "fecha_creacion": "2024-01-15T10:30:00Z",
  ///   "created_at": "2024-01-15T10:30:00Z",
  ///   "updated_at": "2024-01-15T10:30:00Z"
  /// }
  /// ```
  factory ParcelaModel.fromJson(Map<String, dynamic> json) {
    return ParcelaModel(
      id: json['id'] as String,
      usuarioId: json['usuario_id'] as String,
      nombreParcela: json['nombre_parcela'] as String,
      latitud: json['latitud'] != null
          ? (json['latitud'] as num).toDouble()
          : null,
      longitud: json['longitud'] != null
          ? (json['longitud'] as num).toDouble()
          : null,
      usaUbicacionDefault: json['usa_ubicacion_default'] as bool? ?? false,
      areaHectareas: json['area_hectareas'] != null
          ? (json['area_hectareas'] as num).toDouble()
          : null,
      activa: json['activa'] as bool? ?? true,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convierte el modelo a JSON para enviar a Supabase
  ///
  /// Usado en operaciones de INSERT y UPDATE
  ///
  /// Ejemplo de salida:
  /// ```json
  /// {
  ///   "usuario_id": "user-456",
  ///   "nombre_parcela": "Parcela Norte",
  ///   "latitud": -1.3667,
  ///   "longitud": -78.6833,
  ///   "usa_ubicacion_default": false,
  ///   "area_hectareas": 2.5,
  ///   "activa": true
  /// }
  /// ```
  ///
  /// Nota: No incluye `id`, `fecha_creacion`, `created_at`, `updated_at`
  /// porque son manejados automáticamente por Supabase
  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'nombre_parcela': nombreParcela,
      'latitud': latitud,
      'longitud': longitud,
      'usa_ubicacion_default': usaUbicacionDefault,
      'area_hectareas': areaHectareas,
      'activa': activa,
    };
  }

  /// Convierte el modelo a JSON para UPDATE (solo campos proporcionados)
  ///
  /// Similar a toJson() pero incluye solo los campos que no son null
  /// Útil para actualizaciones parciales
  ///
  /// Parámetros opcionales permiten actualizar solo campos específicos
  Map<String, dynamic> toJsonForUpdate({
    String? nombreParcela,
    double? latitud,
    double? longitud,
    bool? usaUbicacionDefault,
    double? areaHectareas,
    bool? activa,
  }) {
    final updates = <String, dynamic>{};

    if (nombreParcela != null) {
      updates['nombre_parcela'] = nombreParcela;
    }

    if (latitud != null) {
      updates['latitud'] = latitud;
    }

    if (longitud != null) {
      updates['longitud'] = longitud;
    }

    if (usaUbicacionDefault != null) {
      updates['usa_ubicacion_default'] = usaUbicacionDefault;
      // Si se activa ubicación por defecto, limpiar coordenadas
      if (usaUbicacionDefault) {
        updates['latitud'] = null;
        updates['longitud'] = null;
      }
    }

    if (areaHectareas != null) {
      updates['area_hectareas'] = areaHectareas;
    }

    if (activa != null) {
      updates['activa'] = activa;
    }

    return updates;
  }

  /// Convierte el modelo a la entidad de dominio
  ///
  /// Usado para pasar datos de la capa Data a la capa Domain
  Parcela toEntity() {
    return Parcela(
      id: id,
      usuarioId: usuarioId,
      nombreParcela: nombreParcela,
      latitud: latitud,
      longitud: longitud,
      usaUbicacionDefault: usaUbicacionDefault,
      areaHectareas: areaHectareas,
      activa: activa,
      fechaCreacion: fechaCreacion,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crea un ParcelaModel desde una entidad de dominio
  ///
  /// Útil para convertir de Domain a Data cuando sea necesario
  factory ParcelaModel.fromEntity(Parcela parcela) {
    return ParcelaModel(
      id: parcela.id,
      usuarioId: parcela.usuarioId,
      nombreParcela: parcela.nombreParcela,
      latitud: parcela.latitud,
      longitud: parcela.longitud,
      usaUbicacionDefault: parcela.usaUbicacionDefault,
      areaHectareas: parcela.areaHectareas,
      activa: parcela.activa,
      fechaCreacion: parcela.fechaCreacion,
      createdAt: parcela.createdAt,
      updatedAt: parcela.updatedAt,
    );
  }
}