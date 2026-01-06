import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../weather/presentation/providers/weather_provider.dart';
import '../../domain/entities/alert.dart';
import '../providers/alert_provider.dart';
import '../widgets/alert_card.dart';
import '../widgets/alert_detail_widget.dart';

/// Pantalla principal de Alertas
///
/// Contiene dos tabs:
/// - ACTIVAS: Alertas agrupadas por severidad
/// - HISTORIAL: Alertas con filtros por fecha
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String? _parcelaId; // Variable que se inicializa después
  bool _isLoadingParcela = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Cargar parcela y alertas al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Inicializa la parcela activa y carga los datos
  Future<void> _initializeData() async {
    setState(() {
      _isLoadingParcela = true;
    });

    try {
      // Obtener el usuario autenticado
      final user = SupabaseConfig.instance.currentUser;
      print('🔍 DEBUG: User ID: ${user?.id}');

      if (user == null) {
        print('❌ DEBUG: Usuario no autenticado');
        setState(() {
          _isLoadingParcela = false;
        });
        return;
      }

      // OPCIÓN A: Usar directamente el user.id
      //_parcelaId = user.id;
      print('🔍 DEBUG: Parcela ID usado: $_parcelaId');

      // OPCIÓN B: Consultar la parcela activa del usuario
      // Descomentar la siguiente línea si usas Opción B:
      _parcelaId = await _obtenerParcelaActiva(user.id);

      if (_parcelaId != null) {
        await _loadInitialData();
      }
    } catch (e) {
      print('❌ DEBUG: Error en initializeData: $e');
      debugPrint('Error al inicializar datos: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingParcela = false;
        });
      }
    }
  }

  /// Obtiene la parcela activa del usuario desde la base de datos
  /// SOLO USAR SI ELIGES OPCIÓN B
  Future<String?> _obtenerParcelaActiva(String userId) async {
    try {
      print('🔍 DEBUG: Buscando parcela para usuario: $userId');

      // Query simple
      final data = await SupabaseConfig.instance.client
          .from('parcelas')
          .select('id')
          .eq('usuario_id', userId)
          .eq('activa', true)
          .limit(1)
          .single(); // ← Cambiado a .single() - devuelve UN mapa

      print('🔍 DEBUG: Data recibida: $data');

      // Extraer el id (es un mapa)
      final parcelaId = data['id'] as String;

      print('✅ DEBUG: Parcela encontrada: $parcelaId');
      return parcelaId;

    } catch (e) {
      print('❌ DEBUG: Error al buscar parcela: $e');
      return null;
    }
  }

  /// Carga los datos iniciales
  Future<void> _loadInitialData() async {
    if (_parcelaId == null) return;

    final provider = context.read<AlertProvider>();
    await provider.fetchActiveAlerts(_parcelaId!);
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading mientras carga la parcela
    if (_isLoadingParcela) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Si no hay parcela, mostrar estado
    if (_parcelaId == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: _buildNoParcelaState(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// AppBar personalizado
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF6A1B9A), // Morado
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Alertas',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        // Botón de refrescar
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _refreshCurrentTab,
        ),
      ],
    );
  }

  /// TabBar
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF6A1B9A),
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        indicatorColor: const Color(0xFF6A1B9A),
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'ACTIVAS'),
          Tab(text: 'HISTORIAL'),
        ],
      ),
    );
  }

  /// Tab de Alertas Activas
  Widget _buildActiveTab() {
    return Consumer<AlertProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.hasError) {
          return _buildErrorState(provider.errorMessage);
        }

        if (!provider.hasActiveAlerts) {
          return _buildEmptyActiveState();
        }

        return RefreshIndicator(
          onRefresh: () => provider.refreshActiveAlerts(_parcelaId!),
          child: _buildActiveAlertsList(provider),
        );
      },
    );
  }

  /// Lista de alertas activas agrupadas por severidad
  Widget _buildActiveAlertsList(AlertProvider provider) {
    // Agrupar alertas por severidad
    final critical = provider.activeAlerts
        .where((a) => a.severidad?.toLowerCase() == 'critica')
        .toList();
    final preventive = provider.activeAlerts
        .where((a) =>
    a.severidad?.toLowerCase() == 'alta' ||
        a.severidad?.toLowerCase() == 'preventiva')
        .toList();
    final others = provider.activeAlerts
        .where((a) =>
    a.severidad?.toLowerCase() != 'critica' &&
        a.severidad?.toLowerCase() != 'alta' &&
        a.severidad?.toLowerCase() != 'preventiva')
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // Alertas Críticas
        if (critical.isNotEmpty) ...[
          _buildSeveritySection(
            title: 'Alertas Críticas',
            icon: Icons.error,
            color: const Color(0xFFDC2626),
            count: critical.length,
            alerts: critical,
          ),
          const SizedBox(height: 16),
        ],

        // Alertas Preventivas
        if (preventive.isNotEmpty) ...[
          _buildSeveritySection(
            title: 'Alertas Preventivas',
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFF59E0B),
            count: preventive.length,
            alerts: preventive,
          ),
          const SizedBox(height: 16),
        ],

        // Otras alertas
        if (others.isNotEmpty) ...[
          _buildSeveritySection(
            title: 'Otras Alertas',
            icon: Icons.info_outline,
            color: const Color(0xFF3B82F6),
            count: others.length,
            alerts: others,
          ),
        ],
      ],
    );
  }

  /// Sección de alertas por severidad
  Widget _buildSeveritySection({
    required String title,
    required IconData icon,
    required Color color,
    required int count,
    required List<Alert> alerts,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de la sección
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Lista de cards
        ...alerts.map((alert) => _buildAlertCard(alert)),
      ],
    );
  }

  /// Card de alerta individual
  Widget _buildAlertCard(Alert alert) {
    return AlertCard(
      alert: alert,
      onTap: () => _showAlertDetail(alert),
      onMarkAsRead: () => _markAlertAsRead(alert),
      // TODO: Conectar con WeatherProvider para temp/humidity reales
      temperature: context.watch<WeatherProvider>().weather?.temperature,
      humidity: context.watch<WeatherProvider>().weather?.humidity,
    );
  }

  /// Tab de Historial
  Widget _buildHistoryTab() {
    return Consumer<AlertProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Barra de filtros
            _buildFilterBar(provider),

            // Lista de alertas filtradas
            Expanded(
              child: _buildHistoryList(provider),
            ),
          ],
        );
      },
    );
  }

  /// Barra de filtros de fecha
  Widget _buildFilterBar(AlertProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botones de filtros rápidos
          Row(
            children: [
              _buildFilterChip(
                label: 'Hoy',
                isSelected: provider.currentFilter == DateFilter.today,
                onTap: () => _applyFilter(DateFilter.today),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Semana',
                isSelected: provider.currentFilter == DateFilter.week,
                onTap: () => _applyFilter(DateFilter.week),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Mes',
                isSelected: provider.currentFilter == DateFilter.month,
                onTap: () => _applyFilter(DateFilter.month),
              ),
              const SizedBox(width: 8),
              // Botón de calendario
              _buildCalendarButton(provider),
            ],
          ),

          // Indicador de filtro activo
          if (provider.currentFilter != DateFilter.all) ...[
            const SizedBox(height: 12),
            _buildActiveFilterIndicator(provider),
          ],
        ],
      ),
    );
  }

  /// Chip de filtro
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6A1B9A)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  /// Botón de calendario
  Widget _buildCalendarButton(AlertProvider provider) {
    return InkWell(
      onTap: () => _showCalendarPicker(provider),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: provider.currentFilter == DateFilter.custom
              ? const Color(0xFF6A1B9A)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.calendar_today,
          size: 16,
          color: provider.currentFilter == DateFilter.custom
              ? Colors.white
              : Colors.grey[700],
        ),
      ),
    );
  }

  /// Indicador de filtro activo
  Widget _buildActiveFilterIndicator(AlertProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_alt,
            size: 16,
            color: Colors.blue[700],
          ),
          const SizedBox(width: 6),
          Text(
            'Filtrado por: ${provider.filterDescription}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => _clearFilters(),
            child: Icon(
              Icons.close,
              size: 16,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  /// Lista de historial
  Widget _buildHistoryList(AlertProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hasError) {
      return _buildErrorState(provider.errorMessage);
    }

    if (!provider.hasHistory) {
      return _buildEmptyHistoryState();
    }

    return RefreshIndicator(
      onRefresh: () => provider.refreshHistory(_parcelaId!),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: provider.groupedByDate.length,
        itemBuilder: (context, index) {
          final date = provider.groupedByDate.keys.elementAt(index);
          final alerts = provider.groupedByDate[date]!;

          return _buildDateGroup(date, alerts);
        },
      ),
    );
  }

  /// Grupo de alertas por fecha
  Widget _buildDateGroup(String date, List<Alert> alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de fecha
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            date,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Lista de alertas
        ...alerts.map((alert) => _buildAlertCard(alert)),

        const SizedBox(height: 8),
      ],
    );
  }

  /// Estado cuando no hay parcela asociada
  Widget _buildNoParcelaState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin parcela activa',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No se encontró una parcela asociada a tu cuenta.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
              ),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado vacío - Alertas Activas
  Widget _buildEmptyActiveState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Colors.green[400],
              ),
            ),
            const SizedBox(height: 24),

            // Título
            const Text(
              'Estado Normal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Descripción
            Text(
              'Todo en orden ✓',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'No hay alertas activas en este momento.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Estado vacío - Historial
  Widget _buildEmptyHistoryState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin historial',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay alertas para el período seleccionado.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Estado de error
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshCurrentTab,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  // ========== MÉTODOS DE ACCIÓN ==========

  /// Muestra el detalle de una alerta
  void _showAlertDetail(Alert alert) {
    AlertDetailWidget.show(
      context: context,
      alert: alert,
      onMarkAsRead: () => _markAlertAsRead(alert),
      onDelete: () => _deleteAlert(alert),
    );
  }

  /// Marca una alerta como leída
  Future<void> _markAlertAsRead(Alert alert) async {
    if (_parcelaId == null) return;

    final provider = context.read<AlertProvider>();
    await provider.markAsRead(alert.id, _parcelaId!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alerta marcada como vista'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Elimina una alerta
  Future<void> _deleteAlert(Alert alert) async {
    if (_parcelaId == null) return;

    final provider = context.read<AlertProvider>();
    final success = await provider.deleteAlert(alert.id, _parcelaId!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Alerta eliminada' : 'Error al eliminar alerta',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// Aplica un filtro de fecha
  Future<void> _applyFilter(DateFilter filter) async {
    if (_parcelaId == null) return;

    final provider = context.read<AlertProvider>();

    switch (filter) {
      case DateFilter.today:
        await provider.fetchTodayAlerts(_parcelaId!);
        break;
      case DateFilter.week:
        await provider.fetchLastWeekAlerts(_parcelaId!);
        break;
      case DateFilter.month:
        await provider.fetchLastMonthAlerts(_parcelaId!);
        break;
      default:
        await provider.fetchAlertsHistory(parcelaId: _parcelaId!);
    }
  }

  /// Muestra el selector de calendario
  Future<void> _showCalendarPicker(AlertProvider provider) async {
    if (_parcelaId == null) return;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6A1B9A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null && mounted) {
      await provider.fetchAlertsByDate(
        parcelaId: _parcelaId!,
        date: selectedDate,
      );
    }
  }

  /// Limpia los filtros
  Future<void> _clearFilters() async {
    if (_parcelaId == null) return;

    final provider = context.read<AlertProvider>();
    provider.clearFilters();
    await provider.fetchAlertsHistory(parcelaId: _parcelaId!);
  }

  /// Refresca el tab actual
  Future<void> _refreshCurrentTab() async {
    if (_parcelaId == null) return;

    final provider = context.read<AlertProvider>();

    if (_tabController.index == 0) {
      // Tab Activas
      await provider.refreshActiveAlerts(_parcelaId!);
    } else {
      // Tab Historial
      await provider.refreshHistory(_parcelaId!);
    }
  }
}