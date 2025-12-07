import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Contrato (interfaz) del repositorio de autenticación
/// Define QUÉ debe hacer el repositorio, pero NO CÓMO lo hace
/// La implementación estará en la capa Data
abstract class AuthRepository {
  /// Inicia sesión con email y contraseña
  /// Retorna Either<Failure, User>:
  /// - Left: Error (Failure)
  /// - Right: Usuario autenticado (User)
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario
  /// Retorna Either<Failure, User>:
  /// - Left: Error (Failure)
  /// - Right: Usuario registrado (User)
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    String? fullName,
    String? phone
  });

  /// Cierra la sesión del usuario actual
  /// Retorna Either<Failure, void>:
  /// - Left: Error (Failure)
  /// - Right: Sesión cerrada exitosamente
  Future<Either<Failure, void>> logout();

  /// Obtiene el usuario actual si está autenticado
  /// Retorna Either<Failure, User>:
  /// - Left: Error (Failure) o no hay usuario
  /// - Right: Usuario actual (User)
  Future<Either<Failure, User>> getCurrentUser();

  /// Envía un email para restablecer la contraseña
  /// Retorna Either<Failure, void>:
  /// - Left: Error (Failure)
  /// - Right: Email enviado exitosamente
  Future<Either<Failure, void>> resetPassword({
    required String email,
  });

  /// Stream que emite el usuario cuando cambia el estado de autenticación
  /// Útil para escuchar cambios en tiempo real (login, logout, etc.)
  Stream<User?> get authStateChanges;

  /// Verifica si hay un usuario autenticado actualmente
  /// Retorna true si hay un usuario, false si no
  Future<bool> isAuthenticated();
}