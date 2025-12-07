import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para registrar un nuevo usuario
/// Aplica validaciones y lógica de negocio antes de llamar al repositorio
class RegisterUseCase {

  RegisterUseCase(this.repository);
  final AuthRepository repository;

  /// Ejecuta el registro de usuario
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    // Limpiar datos antes de enviar
    final cleanEmail = email.trim().toLowerCase();
    final cleanFullName = fullName?.trim();
    final cleanPhone = phone?.trim();

    // Llamar al repositorio
    return  repository.register(
      email: cleanEmail,
      password: password,
      fullName: cleanFullName,

    );
  }
}