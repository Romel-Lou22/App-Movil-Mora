import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../datasources/alert_remote_datasource.dart';
import '../models/alert_model.dart';

/// Implementación del repositorio de alertas
///
/// Actúa como intermediario entre el DataSource y los Use Cases
/// Maneja errores y convierte modelos a entidades
class AlertRepositoryImpl implements AlertRepository {
  final AlertRemoteDataSource remoteDataSource;

  AlertRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<Alert>>> evaluateAndCreateAlerts({
    required String parcelaId,
    required double temperatura,
    required double humedad,
  }) async {
    try {
      final alertModels = await remoteDataSource.evaluateAndCreateAlerts(
        parcelaId: parcelaId,
        temperatura: temperatura,
        humedad: humedad,
      );

      // Convertir modelos a entidades
      final alerts = alertModels.map((model) => model as Alert).toList();

      return Right(alerts);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, Alert>> createAlert(Alert alert) async {
    try {
      // Convertir entidad a modelo
      final alertModel = AlertModel.fromEntity(alert);

      final createdModel = await remoteDataSource.createAlert(alertModel);

      return Right(createdModel);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, List<Alert>>> getActiveAlerts(String parcelaId) async {
    try {
      final alertModels = await remoteDataSource.getActiveAlerts(parcelaId);

      // Convertir modelos a entidades
      final alerts = alertModels.map((model) => model as Alert).toList();

      return Right(alerts);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, List<Alert>>> getAlertsHistory({
    required String parcelaId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      final alertModels = await remoteDataSource.getAlertsHistory(
        parcelaId: parcelaId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      // Convertir modelos a entidades
      final alerts = alertModels.map((model) => model as Alert).toList();

      return Right(alerts);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, List<Alert>>> getTodayAlerts(String parcelaId) async {
    try {
      final alertModels = await remoteDataSource.getTodayAlerts(parcelaId);

      final alerts = alertModels.map((model) => model as Alert).toList();

      return Right(alerts);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, List<Alert>>> getLastWeekAlerts(String parcelaId) async {
    try {
      final alertModels = await remoteDataSource.getLastWeekAlerts(parcelaId);

      final alerts = alertModels.map((model) => model as Alert).toList();

      return Right(alerts);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, List<Alert>>> getLastMonthAlerts(String parcelaId) async {
    try {
      final alertModels = await remoteDataSource.getLastMonthAlerts(parcelaId);

      final alerts = alertModels.map((model) => model as Alert).toList();

      return Right(alerts);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, List<Alert>>> getAlertsByDate({
    required String parcelaId,
    required DateTime date,
  }) async {
    try {
      final alertModels = await remoteDataSource.getAlertsByDate(
        parcelaId: parcelaId,
        date: date,
      );

      final alerts = alertModels.map((model) => model as Alert).toList();

      return Right(alerts);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, Unit>> markAlertAsRead(String alertId) async {
    try {
      await remoteDataSource.markAlertAsRead(alertId);
      return const Right(unit);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, Unit>> markAllAlertsAsRead(String parcelaId) async {
    try {
      await remoteDataSource.markAllAlertsAsRead(parcelaId);
      return const Right(unit);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, int>> getUnreadAlertsCount(String parcelaId) async {
    try {
      final count = await remoteDataSource.getUnreadAlertsCount(parcelaId);
      return Right(count);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, Unit>> deleteAlert(String alertId) async {
    try {
      await remoteDataSource.deleteAlert(alertId);
      return const Right(unit);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, List<Alert>>> getAlertsByType({
    required String parcelaId,
    required String tipoAlerta,
  }) async {
    try {
      final alertModels = await remoteDataSource.getAlertsByType(
        parcelaId: parcelaId,
        tipoAlerta: tipoAlerta,
      );

      // Convertir modelos a entidades
      final alerts = alertModels.map((model) => model as Alert).toList();

      return Right(alerts);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  /// Maneja y formatea los errores
  ///
  /// Convierte excepciones técnicas en mensajes amigables para el usuario
  String _handleError(Object error) {
    debugPrint('🔴 ERROR ORIGINAL: $error');
    debugPrint('🔴 STACK TRACE: ${StackTrace.current}');
    final errorMessage = error.toString();

    // Errores de red
    if (errorMessage.contains('SocketException') ||
        errorMessage.contains('NetworkException')) {
      return 'Sin conexión a internet. Verifica tu conexión.';
    }

    // Errores de timeout
    if (errorMessage.contains('TimeoutException')) {
      return 'La operación tardó demasiado. Intenta nuevamente.';
    }

    // Errores del Random Forest API
    if (errorMessage.contains('Random Forest')) {
      return 'Error al analizar los datos. Intenta más tarde.';
    }

    // Errores de Supabase
    if (errorMessage.contains('Supabase')) {
      return 'Error al conectar con el servidor. Intenta más tarde.';
    }

    // Errores de datos no encontrados
    if (errorMessage.contains('No se encontraron datos')) {
      return 'No hay datos suficientes para generar alertas.';
    }

    // Error genérico
    return 'Ocurrió un error inesperado. Intenta nuevamente.';
  }
}