import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/parcela.dart';

/// Contrato (interfaz) del repositorio de parcelas
/// Define QUÉ debe hacer el repositorio, pero NO CÓMO lo hace
/// La implementación estará en la capa Data
abstract class ParcelaRepository {
  /// Obtiene todas las parcelas activas del usuario autenticado
  ///
  /// Retorna Either<Failure, List<Parcela>>:
  /// - Left: Error (Failure)
  /// - Right: Lista de parcelas activas del usuario
  ///
  /// Solo retorna parcelas con `activa = true`
  Future<Either<Failure, List<Parcela>>> getParcelas();

  /// Obtiene una parcela específica por su ID
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela a buscar
  ///
  /// Retorna Either<Failure, Parcela>:
  /// - Left: Error (Failure) o parcela no encontrada
  /// - Right: Parcela encontrada
  Future<Either<Failure, Parcela>> getParcelaById(String parcelaId);

  /// Crea una nueva parcela
  ///
  /// Parámetros:
  /// - [nombreParcela]: Nombre de la parcela (requerido)
  /// - [latitud]: Latitud de la ubicación (opcional)
  /// - [longitud]: Longitud de la ubicación (opcional)
  /// - [usaUbicacionDefault]: Si usa coordenadas por defecto de Tisaleo
  /// - [areaHectareas]: Área en hectáreas (opcional)
  ///
  /// Retorna Either<Failure, Parcela>:
  /// - Left: Error (Failure)
  /// - Right: Parcela creada
  ///
  /// Nota: El campo `activa` se establece en true por defecto
  Future<Either<Failure, Parcela>> createParcela({
    required String nombreParcela,
    double? latitud,
    double? longitud,
    bool usaUbicacionDefault = false,
    double? areaHectareas,
  });

  /// Actualiza una parcela existente
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela a actualizar
  /// - [nombreParcela]: Nuevo nombre (opcional)
  /// - [latitud]: Nueva latitud (opcional)
  /// - [longitud]: Nueva longitud (opcional)
  /// - [usaUbicacionDefault]: Si usa ubicación por defecto (opcional)
  /// - [areaHectareas]: Nueva área (opcional)
  ///
  /// Retorna Either<Failure, Parcela>:
  /// - Left: Error (Failure)
  /// - Right: Parcela actualizada
  ///
  /// Solo se actualizan los campos proporcionados (no null)
  Future<Either<Failure, Parcela>> updateParcela({
    required String parcelaId,
    String? nombreParcela,
    double? latitud,
    double? longitud,
    bool? usaUbicacionDefault,
    double? areaHectareas,
  });

  /// Desactiva una parcela (borrado lógico)
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela a desactivar
  ///
  /// Retorna Either<Failure, void>:
  /// - Left: Error (Failure)
  /// - Right: Parcela desactivada exitosamente
  ///
  /// Nota: No elimina la parcela de la BD, solo cambia `activa = false`
  /// Los datos históricos asociados se mantienen intactos
  Future<Either<Failure, void>> deleteParcela(String parcelaId);

  /// Reactiva una parcela previamente desactivada
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela a reactivar
  ///
  /// Retorna Either<Failure, Parcela>:
  /// - Left: Error (Failure)
  /// - Right: Parcela reactivada
  ///
  /// Cambia `activa = true` y retorna la parcela actualizada
  Future<Either<Failure, Parcela>> reactivarParcela(String parcelaId);

  /// Obtiene el conteo de parcelas activas del usuario
  ///
  /// Retorna Either<Failure, int>:
  /// - Left: Error (Failure)
  /// - Right: Número de parcelas activas
  ///
  /// Útil para validar si el usuario tiene parcelas antes de mostrar el HomeScreen
  Future<Either<Failure, int>> getConteoParcelasActivas();
}