import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart'; // O 'package:fpdart/fpdart.dart' si usas fpdart
import '../../domain/entities/alert.dart';
import '../../domain/usecases/create_alert_usecase.dart';
import '../../domain/usecases/evaluate_thresholds_usecase.dart';
import '../../domain/usecases/get_active_alerts_usecase.dart';
import '../../domain/usecases/get_alerts_history_usecase.dart';
import '../../domain/usecases/mark_alert_as_read_usecase.dart';

/// Estados posibles del provider
enum AlertStatus {
  initial,    // Estado inicial
  loading,    // Cargando datos
  success,    // Operación exitosa
  error,      // Error en operación
}

/// Filtros rápidos para el historial
enum DateFilter {
  all,        // Todas las alertas
  today,      // Solo hoy
  week,       // Última semana
  month,      // Último mes
  custom,     // Rango personalizado
}

/// Provider que maneja el estado de las alertas
///
/// Responsabilidades:
/// - Evaluar umbrales y generar alertas
/// - Obtener alertas activas e historial (con filtros por fecha)
/// - Marcar alertas como leídas
/// - Crear alertas manuales
/// - Mantener el conteo de alertas sin leer
class AlertProvider extends ChangeNotifier {
  // Use Cases
  final EvaluateThresholdsUseCase evaluateThresholdsUseCase;
  final GetActiveAlertsUseCase getActiveAlertsUseCase;
  final GetAlertsHistoryUseCase getAlertsHistoryUseCase;
  final MarkAlertAsReadUseCase markAlertAsReadUseCase;
  final CreateAlertUseCase createAlertUseCase;

  AlertProvider({
    required this.evaluateThresholdsUseCase,
    required this.getActiveAlertsUseCase,
    required this.getAlertsHistoryUseCase,
    required this.markAlertAsReadUseCase,
    required this.createAlertUseCase,
  });

  // Estado general
  AlertStatus _status = AlertStatus.initial;
  String _errorMessage = '';

  // Alertas activas
  List<Alert> _activeAlerts = [];
  int _unreadCount = 0;

  // Historial de alertas
  List<Alert> _alertsHistory = [];
  Map<String, List<Alert>> _groupedByDate = {};

  // Filtros de fecha
  DateFilter _currentFilter = DateFilter.all;
  DateTime? _selectedDate;
  DateTime? _startDate;
  DateTime? _endDate;

  // Estado de evaluación
  bool _isEvaluating = false;
  List<Alert> _lastEvaluationAlerts = [];

  // Getters - Estado general
  AlertStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == AlertStatus.loading;
  bool get hasError => _status == AlertStatus.error;
  bool get isEvaluating => _isEvaluating;

  // Getters - Alertas activas
  List<Alert> get activeAlerts => _activeAlerts;
  int get unreadCount => _unreadCount;
  bool get hasActiveAlerts => _activeAlerts.isNotEmpty;
  bool get hasUnreadAlerts => _unreadCount > 0;

  // Getters - Historial
  List<Alert> get alertsHistory => _alertsHistory;
  Map<String, List<Alert>> get groupedByDate => _groupedByDate;
  bool get hasHistory => _alertsHistory.isNotEmpty;

  // Getters - Filtros
  DateFilter get currentFilter => _currentFilter;
  DateTime? get selectedDate => _selectedDate;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get filterDescription => _getFilterDescription();

  // Getters - Última evaluación
  List<Alert> get lastEvaluationAlerts => _lastEvaluationAlerts;
  bool get hasNewAlerts => _lastEvaluationAlerts.isNotEmpty;

  /// Evalúa los umbrales y genera alertas automáticamente
  Future<void> evaluateThresholds({
    required String parcelaId,
    required double temperatura,
    required double humedad,
  }) async {
    _isEvaluating = true;
    _lastEvaluationAlerts = [];
    notifyListeners();

    final result = await evaluateThresholdsUseCase(
      parcelaId: parcelaId,
      temperatura: temperatura,
      humedad: humedad,
    );

    result.fold(
          (error) {
        _status = AlertStatus.error;
        _errorMessage = error;
        _isEvaluating = false;
        notifyListeners();
      },
          (alerts) {
        _lastEvaluationAlerts = alerts;
        _isEvaluating = false;

        if (alerts.isNotEmpty) {
          fetchActiveAlerts(parcelaId);
        } else {
          _status = AlertStatus.success;
          notifyListeners();
        }
      },
    );
  }

  /// Obtiene las alertas activas de una parcela
  Future<void> fetchActiveAlerts(String parcelaId) async {
    _status = AlertStatus.loading;
    notifyListeners();

    final result = await getActiveAlertsUseCase(parcelaId);

    result.fold(
          (error) {
        _status = AlertStatus.error;
        _errorMessage = error;
        _activeAlerts = [];
        notifyListeners();
      },
          (alerts) {
        _status = AlertStatus.success;
        _activeAlerts = alerts;
        _errorMessage = '';
        _updateUnreadCount(parcelaId);
        notifyListeners();
      },
    );
  }

  /// Obtiene el historial de alertas (todas, sin filtro)
  Future<void> fetchAlertsHistory({
    required String parcelaId,
    int limit = 50,
  }) async {
    _currentFilter = DateFilter.all;
    _selectedDate = null;
    _startDate = null;
    _endDate = null;

    _status = AlertStatus.loading;
    notifyListeners();

    final result = await getAlertsHistoryUseCase(
      parcelaId: parcelaId,
      limit: limit,
    );

    _handleHistoryResult(result);
  }

  /// Obtiene las alertas de hoy
  Future<void> fetchTodayAlerts(String parcelaId) async {
    _currentFilter = DateFilter.today;
    _selectedDate = DateTime.now();
    _startDate = null;
    _endDate = null;

    _status = AlertStatus.loading;
    notifyListeners();

    final result = await getAlertsHistoryUseCase.fetchToday(parcelaId);
    _handleHistoryResult(result);
  }

  /// Obtiene las alertas de la última semana
  Future<void> fetchLastWeekAlerts(String parcelaId) async {
    _currentFilter = DateFilter.week;
    _selectedDate = null;
    _startDate = DateTime.now().subtract(const Duration(days: 7));
    _endDate = DateTime.now();

    _status = AlertStatus.loading;
    notifyListeners();

    final result = await getAlertsHistoryUseCase.fetchLastWeek(parcelaId);
    _handleHistoryResult(result);
  }

  /// Obtiene las alertas del último mes
  Future<void> fetchLastMonthAlerts(String parcelaId) async {
    _currentFilter = DateFilter.month;
    _selectedDate = null;
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month - 1, now.day);
    _endDate = now;

    _status = AlertStatus.loading;
    notifyListeners();

    final result = await getAlertsHistoryUseCase.fetchLastMonth(parcelaId);
    _handleHistoryResult(result);
  }

  /// Obtiene alertas de un día específico (desde el calendario)
  Future<void> fetchAlertsByDate({
    required String parcelaId,
    required DateTime date,
  }) async {
    _currentFilter = DateFilter.custom;
    _selectedDate = date;
    _startDate = date;
    _endDate = date;

    _status = AlertStatus.loading;
    notifyListeners();

    final result = await getAlertsHistoryUseCase.fetchByDate(
      parcelaId: parcelaId,
      date: date,
    );

    _handleHistoryResult(result);
  }

  /// Obtiene alertas por rango de fechas personalizado
  Future<void> fetchAlertsByDateRange({
    required String parcelaId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _currentFilter = DateFilter.custom;
    _selectedDate = null;
    _startDate = startDate;
    _endDate = endDate;

    _status = AlertStatus.loading;
    notifyListeners();

    final result = await getAlertsHistoryUseCase.fetchByDateRange(
      parcelaId: parcelaId,
      startDate: startDate,
      endDate: endDate,
    );

    _handleHistoryResult(result);
  }

  /// Maneja el resultado del historial
  void _handleHistoryResult(Either<String, List<Alert>> result) {
    result.fold(
          (error) {
        _status = AlertStatus.error;
        _errorMessage = error as String;
        _alertsHistory = [];
        notifyListeners();
      },
          (alerts) {
        _status = AlertStatus.success;
        _alertsHistory = alerts as List<Alert>;
        _errorMessage = '';
        _groupedByDate = getAlertsHistoryUseCase.groupByDate(alerts as List<Alert>);
        notifyListeners();
      },
    );
  }

  /// Actualiza el conteo de alertas sin leer
  Future<void> _updateUnreadCount(String parcelaId) async {
    final result = await getActiveAlertsUseCase.getCount(parcelaId);

    result.fold(
          (error) {
        _unreadCount = 0;
      },
          (count) {
        _unreadCount = count;
      },
    );

    notifyListeners();
  }

  /// Marca una alerta como leída
  Future<void> markAsRead(String alertId, String parcelaId) async {
    final result = await markAlertAsReadUseCase(alertId);

    result.fold(
          (error) {
        _errorMessage = error;
        notifyListeners();
      },
          (_) {
        final index = _activeAlerts.indexWhere((a) => a.id == alertId);
        if (index != -1) {
          _activeAlerts[index] = _activeAlerts[index].copyWith(vista: true);
        }
        _updateUnreadCount(parcelaId);
        notifyListeners();
      },
    );
  }

  /// Marca todas las alertas como leídas
  Future<void> markAllAsRead(String parcelaId) async {
    final result = await markAlertAsReadUseCase.markAll(parcelaId);

    result.fold(
          (error) {
        _errorMessage = error;
        notifyListeners();
      },
          (_) {
        _activeAlerts = _activeAlerts
            .map((alert) => alert.copyWith(vista: true))
            .toList();
        _unreadCount = 0;
        notifyListeners();
      },
    );
  }

  /// Crea una alerta manual
  Future<bool> createManualAlert(Alert alert) async {
    _status = AlertStatus.loading;
    notifyListeners();

    final result = await createAlertUseCase(alert);

    return result.fold(
          (error) {
        _status = AlertStatus.error;
        _errorMessage = error;
        notifyListeners();
        return false;
      },
          (createdAlert) {
        _status = AlertStatus.success;
        if (!createdAlert.vista) {
          _activeAlerts.insert(0, createdAlert);
          _unreadCount++;
        }
        notifyListeners();
        return true;
      },
    );
  }

  /// Elimina una alerta
  Future<bool> deleteAlert(String alertId, String parcelaId) async {
    final result = await createAlertUseCase.deleteAlert(alertId);

    return result.fold(
          (error) {
        _errorMessage = error;
        notifyListeners();
        return false;
      },
          (_) {
        _activeAlerts.removeWhere((a) => a.id == alertId);
        _alertsHistory.removeWhere((a) => a.id == alertId);
        _updateUnreadCount(parcelaId);
        notifyListeners();
        return true;
      },
    );
  }

  /// Filtra alertas por tipo
  Future<void> fetchAlertsByType({
    required String parcelaId,
    required String tipoAlerta,
  }) async {
    _status = AlertStatus.loading;
    notifyListeners();

    final result = await getAlertsHistoryUseCase.getByType(
      parcelaId: parcelaId,
      tipoAlerta: tipoAlerta,
    );

    result.fold(
          (error) {
        _status = AlertStatus.error;
        _errorMessage = error;
        notifyListeners();
      },
          (alerts) {
        _status = AlertStatus.success;
        _alertsHistory = alerts;
        _groupedByDate = getAlertsHistoryUseCase.groupByDate(alerts);
        notifyListeners();
      },
    );
  }

  /// Refresca las alertas activas
  Future<void> refreshActiveAlerts(String parcelaId) async {
    await fetchActiveAlerts(parcelaId);
  }

  /// Refresca el historial según el filtro actual
  Future<void> refreshHistory(String parcelaId) async {
    switch (_currentFilter) {
      case DateFilter.all:
        await fetchAlertsHistory(parcelaId: parcelaId);
        break;
      case DateFilter.today:
        await fetchTodayAlerts(parcelaId);
        break;
      case DateFilter.week:
        await fetchLastWeekAlerts(parcelaId);
        break;
      case DateFilter.month:
        await fetchLastMonthAlerts(parcelaId);
        break;
      case DateFilter.custom:
        if (_selectedDate != null) {
          await fetchAlertsByDate(parcelaId: parcelaId, date: _selectedDate!);
        } else if (_startDate != null && _endDate != null) {
          await fetchAlertsByDateRange(
            parcelaId: parcelaId,
            startDate: _startDate!,
            endDate: _endDate!,
          );
        }
        break;
    }
  }

  /// Obtiene la descripción del filtro actual
  String _getFilterDescription() {
    switch (_currentFilter) {
      case DateFilter.all:
        return 'Todas las alertas';
      case DateFilter.today:
        return 'Hoy';
      case DateFilter.week:
        return 'Última semana';
      case DateFilter.month:
        return 'Último mes';
      case DateFilter.custom:
        if (_selectedDate != null) {
          return '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
        } else if (_startDate != null && _endDate != null) {
          return '${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}';
        }
        return 'Personalizado';
    }
  }

  /// Limpia los filtros de fecha
  void clearFilters() {
    _currentFilter = DateFilter.all;
    _selectedDate = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  /// Limpia el estado de error
  void clearError() {
    _status = AlertStatus.initial;
    _errorMessage = '';
    notifyListeners();
  }

  /// Limpia las alertas de la última evaluación
  void clearLastEvaluation() {
    _lastEvaluationAlerts = [];
    notifyListeners();
  }

  /// Limpia todo el estado del provider
  void clear() {
    _status = AlertStatus.initial;
    _errorMessage = '';
    _activeAlerts = [];
    _unreadCount = 0;
    _alertsHistory = [];
    _groupedByDate = {};
    _isEvaluating = false;
    _lastEvaluationAlerts = [];
    _currentFilter = DateFilter.all;
    _selectedDate = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  /// Obtiene estadísticas de alertas por tipo
  Map<String, int> getAlertStatistics() {
    return getAlertsHistoryUseCase.groupByType(_alertsHistory);
  }

  /// Obtiene estadísticas por mes
  Map<String, int> getMonthlyStatistics() {
    return getAlertsHistoryUseCase.groupByMonth(_alertsHistory);
  }
}