import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';

import '../../../alerts/domain/entities/alert.dart';
import '../../../alerts/presentation/providers/alert_provider.dart';
import '../../../alerts/presentation/screens/alerts_screen.dart';
import '../../../parcelas/presentation/providers/parcela_provider.dart';
import '../../../parcelas/presentation/screens/parcelas_list_screen.dart';
import '../../../predictions/presentation/screens/predictions_screen.dart';
import '../../../statistics/presentation/pages/statistics_page.dart';
import '../widgets/badged_icon.dart';
import '../widgets/home_drawer.dart';
import 'home_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = const [
    '',
    'Datos Actuales',
    'Alertas',
    'Parcelas',
    'Estadisticas',
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      HomeScreen(onTabRequested: _onTabRequested),
      const PredictionsScreen(),
      const AlertsScreen(),
      const ParcelasListScreen(),
      const StatisticsPage(),
    ];

   /* WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final parcelaProvider = context.read<ParcelaProvider>();
      final alertProvider = context.read<AlertProvider>();

      debugPrint('📊 [SHELL] Cargando datos iniciales...');

      parcelaProvider.fetchParcelas().then((_) {
        if (!mounted) return;

        final parcela = parcelaProvider.parcelaSeleccionada;
        if (parcela != null) {
          debugPrint('🚨 [SHELL] Cargando alertas para: ${parcela.nombreParcela}');
          alertProvider.fetchActiveAlerts(parcela.id);
        } else {
          debugPrint('⚠️ [SHELL] No hay parcela seleccionada');
        }
      });
    });*/
  }

  void _onTabRequested(int i) {
    setState(() => _selectedIndex = i);
  }

  List<Widget> _buildActionIcons(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return [
          Consumer<AlertProvider>(
            builder: (context, alertProvider, _) {
              return BadgedIcon(
                icon: Icons.notifications_outlined,
                count: alertProvider.unreadCount,
                tooltip: alertProvider.unreadCount > 0
                    ? '${alertProvider.unreadCount} alerta${alertProvider.unreadCount > 1 ? 's' : ''} activa${alertProvider.unreadCount > 1 ? 's' : ''}'
                    : 'Ver alertas',
                onPressed: () => _showAlertsPreviewDialog(context),
              );
            },
          ),
        ];

      case 1:
        return [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            tooltip: 'Información',
            onPressed: () => _showPredictionsInfoDialog(context),
          ),
        ];

      case 2:
        return [

        ];

      case 3:
        return [];

      case 4:
        return [
          IconButton(
            icon: const Icon(Icons.date_range, color: Colors.white),
            tooltip: 'Filtrar fechas',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filtro de fechas próximamente'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ];

      default:
        return [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            tooltip: 'Ver alertas',
            onPressed: () => setState(() => _selectedIndex = 2),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          if (_selectedIndex == 0) ...[
            _buildParcelaActionChip(context),
            const SizedBox(width: 6),
          ],
          ..._buildActionIcons(context),
          const SizedBox(width: 6),
        ],
      ),
      drawer: const HomeDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Datos Actuales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grass_outlined),
            activeIcon: Icon(Icons.grass),
            label: 'Parcela',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights),
            label: 'Estadísticas',
          ),
        ],
      ),
    );
  }

  Widget _buildParcelaActionChip(BuildContext context) {
    return Consumer<ParcelaProvider>(
      builder: (_, parcelaProvider, __) {
        final parcela = parcelaProvider.parcelaSeleccionada;
        final label = parcela?.nombreParcela ?? 'Parcela';

        return InkWell(
          onTap: () => _openParcelaSelectorModal(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.grass, size: 18, color: Colors.white),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openParcelaSelectorModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Consumer<ParcelaProvider>(
            builder: (context, parcelaProvider, __) {
              final status = parcelaProvider.status;
              final parcelas = parcelaProvider.parcelas;
              final selectedId = parcelaProvider.parcelaSeleccionada?.id;

              if (status == ParcelaStatus.initial || parcelaProvider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (status == ParcelaStatus.error) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        parcelaProvider.errorMessage ?? 'Error al cargar parcelas.',
                        style: const TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => parcelaProvider.fetchParcelas(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              if (parcelas.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No tienes parcelas activas.'),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                itemCount: parcelas.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final p = parcelas[i];
                  final isSelected = p.id == selectedId;

                  return ListTile(
                    title: Text(p.nombreParcela),
                    subtitle: Text(p.ubicacionDisplay),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.secondary)
                        : const Icon(Icons.circle_outlined),
                    onTap: () {
                      parcelaProvider.setParcelaSeleccionada(p);
                      Navigator.pop(context);

                      debugPrint('🔄 [SHELL] Recargando alertas para: ${p.nombreParcela}');
                      context.read<AlertProvider>().fetchActiveAlerts(p.id);
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  /// Muestra el diálogo de preview de alertas
  void _showAlertsPreviewDialog(BuildContext context) {
    final alertProvider = context.read<AlertProvider>();
    final parcelaProvider = context.read<ParcelaProvider>();

    final parcela = parcelaProvider.parcelaSeleccionada;

    if (parcela == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una parcela primero'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => Consumer<AlertProvider>(
        builder: (context, provider, _) {
          final alerts = provider.activeAlerts;

          // 🔧 CORRECCIÓN: usar createdAt en lugar de fechaHora
          final criticalAlerts = alerts
              .where((a) => a.severidad == AlertSeverity.critica)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          List<Alert> displayAlerts = [...criticalAlerts];
          if (displayAlerts.length < 5) {
            final nonCritical = alerts
                .where((a) => a.severidad != AlertSeverity.critica)
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            displayAlerts.addAll(
              nonCritical.take(5 - displayAlerts.length),
            );
          }

          displayAlerts = displayAlerts.take(5).toList();

          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.notifications_active, color: AppColors.error, size: 28),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Alertas Activas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (alerts.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${alerts.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: provider.isLoading
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
                  : alerts.isEmpty
                  ? const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: AppColors.success,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '¡Todo en orden!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No tienes alertas activas en este momento.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Todos los parámetros están en rangos normales.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
                  : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (displayAlerts.length < alerts.length)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 16,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Mostrando ${displayAlerts.length} de ${alerts.length} alertas (priorizando críticas)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ...displayAlerts.map(
                          (alert) => _buildAlertPreviewItem(alert),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cerrar'),
              ),
              if (alerts.isNotEmpty)
                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    setState(() => _selectedIndex = 2);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                  ),
                  child: const Text('Ver Todas'),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Widget para cada item de alerta en el preview
  Widget _buildAlertPreviewItem(Alert alert) {
    Color severityColor;
    IconData severityIcon;
    String severityText;

    // 🔧 CORRECCIÓN: Manejar severidad nullable
    switch (alert.severidad) {
      case AlertSeverity.critica:
        severityColor = AppColors.error;
        severityIcon = Icons.error;
        severityText = 'CRÍTICA';
        break;
      case AlertSeverity.alta:
        severityColor = Colors.orange;
        severityIcon = Icons.warning;
        severityText = 'ALTA';
        break;
      case AlertSeverity.media:
        severityColor = Colors.yellow.shade700;
        severityIcon = Icons.info;
        severityText = 'MEDIA';
        break;
      case AlertSeverity.baja:
        severityColor = Colors.blue;
        severityIcon = Icons.info_outline;
        severityText = 'BAJA';
        break;
      case null:
        severityColor = Colors.grey;
        severityIcon = Icons.help_outline;
        severityText = 'DESCONOCIDA';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: severityColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: severityColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Icon(severityIcon, color: severityColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getAlertTypeName(alert.tipoAlerta), // 🔧 CORRECCIÓN: usar helper
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: severityColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: severityColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    severityText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              alert.mensaje,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔧 NUEVO: Helper para obtener nombre legible del tipo de alerta
  String _getAlertTypeName(AlertType tipo) {
    switch (tipo) {
      case AlertType.phBajo:
        return 'pH Muy Ácido';
      case AlertType.phAlto:
        return 'pH Muy Alcalino';
      case AlertType.tempBaja:
        return 'Riesgo de Helada';
      case AlertType.tempAlta:
        return 'Calor Excesivo';
      case AlertType.humBaja:
        return 'Riesgo de Sequía';
      case AlertType.humAlta:
        return 'Exceso de Humedad';
      case AlertType.nBajo:
        return 'Nitrógeno Bajo';
      case AlertType.nAlto:
        return 'Nitrógeno Alto';
      case AlertType.pBajo:
        return 'Fósforo Bajo';
      case AlertType.pAlto:
        return 'Fósforo Alto';
      case AlertType.kBajo:
        return 'Potasio Bajo';
      case AlertType.kAlto:
        return 'Potasio Alto';
    }
  }

  /// Muestra el diálogo de información de predicciones
  void _showPredictionsInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acerca de las Predicciones'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Datos Climáticos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Obtenidos en tiempo real desde OpenWeather API usando las coordenadas de tu parcela.',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                'Predicción de Nutrientes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Generada por un modelo de Inteligencia Artificial entrenado específicamente para cultivos de mora.',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                'Actualización Recomendada',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Se recomienda actualizar los datos cada hora para obtener predicciones más precisas.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}