import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/parcela.dart';
import '../repositories/parcela_repository.dart';

/// Caso de uso para obtener una parcela específica por su ID
/// Contiene la lógica de negocio específica para buscar una parcela
/// Sigue el principio de Single Responsibility (una sola responsabilidad)
class GetParcelaByIdUseCase {
  final ParcelaRepository repository;

  GetParcelaByIdUseCase(this.repository);

  /// Ejecuta el caso de uso para obtener una parcela por ID
  ///
  /// Parámetros:
  /// - [parcelaId]: ID de la parcela a buscar
  ///
  /// Retorna:
  /// - Either<Failure, Parcela>:
  ///   - Left: Error (NotFoundFailure si no existe, NetworkFailure, etc.)
  ///   - Right: Parcela encontrada
  ///
  /// Validaciones:
  /// - El ID no debe estar vacío
  /// - La parcela debe existir
  /// - La parcela debe pertenecer al usuario autenticado
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final result = await getParcelaByIdUseCase('abc-123');
  ///
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (parcela) => print('Parcela: ${parcela.nombreParcela}'),
  /// );
  /// ```
  Future<Either<Failure, Parcela>> call(String parcelaId) async {
    // Validación: ID no puede estar vacío
    if (parcelaId.isEmpty) {
      return const Left(
        ValidationFailure('El ID de la parcela es requerido'),
      );
    }

    // Delegar la ejecución al repositorio
    return await repository.getParcelaById(parcelaId);
  }
}