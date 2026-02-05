import 'package:dartz/dartz.dart';

import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_engine_repository.dart';
import '../datasources/alert_engine_remote_datasource.dart';

class AlertEngineRepositoryImpl implements AlertEngineRepository {
  final AlertEngineRemoteDataSource remote;

  AlertEngineRepositoryImpl({required this.remote});

  @override
  Future<Either<String, List<Alert>>> generateAndPersistAlerts({
    required String parcelaId,
    required Map<String, double> features,
  }) async {
    try {
      final alerts = await remote.generateAndPersistAlerts(
        parcelaId: parcelaId,
        features: features,
      );
      return Right(alerts);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
