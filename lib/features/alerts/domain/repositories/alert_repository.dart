import 'package:dartz/dartz.dart';
import '../entities/alert.dart';

abstract class AlertRepository {
  Future<Either<String, Alert>> createAlert(Alert alert);

  Future<Either<String, List<Alert>>> fetchAlerts({
    required String parcelaId,
    bool? onlyUnread,
    AlertType? type,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  });

  Future<Either<String, Unit>> markAlertAsRead(String alertId);

  Future<Either<String, Unit>> markAllAlertsAsRead(String parcelaId);

  Future<Either<String, int>> getUnreadAlertsCount(String parcelaId);
}
