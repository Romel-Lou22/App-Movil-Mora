import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/parcela.dart';
import '../repositories/parcela_repository.dart';

/// Caso de uso para actualizar una parcela existente
/// Contiene la lógica de negocio y validaciones para actualizar parcelas
/// Sigue el principio de Single Responsibility (una sola responsabilidad)
class UpdateParcelaUseCase {
  final ParcelaRepository repository;

  UpdateParcelaUseCase(this.repository);

  /// Ejecuta el caso de uso para actualizar una parcela
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela a actualizar (requerido)
  /// - [nombreParcela]: Nuevo nombre de la parcela (opcional)
  /// - [latitud]: Nueva latitud (opcional)
  /// - [longitud]: Nueva longitud (opcional)
  /// - [usaUbicacionDefault]: Si usa coordenadas por defecto (opcional)
  /// - [areaHectareas]: Nueva área en hectáreas (opcional)
  ///
  /// Retorna:
  /// - Either<Failure, Parcela>:
  ///   - Left: Error (ValidationFailure, NotFoundFailure, etc.)
  ///   - Right: Parcela actualizada exitosamente
  ///
  /// Validaciones aplicadas:
  /// - El ID de la parcela no puede estar vacío
  /// - Si se proporciona nombre, debe tener al menos 3 caracteres
  /// - Si se proporciona nombre, no debe exceder 100 caracteres
  /// - Si se proporcionan coordenadas, ambas deben estar presentes
  /// - La latitud debe estar entre -90 y 90
  /// - La longitud debe estar entre -180 y 180
  /// - Si se proporciona área, debe ser mayor que 0
  /// - Si se proporciona área, no debe exceder 1000 hectáreas
  ///
  /// Nota: Solo se actualizan los campos proporcionados (no null)
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final result = await updateParcelaUseCase(
  ///   parcelaId: 'abc-123',
  ///   nombreParcela: 'Parcela Norte Actualizada',
  ///   areaHectareas: 3.0,
  /// );
  ///
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (parcela) => print('Parcela actualizada: ${parcela.nombreParcela}'),
  /// );
  /// ```
  Future<Either<Failure, Parcela>> call({
    required String parcelaId,
    String? nombreParcela,
    double? latitud,
    double? longitud,
    bool? usaUbicacionDefault,
    double? areaHectareas,
  }) async {
    // === VALIDACIONES DE NEGOCIO ===

    // Validar ID de parcela
    if (parcelaId.isEmpty) {
      return const Left(
        ValidationFailure('El ID de la parcela es requerido'),
      );
    }

    // Validar nombre de parcela si se proporciona
    String? nombreLimpio;
    if (nombreParcela != null) {
      nombreLimpio = nombreParcela.trim();

      if (nombreLimpio.isEmpty) {
        return const Left(
          ValidationFailure('El nombre de la parcela no puede estar vacío'),
        );
      }

      if (nombreLimpio.length < 3) {
        return const Left(
          ValidationFailure('El nombre debe tener al menos 3 caracteres'),
        );
      }

      if (nombreLimpio.length > 100) {
        return const Left(
          ValidationFailure('El nombre no debe exceder 100 caracteres'),
        );
      }
    }

    // Validar coordenadas si se proporcionan
    if (usaUbicacionDefault != true) {
      // Si se proporciona una coordenada, ambas deben estar presentes
      if ((latitud != null && longitud == null) ||
          (latitud == null && longitud != null)) {
        return const Left(
          ValidationFailure(
            'Debe proporcionar tanto latitud como longitud, o ninguna',
          ),
        );
      }

      // Validar rangos de coordenadas
      if (latitud != null) {
        if (latitud < -90 || latitud > 90) {
          return const Left(
            ValidationFailure('La latitud debe estar entre -90 y 90'),
          );
        }
      }

      if (longitud != null) {
        if (longitud < -180 || longitud > 180) {
          return const Left(
            ValidationFailure('La longitud debe estar entre -180 y 180'),
          );
        }
      }
    }

    // Validar área si se proporciona
    if (areaHectareas != null) {
      if (areaHectareas <= 0) {
        return const Left(
          ValidationFailure('El área debe ser mayor que 0'),
        );
      }

      if (areaHectareas > 1000) {
        return const Left(
          ValidationFailure(
            'El área no puede exceder 1000 hectáreas. Verifica el valor.',
          ),
        );
      }
    }

    // === EJECUTAR ACTUALIZACIÓN ===

    // Delegar la ejecución al repositorio
    return await repository.updateParcela(
      parcelaId: parcelaId,
      nombreParcela: nombreLimpio,
      latitud: usaUbicacionDefault == true ? null : latitud,
      longitud: usaUbicacionDefault == true ? null : longitud,
      usaUbicacionDefault: usaUbicacionDefault,
      areaHectareas: areaHectareas,
    );
  }
}