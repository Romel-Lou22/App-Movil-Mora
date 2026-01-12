import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/parcela_repository.dart';

/// Caso de uso para desactivar (eliminar lógicamente) una parcela
/// Contiene la lógica de negocio específica para el borrado lógico
/// Sigue el principio de Single Responsibility (una sola responsabilidad)
class DeleteParcelaUseCase {
  final ParcelaRepository repository;

  DeleteParcelaUseCase(this.repository);

  /// Ejecuta el caso de uso para desactivar una parcela
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela a desactivar (requerido)
  ///
  /// Retorna:
  /// - Either<Failure, void>:
  ///   - Left: Error (ValidationFailure, NotFoundFailure, etc.)
  ///   - Right: Parcela desactivada exitosamente
  ///
  /// Comportamiento:
  /// - NO elimina la parcela de la base de datos
  /// - Cambia el campo `activa` a `false` (borrado lógico)
  /// - Los datos históricos asociados se mantienen intactos
  /// - Las alertas y predicciones asociadas permanecen
  /// - La parcela puede ser reactivada posteriormente
  ///
  /// Validaciones aplicadas:
  /// - El ID de la parcela no puede estar vacío
  /// - La parcela debe existir
  /// - La parcela debe pertenecer al usuario autenticado
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final result = await deleteParcelaUseCase('abc-123');
  ///
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (_) => print('Parcela desactivada exitosamente'),
  /// );
  /// ```
  Future<Either<Failure, void>> call(String parcelaId) async {
    // === VALIDACIONES DE NEGOCIO ===

    // Validar ID de parcela
    if (parcelaId.isEmpty) {
      return const Left(
        ValidationFailure('El ID de la parcela es requerido'),
      );
    }

    // === EJECUTAR DESACTIVACIÓN ===

    // Delegar la ejecución al repositorio
    return await repository.deleteParcela(parcelaId);
  }
}