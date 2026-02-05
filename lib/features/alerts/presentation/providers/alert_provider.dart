import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/alert.dart';
import '../../domain/usecases/evaluate_thresholds_usecase.dart';
import '../../domain/usecases/get_active_alerts_usecase.dart';
import '../../domain/usecases/get_alerts_history_usecase.dart';
import '../../domain/usecases/mark_alert_as_read_usecase.dart';

/// Estados posibles del provider
enum AlertStatus { initial, loading, success, error }

/// Filtros rápidos para el historial
enum DateFilter { all, today, week, month, custom }

class AlertProvider extends ChangeNotifier {
  final EvaluateThresholdsUseCase evaluateThresholdsUseCase;
  final GetActiveAlertsUseCase getActiveAlertsUseCase;
  final GetAlertsHistoryUseCase getAlertsHistoryUseCase;
  final MarkAlertAsReadUseCase markAlertAsReadUseCase;

  AlertProvider({
    required this.evaluateThresholdsUseCase,
    required this.getActiveAlertsUseCase,
    required this.getAlertsHistoryUseCase,
    required this.markAlertAsReadUseCase,
  });

  // Estado general
  AlertStatus _status = AlertStatus.initial;
  String _errorMessage = '';

  // Alertas activas (en este diseño: activas = no leídas y no expiradas)
  List<Alert> _activeAlerts = [];
  int _unreadCount = 0;

  // Historial
  List<Alert> _alertsHistory = [];
  Map<String, List<Alert>> _groupedByDate = {};

  // Filtros
  DateFilter _currentFilter = DateFilter.all;
  DateTime? _selectedDate;
  DateTime? _startDate;
  DateTime? _endDate;

  // Evaluación
  bool _isEvaluating = false;
  List<Alert> _lastEvaluationAlerts = [];

  // Getters
  AlertStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == AlertStatus.loading;
  bool get hasError => _status == AlertStatus.error;

  bool get isEvaluating => _isEvaluating;
  List<Alert> get lastEvaluationAlerts => _lastEvaluationAlerts;
  bool get hasNewAlerts => _lastEvaluationAlerts.isNotEmpty;

  List<Alert> get activeAlerts => _activeAlerts;
  int get unreadCount => _unreadCount;
  bool get hasActiveAlerts => _activeAlerts.isNotEmpty;
  bool get hasUnreadAlerts => _unreadCount > 0;

  List<Alert> get alertsHistory => _alertsHistory;
  Map<String, List<Alert>> get groupedByDate => _groupedByDate;
  bool get hasHistory => _alertsHistory.isNotEmpty;

  DateFilter get currentFilter => _currentFilter;
  DateTime? get selectedDate => _selectedDate;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get filterDescription => _getFilterDescription();

  // ====== EVALUACIÓN (HF + persist) ======
  /// Genera y persiste alertas en base a features
  /// Genera y persiste alertas en base a features
  Future<void> evaluateThresholds({
    required String parcelaId,
    required Map<String, double> features,
  }) async {
    print('🚨 ═══════════════════════════════════');
    print('🚨 EVALUANDO ALERTAS CON RANDOM FOREST');
    print('🚨 ═══════════════════════════════════');
    print('📍 Parcela: $parcelaId');
    print('📊 Features recibidos:');
    features.forEach((key, value) {
      print('   - $key: $value');
    });

    _isEvaluating = true;
    _lastEvaluationAlerts = [];
    notifyListeners();

    print('🔄 Llamando al Random Forest...');
    final result = await evaluateThresholdsUseCase(
      parcelaId: parcelaId,
      features: features,
    );

    print('📦 Respuesta del Random Forest recibida');

    result.fold(
          (error) {
        print('❌ ═══════════════════════════════════');
        print('❌ ERROR AL EVALUAR ALERTAS');
        print('❌ ═══════════════════════════════════');
        print('❌ Error: $error');

        _status = AlertStatus.error;
        _errorMessage = error;
        _isEvaluating = false;
        notifyListeners();
      },
          (alerts) async {
        print('✅ ═══════════════════════════════════');
        print('✅ ALERTAS GENERADAS: ${alerts.length}');
        print('✅ ═══════════════════════════════════');

        if (alerts.isNotEmpty) {
          for (var i = 0; i < alerts.length; i++) {
            print('   ${i + 1}. Tipo: ${alerts[i].tipoAlerta}');
            print('      Severidad: ${alerts[i].severidad}');
            print('      Mensaje: ${alerts[i].mensaje}');
            print('      ---');
          }
        } else {
          print('ℹ️ No se generaron alertas (todos los parámetros están en rangos normales)');
        }

        _lastEvaluationAlerts = alerts;
        _isEvaluating = false;

        // Si hubo nuevas alertas, refresca activas (no leídas) y opcionalmente historial
        if (alerts.isNotEmpty) {
          print('💾 Guardando alertas en Supabase (alertas_historial)...');
          await fetchActiveAlerts(parcelaId);
          print('✅ Alertas guardadas y lista actualizada');
        } else {
          _status = AlertStatus.success;
          _errorMessage = '';
          notifyListeners();
        }

        print('🚨 ═══════════════════════════════════');
        print('🚨 EVALUACIÓN COMPLETADA');
        print('🚨 ═══════════════════════════════════');
      },
    );
  }




  // ====== ACTIVAS ======
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
          (alerts) async {
        _status = AlertStatus.success;
        _activeAlerts = alerts;
        _errorMessage = '';
        await _updateUnreadCount(parcelaId);
        notifyListeners();
      },
    );
  }

  // ====== HISTORIAL ======
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

  Future<void> fetchLastWeekAlerts(String parcelaId) async {
    _currentFilter = DateFilter.week;
    _selectedDate = null;
    _startDate = DateTime.now().subtract(const Duration(days: 6));
    _endDate = DateTime.now();

    _status = AlertStatus.loading;
    notifyListeners();

    final result = await getAlertsHistoryUseCase.fetchLastWeek(parcelaId);
    _handleHistoryResult(result);
  }

  Future<void> fetchLastMonthAlerts(String parcelaId) async {
    _currentFilter = DateFilter.month;
    _selectedDate = null;
    _startDate = DateTime.now().subtract(const Duration(days: 29));
    _endDate = DateTime.now();

    _status = AlertStatus.loading;
    notifyListeners();

    final result = await getAlertsHistoryUseCase.fetchLastMonth(parcelaId);
    _handleHistoryResult(result);
  }

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

  void _handleHistoryResult(Either<String, List<Alert>> result) {
    result.fold(
          (error) {
        _status = AlertStatus.error;
        _errorMessage = error; // ✅ sin casts
        _alertsHistory = [];
        _groupedByDate = {};
        notifyListeners();
      },
          (alerts) {
        _status = AlertStatus.success;
        _alertsHistory = alerts; // ✅ sin casts
        _errorMessage = '';
        _groupedByDate = getAlertsHistoryUseCase.groupByDate(alerts);
        notifyListeners();
      },
    );
  }

  // ====== MARCAR COMO LEÍDAS ======
  Future<void> markAsRead(String alertId, String parcelaId) async {
    final result = await markAlertAsReadUseCase(alertId);

    result.fold(
          (error) {
        _errorMessage = error;
        notifyListeners();
      },
          (_) async {
        // ✅ Como “activas” son no leídas, al marcar como leída se remueve de activas
        _activeAlerts.removeWhere((a) => a.id == alertId);

        await _updateUnreadCount(parcelaId);
        notifyListeners();
      },
    );
  }

  Future<void> markAllAsRead(String parcelaId) async {
    final result = await markAlertAsReadUseCase.markAll(parcelaId);

    result.fold(
          (error) {
        _errorMessage = error;
        notifyListeners();
      },
          (_) {
        // ✅ Limpia activas: ya no hay no leídas
        _activeAlerts = [];
        _unreadCount = 0;
        notifyListeners();
      },
    );
  }

  Future<void> _updateUnreadCount(String parcelaId) async {
    final result = await getActiveAlertsUseCase.getCount(parcelaId);

    result.fold(
          (_) => _unreadCount = 0,
          (count) => _unreadCount = count,
    );
  }

  // ====== FILTRAR POR TIPO (historial) ======
  /// Ahora debe recibir AlertType (no String)
  Future<void> fetchAlertsByType({
    required String parcelaId,
    required AlertType tipoAlerta,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _status = AlertStatus.loading;
    notifyListeners();

    final result = await getAlertsHistoryUseCase.getByType(
      parcelaId: parcelaId,
      tipoAlerta: tipoAlerta,
      startDate: startDate,
      endDate: endDate,
      limit: 200,
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

  // ====== REFRESH ======
  Future<void> refreshActiveAlerts(String parcelaId) async {
    await fetchActiveAlerts(parcelaId);
  }

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

  // ====== HELPERS ======
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

  void clearFilters() {
    _currentFilter = DateFilter.all;
    _selectedDate = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  void clearError() {
    _status = AlertStatus.initial;
    _errorMessage = '';
    notifyListeners();
  }

  void clearLastEvaluation() {
    _lastEvaluationAlerts = [];
    notifyListeners();
  }

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

  /// Estadísticas por tipo para UI (keys string)
  Map<String, int> getAlertStatistics() {
    return getAlertsHistoryUseCase.groupByTypeDbValue(_alertsHistory);
  }

  Map<String, int> getMonthlyStatistics() {
    return getAlertsHistoryUseCase.groupByMonth(_alertsHistory);
  }
}
