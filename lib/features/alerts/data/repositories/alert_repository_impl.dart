import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../datasources/alert_remote_datasource.dart';
import '../models/alert_model.dart';

class AlertRepositoryImpl implements AlertRepository {
  final AlertRemoteDataSource remoteDataSource;

  AlertRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, Alert>> createAlert(Alert alert) async {
    try {
      // Si ya NO vas a crear manuales, puedes eliminar este método del repo
      // o dejarlo por compatibilidad.
      final model = AlertModel.fromEntity(alert);
      final created = await remoteDataSource.insertAlerts([model]);
      if (created.isEmpty) {
        return const Left('No se pudo crear la alerta');
      }
      return Right(created.first);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, List<Alert>>> fetchAlerts({
    required String parcelaId,
    bool? onlyUnread,
    AlertType? type,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      final models = await remoteDataSource.fetchAlerts(
        parcelaId: parcelaId,
        onlyUnread: onlyUnread ?? false,
        tipo: type,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      // Convertir modelo -> entidad (AlertModel extiende Alert)
      final alerts = models.cast<Alert>().toList();
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

  String _handleError(Object error) {
    debugPrint('🔴 ERROR ORIGINAL: $error');

    final msg = error.toString();

    if (msg.contains('SocketException') || msg.contains('NetworkException')) {
      return 'Sin conexión a internet. Verifica tu conexión.';
    }
    if (msg.contains('TimeoutException')) {
      return 'La operación tardó demasiado. Intenta nuevamente.';
    }
    if (msg.contains('Supabase')) {
      return 'Error al conectar con el servidor. Intenta más tarde.';
    }
    return 'Ocurrió un error inesperado. Intenta nuevamente.';
  }
}
