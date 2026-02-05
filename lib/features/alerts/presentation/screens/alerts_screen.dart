import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/supabase_config.dart';
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
  bool _isLoadingParcela = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
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
