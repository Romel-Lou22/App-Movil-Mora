import 'package:dartz/dartz.dart';
import '../entities/alert.dart';

abstract class AlertEngineRepository {
  Future<Either<String, List<Alert>>> generateAndPersistAlerts({
    required String parcelaId,
    required Map<String, double> features,
  });
}
