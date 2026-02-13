import 'package:dartz/dartz.dart';
import '../entities/alert.dart';
import '../repositories/alert_repository.dart';

/// Use Case para obtener alertas activas (no vistas) de una parcela
class GetActiveAlertsUseCase {
  final AlertRepository repository;

  GetActiveAlertsUseCase(this.repository);

  Future<Either<String, List<Alert>>> call(
      String parcelaId, {
        int limit = 200, // ✅ Aumentado para cubrir más alertas
      }) async {
    if (parcelaId.isEmpty) return const Left('ID de parcela inválido');
    if (limit <= 0) return const Left('Límite debe ser mayor a 0');
    if (limit > 500) return const Left('Límite máximo es 500 alertas');

    final result = await repository.fetchAlerts(
      parcelaId: parcelaId,
      onlyUnread: true, // ✅ CRÍTICO: vista = false
      limit: limit,
    );

    return result.fold(
      Left.new,
          (alerts) {
        // ✅ YA NO filtrar por isActive aquí, porque ya viene filtrado por vista=false
        // El datasource ya hizo el trabajo

        // ✅ Ordenar por fecha de creación (más recientes primero)
        alerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Right(alerts);
      },
    );
  }

  Future<Either<String, int>> getCount(String parcelaId) async {
    if (parcelaId.isEmpty) return const Left('ID de parcela inválido');
    return repository.getUnreadAlertsCount(parcelaId);
  }
}