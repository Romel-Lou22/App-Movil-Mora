import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementación del repositorio de autenticación
/// Conecta la capa Domain con la capa Data
/// Maneja errores y convierte excepciones en Failures
class AuthRepositoryImpl implements AuthRepository {


  AuthRepositoryImpl({required this.remoteDataSource});
  final AuthRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Llamar al datasource para hacer login
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Convertir UserModel (Data) a User (Domain)
      return Right(userModel.toEntity());
    } catch (e) {
      // Mapear la excepción a un Failure específico
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      // Llamar al datasource para registrar
      final userModel = await remoteDataSource.register(
        email: email,
        password: password,
        fullName: fullName,
      );

      // Convertir UserModel (Data) a User (Domain)
      return Right(userModel.toEntity());
    } catch (e) {
      // Mapear la excepción a un Failure específico
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();

      if (userModel == null) {
        return const Left(UnauthenticatedFailure());
      }

      return Right(userModel.toEntity());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
  }) async {
    try {
      await remoteDataSource.resetPassword(email: email);
      return const Right(null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((userModel) {
      return userModel?.toEntity();
    });
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return userModel != null;
    } catch (e) {
      return false;
    }
  }

  /// Mapea excepciones a Failures específicos con mensajes en español
  Failure _mapExceptionToFailure(dynamic exception) {
    final errorMessage = exception.toString().toLowerCase();

    // Errores de autenticación
    if (errorMessage.contains('invalid login credentials') ||
        errorMessage.contains('invalid_credentials') ||
        errorMessage.contains('invalid_grant')) {
      return const InvalidCredentialsFailure();
    }

    if (errorMessage.contains('email already registered') ||
        errorMessage.contains('user already registered') ||
        errorMessage.contains('already_registered')) {
      return const EmailAlreadyInUseFailure();
    }

    if (errorMessage.contains('email not confirmed') ||
        errorMessage.contains('email_not_confirmed')) {
      return const EmailNotVerifiedFailure();
    }

    if (errorMessage.contains('user not found')) {
      return const InvalidCredentialsFailure();
    }

    if (errorMessage.contains('invalid email')) {
      return const InvalidEmailFailure();
    }

    if (errorMessage.contains('password') &&
        (errorMessage.contains('weak') || errorMessage.contains('at least'))) {
      return const WeakPasswordFailure();
    }

    // Errores de red
    if (errorMessage.contains('network') ||
        errorMessage.contains('socket') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('failed host lookup')) {
      return const NetworkFailure();
    }

    if (errorMessage.contains('timeout')) {
      return const TimeoutFailure();
    }

    // Error genérico
    return UnknownFailure(exception.toString());
  }
}