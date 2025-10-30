import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para iniciar sesión
/// Contiene la lógica de negocio específica del login
/// Sigue el principio de Single Responsibility (una sola responsabilidad)
class LoginUseCase {

  LoginUseCase(this.repository);
  final AuthRepository repository;


  /// Ejecuta el caso de uso de login
  ///
  /// Parámetros:
  /// - [email]: Email del usuario
  /// - [password]: Contraseña del usuario
  ///
  /// Retorna:
  /// - Either<Failure, User>:
  ///   - Left: Error (InvalidCredentialsFailure, NetworkFailure, etc.)
  ///   - Right: Usuario autenticado exitosamente
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final result = await loginUseCase(
  ///   email: 'user@example.com',
  ///   password: 'password123',
  /// );
  ///
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (user) => print('Bienvenido: ${user.email}'),
  /// );
  /// ```
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    // Validaciones previas (opcional, también se valida en el UI)
    if (email.isEmpty) {
      return const Left(ValidationFailure('El email es requerido'));
    }

    if (password.isEmpty) {
      return const Left(ValidationFailure('La contraseña es requerida'));
    }

    // Limpiar espacios en blanco del email
    final cleanEmail = email.trim().toLowerCase();

    // Delegar la ejecución al repositorio
    return  repository.login(
      email: cleanEmail,
      password: password,
    );
  }
}