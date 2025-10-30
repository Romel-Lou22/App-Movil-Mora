import 'package:equatable/equatable.dart';

/// Clase base abstracta para todos los fallos/errores de la aplicación
/// Usa Equatable para comparaciones de objetos
abstract class Failure extends Equatable {

  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

// === Errores de Autenticación ===

/// Error cuando las credenciales son incorrectas
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure()
      : super('Email o contraseña incorrectos');
}

/// Error cuando el email ya está registrado
class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure()
      : super('Este email ya está registrado');
}

/// Error cuando el usuario no está autenticado
class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure()
      : super('No estás autenticado. Por favor inicia sesión');
}

/// Error cuando el token de sesión expiró
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure()
      : super('Tu sesión ha expirado. Por favor inicia sesión nuevamente');
}

/// Error cuando el email no está verificado
class EmailNotVerifiedFailure extends Failure {
  const EmailNotVerifiedFailure()
      : super('Por favor verifica tu email antes de continuar');
}

/// Error cuando el usuario está deshabilitado
class UserDisabledFailure extends Failure {
  const UserDisabledFailure()
      : super('Esta cuenta ha sido deshabilitada');
}

/// Error cuando el formato del email es inválido
class InvalidEmailFailure extends Failure {
  const InvalidEmailFailure()
      : super('El formato del email no es válido');
}

/// Error cuando la contraseña es muy débil
class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure()
      : super('La contraseña debe tener al menos 6 caracteres');
}

// === Errores de Red/Servidor ===

/// Error de conexión a internet
class NetworkFailure extends Failure {
  const NetworkFailure()
      : super('No hay conexión a internet. Verifica tu conexión');
}

/// Error del servidor (500, 503, etc.)
class ServerFailure extends Failure {
  const ServerFailure([String? customMessage])
      : super(customMessage ?? 'Error del servidor. Intenta más tarde');
}

/// Error de timeout (request muy lento)
class TimeoutFailure extends Failure {
  const TimeoutFailure()
      : super('La solicitud tardó demasiado. Intenta nuevamente');
}

// === Errores Generales ===

/// Error desconocido o no manejado
class UnknownFailure extends Failure {
  const UnknownFailure([String? customMessage])
      : super(customMessage ?? 'Ocurrió un error inesperado');
}

/// Error de validación de datos
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Error cuando faltan permisos
class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure()
      : super('No tienes permisos para realizar esta acción');
}

// === Errores de Cache/Storage ===

/// Error al leer del almacenamiento local
class CacheFailure extends Failure {
  const CacheFailure()
      : super('Error al acceder al almacenamiento local');
}

// === Helper para convertir excepciones en Failures ===

/// Convierte excepciones de Supabase en Failures específicos
Failure mapSupabaseException(dynamic exception) {
  final errorMessage = exception.toString().toLowerCase();

  // Errores de autenticación
  if (errorMessage.contains('invalid login credentials') ||
      errorMessage.contains('invalid_credentials')) {
    return const InvalidCredentialsFailure();
  }

  if (errorMessage.contains('email already registered') ||
      errorMessage.contains('user already registered')) {
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

  if (errorMessage.contains('password should be at least')) {
    return const WeakPasswordFailure();
  }

  // Errores de red
  if (errorMessage.contains('network') ||
      errorMessage.contains('socket') ||
      errorMessage.contains('connection')) {
    return const NetworkFailure();
  }

  if (errorMessage.contains('timeout')) {
    return const TimeoutFailure();
  }

  // Error genérico con el mensaje de la excepción
  return UnknownFailure(exception.toString());
}