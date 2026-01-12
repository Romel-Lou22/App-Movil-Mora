import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/parcela.dart';
import '../repositories/parcela_repository.dart';

/// Caso de uso para obtener todas las parcelas activas del usuario
/// Contiene la lógica de negocio específica para listar parcelas
/// Sigue el principio de Single Responsibility (una sola responsabilidad)
class GetParcelasUseCase {
  final ParcelaRepository repository;

  GetParcelasUseCase(this.repository);

  /// Ejecuta el caso de uso para obtener todas las parcelas activas
  ///
  /// Retorna:
  /// - Either<Failure, List<Parcela>>:
  ///   - Left: Error (NetworkFailure, UnauthenticatedFailure, etc.)
  ///   - Right: Lista de parcelas activas del usuario
  ///
  /// Solo retorna parcelas con `activa = true`
  /// Ordenadas por fecha de creación (más recientes primero)
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final result = await getParcelasUseCase();
  ///
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (parcelas) => print('Parcelas: ${parcelas.length}'),
  /// );
  /// ```
  Future<Either<Failure, List<Parcela>>> call() async {
    // Delegar la ejecución al repositorio
    return await repository.getParcelas();
  }
}