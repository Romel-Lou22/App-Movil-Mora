import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para cerrar sesión
/// Contiene la lógica de negocio específica del logout
/// Sigue el principio de Single Responsibility (una sola responsabilidad)
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  /// Ejecuta el caso de uso de logout
  ///
  /// Retorna:
  /// - Either<Failure, void>:
  ///   - Left: Error al cerrar sesión (NetworkFailure, etc.)
  ///   - Right: Sesión cerrada exitosamente
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final result = await logoutUseCase();
  ///
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (_) => print('Sesión cerrada exitosamente'),
  /// );
  /// ```
  Future<Either<Failure, void>> call() async {
    // Delegar la ejecución al repositorio
    return await repository.logout();
  }
}