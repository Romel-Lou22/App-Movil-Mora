import 'package:flutter/foundation.dart';
import '../../services/statistics_service.dart';

/// Provider de estadísticas usando ChangeNotifier
class StatisticsProvider extends ChangeNotifier {
  final StatisticsService _service;

  StatisticsProvider({required StatisticsService service}) : _service = service;

  // === Estado ===
  bool _isLoading = false;
  Map<String, Map<String, double>> _weeklyData = {}; // ✅ double para porcentajes
  Map<String, dynamic> _summary = {};
  String? _error;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // === Getters ===
  bool get isLoading => _isLoading;
  Map<String, Map<String, double>> get weeklyData => _weeklyData; // ✅ double
  Map<String, dynamic> get summary => _summary;
  String? get error => _error;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;
  bool get hasError => _error != null;
  bool get hasData => _weeklyData.isNotEmpty;

  /// Cargar datos del mes seleccionado
  Future<void> loadMonthData(String parcelaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getAlertsByWeekAndParameter( // ✅ Cambio de método
          parcelaId: parcelaId,
          year: _selectedYear,
          month: _selectedMonth,
        ),
        _service.getMonthSummary(
          parcelaId: parcelaId,
          year: _selectedYear,
          month: _selectedMonth,
        ),
      ]);

      _weeklyData = results[0] as Map<String, Map<String, double>>;
      _summary = results[1] as Map<String, dynamic>;
      _isLoading = false;
      _error = null;

      notifyListeners();
      debugPrint('📊 Datos cargados - Total alertas: ${_summary['total']}');
    } catch (e) {
      _isLoading = false;
      _error = 'Error al cargar datos: ${e.toString()}';
      notifyListeners();
      debugPrint('❌ Error: $e');
    }
  }

  /// Cambiar mes seleccionado
  void changeMonth(int month) {
    if (_selectedMonth != month) {
      _selectedMonth = month;
      notifyListeners();
    }
  }

  /// Cambiar año
  void changeYear(int year) {
    if (_selectedYear != year) {
      _selectedYear = year;
      notifyListeners();
    }
  }

  /// Refrescar datos
  Future<void> refresh(String parcelaId) async {
    await loadMonthData(parcelaId);
  }

  /// Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset
  void reset() {
    _isLoading = false;
    _weeklyData = {};
    _summary = {};
    _error = null;
    _selectedMonth = DateTime.now().month;
    _selectedYear = DateTime.now().year;
    notifyListeners();
  }
}