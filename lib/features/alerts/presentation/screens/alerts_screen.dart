import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../parcelas/presentation/providers/parcela_provider.dart';
import '../../../weather/presentation/providers/weather_provider.dart';
import '../../domain/entities/alert.dart';
import '../providers/alert_provider.dart';
import '../widgets/alert_card.dart';
import '../widgets/alert_detail_widget.dart';

part 'alerts_screen.controller.dart';
part 'alerts_screen.active_tab.dart';
part 'alerts_screen.history_tab.dart';
part 'alerts_screen.states.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String? _parcelaId;
  String? _lastParcelaId; // ✅ NUEVO: Detectar cambios de parcela
  bool _isLoadingParcela = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // ✅ NUEVO: Escuchar cambios de tab
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  // ✅ NUEVO: Cargar datos cuando cambia el tab
  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _loadCurrentTabData();
    }
  }

  // ✅ NUEVO: Cargar datos del tab actual
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

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged); // ✅ NUEVO
    _tabController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    // ✅ NUEVO: Detectar cambio de parcela
    final currentParcelaId = context.select<ParcelaProvider, String?>(
          (provider) => provider.parcelaSeleccionada?.id,
    );

    // ✅ NUEVO: Si cambió la parcela, recargar datos
    if (currentParcelaId != _lastParcelaId && currentParcelaId != null) {
      debugPrint('🔄 Parcela cambió de $_lastParcelaId a $currentParcelaId');
      _lastParcelaId = currentParcelaId;
      _parcelaId = currentParcelaId;

      // Recargar datos del tab actual
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadCurrentTabData();
        }
      });
    }

    if (_isLoadingParcela) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_parcelaId == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: _buildNoParcelaState(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
}