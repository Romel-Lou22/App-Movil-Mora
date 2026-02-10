import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../alerts/presentation/screens/alerts_screen.dart';
import '../../../parcelas/presentation/providers/parcela_provider.dart';
import '../../../parcelas/presentation/screens/parcelas_list_screen.dart';
import '../../../predictions/presentation/screens/predictions_screen.dart';

import '../../../statistics/presentation/pages/statistics_page.dart';
import '../widgets/home_drawer.dart';
import 'home_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;

  // Títulos por tab
  final List<String> _titles = const [
    '',
    'Datos Actuales',
    'Alertas',
    'Parcelas',
    'Gráfico',
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
      const StatisticsPage(), // ← NUEVO
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ParcelaProvider>().fetchParcelas();
    });
  }

  void _onTabRequested(int i) {
    setState(() => _selectedIndex = i);
  }

  /// Construye los íconos de acción según el tab activo
  List<Widget> _buildActionIcons(BuildContext context) {
    switch (_selectedIndex) {
      case 0: // Home
        return [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            tooltip: 'Ver alertas',
            onPressed: () => setState(() => _selectedIndex = 2),
          ),
        ];

      case 1: // Predicciones
        return [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            tooltip: 'Información',
            onPressed: () => _showPredictionsInfoDialog(context),
          ),

        ];

      case 2: // Alertas
        return [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.white),
            tooltip: 'Estás viendo alertas',
            onPressed: () {
              // Ya estás en alertas, podrías mostrar un mensaje o refrescar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ya estás en la sección de alertas'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ];

      case 3: // Parcelas
        return [


        ];

      case 4: // Gráfico
        return [
          IconButton(
            icon: const Icon(Icons.date_range, color: Colors.white),
            tooltip: 'Filtrar fechas',
            onPressed: () {
              // TODO: Mostrar selector de fechas para el gráfico
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
            _buildParcelaActionChip(context), // chip solo en Home
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
            label: 'Grafico',
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

              // ✅ MEJORA: si está en initial, lo tratamos como "cargando"
              if (status == ParcelaStatus.initial || parcelaProvider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // ✅ MEJORA: si hubo error, muestro error + reintentar
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

              // ✅ MEJORA: estado loaded pero sin parcelas
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
