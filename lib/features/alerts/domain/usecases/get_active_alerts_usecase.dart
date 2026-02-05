import 'package:dartz/dartz.dart';
import '../entities/alert.dart';
import '../repositories/alert_repository.dart';

/// Use Case para obtener alertas activas (no vistas y no expiradas) de una parcela
class GetActiveAlertsUseCase {
  final AlertRepository repository;

  GetActiveAlertsUseCase(this.repository);

  Future<Either<String, List<Alert>>> call(
      String parcelaId, {
        int limit = 50,
      }) async {
    if (parcelaId.isEmpty) return const Left('ID de parcela inválido');
    if (limit <= 0) return const Left('Límite debe ser mayor a 0');
    if (limit > 200) return const Left('Límite máximo es 200 alertas');

    final result = await repository.fetchAlerts(
      parcelaId: parcelaId,
      onlyUnread: true, // vista = false
      limit: limit,
    );

    return result.fold(
      Left.new,
          (alerts) {
        // ✅ Filtrar SOLO activas (no expiradas)
        final active = alerts.where((a) => a.isActive).toList();

        // ✅ Orden: severidad desc (critica -> baja) y fecha desc
        active.sort((a, b) {
          final sevCmp = _compareSeverityDesc(a.severidad, b.severidad);
          if (sevCmp != 0) return sevCmp;
          return b.fechaAlerta.compareTo(a.fechaAlerta);
        });

        return Right(active);
      },
    );
  }

  Future<Either<String, int>> getCount(String parcelaId) async {
    if (parcelaId.isEmpty) return const Left('ID de parcela inválido');
    return repository.getUnreadAlertsCount(parcelaId);
  }

  int _compareSeverityDesc(AlertSeverity? a, AlertSeverity? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;  // null al final
    if (b == null) return -1;

    int rank(AlertSeverity s) {
      switch (s) {
        case AlertSeverity.critica:
          return 4;
        case AlertSeverity.alta:
          return 3;
        case AlertSeverity.media:
          return 2;
        case AlertSeverity.baja:
          return 1;
      }
    }

    // ✅ Descendente: 4 primero, 1 último
    return rank(b).compareTo(rank(a)) * -1;
    // alternativa más clara:
    // return rank(b) < rank(a) ? -1 : (rank(b) > rank(a) ? 1 : 0);
  }
}
