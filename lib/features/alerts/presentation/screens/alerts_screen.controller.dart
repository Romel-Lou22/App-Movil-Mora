part of 'alerts_screen.dart';

extension _AlertsScreenActions on _AlertsScreenState {
  Future<void> _initializeData() async {
    setState(() => _isLoadingParcela = true);

    try {
      final user = SupabaseConfig.instance.currentUser;
      if (user == null) {
        setState(() => _parcelaId = null);
        return;
      }

      _parcelaId = await _obtenerParcelaActiva(user.id);
      _lastParcelaId = _parcelaId; // ✅ AGREGAR ESTA LÍNEA

      if (_parcelaId != null) {
        await _loadInitialData();
        _loadCurrentTabData(); // ✅ AGREGAR ESTA LÍNEA (carga historial si estás en ese tab)
      }
    } catch (_) {
      if (mounted) setState(() => _parcelaId = null);
    } finally {
      if (mounted) setState(() => _isLoadingParcela = false);
    }
  }

  Future<String?> _obtenerParcelaActiva(String userId) async {
    try {
      final data = await SupabaseConfig.instance.client
          .from('parcelas')
          .select('id')
          .eq('usuario_id', userId)
          .eq('activa', true)
          .limit(1)
          .single();

      return data['id'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadInitialData() async {
    final parcelaId = _parcelaId;
    if (parcelaId == null) return;

    final provider = context.read<AlertProvider>();
    await provider.fetchActiveAlerts(parcelaId);
  }

  void _showAlertDetail(Alert alert) {
    AlertDetailWidget.show(
      context: context,
      alert: alert,
      onMarkAsRead: () => _markAlertAsRead(alert),
      onDelete: () => _deleteAlert(alert),
    );
  }

  Future<void> _markAlertAsRead(Alert alert) async {
    final parcelaId = _parcelaId;
    if (parcelaId == null) return;

    final provider = context.read<AlertProvider>();
    await provider.markAsRead(alert.id, parcelaId);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alerta marcada como vista')),
    );
  }

  Future<void> _deleteAlert(Alert alert) async {
    final parcelaId = _parcelaId;
    if (parcelaId == null) return;

    final provider = context.read<AlertProvider>();


    if (!mounted) return;


  }

  Future<void> _applyFilter(DateFilter filter) async {
    final parcelaId = _parcelaId;
    if (parcelaId == null) return;

    final provider = context.read<AlertProvider>();

    switch (filter) {
      case DateFilter.today:
        await provider.fetchTodayAlerts(parcelaId);
        break;
      case DateFilter.week:
        await provider.fetchLastWeekAlerts(parcelaId);
        break;
      case DateFilter.month:
        await provider.fetchLastMonthAlerts(parcelaId);
        break;
      default:
        await provider.fetchAlertsHistory(parcelaId: parcelaId);
    }
  }

  Future<void> _showCalendarPicker(AlertProvider provider) async {
    final parcelaId = _parcelaId;
    if (parcelaId == null) return;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF6A1B9A)),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null && mounted) {
      await provider.fetchAlertsByDate(
        parcelaId: parcelaId,
        date: selectedDate,
      );
    }
  }

  Future<void> _clearFilters() async {
    final parcelaId = _parcelaId;
    if (parcelaId == null) return;

    final provider = context.read<AlertProvider>();
    provider.clearFilters();
    await provider.fetchAlertsHistory(parcelaId: parcelaId);
  }

  Future<void> _refreshCurrentTab() async {
    final parcelaId = _parcelaId;
    if (parcelaId == null) return;

    final provider = context.read<AlertProvider>();

    if (_tabController.index == 0) {
      await provider.refreshActiveAlerts(parcelaId);
    } else {
      await provider.refreshHistory(parcelaId);
    }
  }

  // ✅ AGREGAR TODO ESTE MÉTODO AL FINAL DEL EXTENSION
  void _loadCurrentTabData() {
    final parcelaId = _parcelaId;
    if (parcelaId == null) return;

    final provider = context.read<AlertProvider>();

    debugPrint('📊 Cargando datos del tab: ${_tabController.index}');

    if (_tabController.index == 0) {
      // Tab Activas
      provider.fetchActiveAlerts(parcelaId);
    } else if (_tabController.index == 1) {
      // Tab Historial
      provider.fetchAlertsHistory(parcelaId: parcelaId);
    }
  }
}
