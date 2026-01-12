import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/parcela.dart';
import '../repositories/parcela_repository.dart';

/// Caso de uso para crear una nueva parcela
/// Contiene la lógica de negocio y validaciones para crear parcelas
/// Sigue el principio de Single Responsibility (una sola responsabilidad)
class CreateParcelaUseCase {
  final ParcelaRepository repository;

  CreateParcelaUseCase(this.repository);

  /// Ejecuta el caso de uso para crear una nueva parcela
  ///
  /// Parámetros:
  /// - [nombreParcela]: Nombre de la parcela (requerido)
  /// - [latitud]: Latitud de la ubicación (opcional)
  /// - [longitud]: Longitud de la ubicación (opcional)
  /// - [usaUbicacionDefault]: Si usa coordenadas por defecto de Tisaleo
  /// - [areaHectareas]: Área en hectáreas (opcional)
  ///
  /// Retorna:
  /// - Either<Failure, Parcela>:
  ///   - Left: Error (ValidationFailure, NetworkFailure, etc.)
  ///   - Right: Parcela creada exitosamente
  ///
  /// Validaciones aplicadas:
  /// - El nombre no puede estar vacío
  /// - El nombre debe tener al menos 3 caracteres
  /// - El nombre no debe exceder 100 caracteres
  /// - Si se proporcionan coordenadas, ambas deben estar presentes
  /// - La latitud debe estar entre -90 y 90
  /// - La longitud debe estar entre -180 y 180
  /// - Si se proporciona área, debe ser mayor que 0
  /// - Si se proporciona área, no debe exceder 1000 hectáreas (razonable)
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final result = await createParcelaUseCase(
  ///   nombreParcela: 'Parcela Norte',
  ///   latitud: -1.3667,
  ///   longitud: -78.6833,
  ///   areaHectareas: 2.5,
  /// );
  ///
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (parcela) => print('Parcela creada: ${parcela.id}'),
  /// );
  /// ```
  Future<Either<Failure, Parcela>> call({
    required String nombreParcela,
    double? latitud,
    double? longitud,
    bool usaUbicacionDefault = false,
    double? areaHectareas,
  }) async {
    // === VALIDACIONES DE NEGOCIO ===

    // Validar nombre de parcela
    final nombreLimpio = nombreParcela.trim();

    if (nombreLimpio.isEmpty) {
      return const Left(
        ValidationFailure('El nombre de la parcela es requerido'),
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

    // Validar coordenadas
    if (!usaUbicacionDefault) {
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

    // Validar área
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

    // === EJECUTAR CREACIÓN ===

    // Delegar la ejecución al repositorio
    return await repository.createParcela(
      nombreParcela: nombreLimpio,
      latitud: usaUbicacionDefault ? null : latitud,
      longitud: usaUbicacionDefault ? null : longitud,
      usaUbicacionDefault: usaUbicacionDefault,
      areaHectareas: areaHectareas,
    );
  }
}