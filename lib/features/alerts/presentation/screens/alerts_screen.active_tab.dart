part of 'alerts_screen.dart';

extension _AlertsScreenActiveTab on _AlertsScreenState {
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

        final parcelaId = _parcelaId;
        if (parcelaId == null) {
          return _buildNoParcelaState();
        }

        return RefreshIndicator(
          onRefresh: () => provider.refreshActiveAlerts(parcelaId),
          child: _buildActiveAlertsList(provider),
        );
      },
    );
  }

  Widget _buildActiveAlertsList(AlertProvider provider) {
    String sev(Alert a) => _sevKey(a.severidad);

    final critical = provider.activeAlerts.where((a) => sev(a) == 'critica').toList();
    final high = provider.activeAlerts.where((a) => sev(a) == 'alta').toList();

    final others = provider.activeAlerts.where((a) {
      final s = sev(a);
      return s != 'critica' && s != 'alta';
    }).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
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
        if (high.isNotEmpty) ...[
          _buildSeveritySection(
            title: 'Alertas Altas',
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFF59E0B),
            count: high.length,
            alerts: high,
          ),
          const SizedBox(height: 16),
        ],
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
        ...alerts.map(_buildAlertCard),
      ],
    );
  }

  Widget _buildAlertCard(Alert alert) {
    final weather = context.watch<WeatherProvider>().weather;

    return AlertCard(
      alert: alert,
      onTap: () => _showAlertDetail(alert),
      onMarkAsRead: () => _markAlertAsRead(alert),
      temperature: weather?.temperature,
      humidity: weather?.humidity,
    );
  }

  /// Convierte severidad (String / enum / Object) a un key normalizado.
  String _sevKey(Object? value) {
    if (value == null) return '';

    // Si es String directo
    if (value is String) return value.toLowerCase();

    // Si es enum (AlertSeverity.critica, etc.) o cualquier otro Object:
    final raw = value.toString(); // ej: "AlertSeverity.critica"
    final last = raw.contains('.') ? raw.split('.').last : raw;
    return last.toLowerCase();
  }
}
