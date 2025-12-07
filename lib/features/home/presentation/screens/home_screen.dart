import 'package:flutter/material.dart';

import '../../../../core/config/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/home_drawer.dart';

/// Pantalla principal (Home/Dashboard) de EcoMora
/// Muestra resumen del clima, alertas y estado de la parcela seleccionada
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Índice del bottom navigation bar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // AppBar personalizado
      appBar: _buildAppBar(),

      drawer: const HomeDrawer(),

      // Cuerpo principalf
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información de la parcela
              _buildParcelaInfo(),

              const SizedBox(height: 16),

              // Card: Current Weather
              _buildCurrentWeatherCard(),

              const SizedBox(height: 16),

              // Card: Active Alerts
              _buildActiveAlertsCard(),

              const SizedBox(height: 16),

              // Card: Quick Summary
              _buildQuickSummaryCard(),

              const SizedBox(height: 24),

              // Botón: Ver predicciones detalladas
              _buildPredictionsButton(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// AppBar personalizado con menú, logo, dropdown y notificaciones
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.secondary,
      elevation: 0,
      leading: Builder(  // ✅ AGREGAR BUILDER AQUÍ
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      title: const Text(
        'EcoMora',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        // Dropdown de parcelas
        _buildParcelasDropdown(),

        // Icono de notificaciones
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.alerts);
          },
        ),
      ],
    );
  }

  /// Dropdown para seleccionar parcela
  Widget _buildParcelasDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: 'Parcela Norte',
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        underline: const SizedBox(),
        dropdownColor: AppColors.secondary,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        items: const [
          DropdownMenuItem(
            value: 'Parcela Norte',
            child: Text('Parcela Norte'),
          ),
          DropdownMenuItem(
            value: 'Parcela Sur',
            child: Text('Parcela Sur'),
          ),
          DropdownMenuItem(
            value: 'Parcela Este',
            child: Text('Parcela Este'),
          ),
        ],
        onChanged: (value) {
          // TODO: Cambiar parcela seleccionada
          setState(() {});
        },
      ),
    );
  }

  /// Widget de información de la parcela
  Widget _buildParcelaInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.location_on,
              color: Colors.red,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'Parcela Norte',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Padding(
          padding: EdgeInsets.only(left: 36),
          child: Text(
            'Tisaleo, Tungurahua',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 36),
          child: Text(
            'Última actualización: ${TimeOfDay.now().format(context)}',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  /// Card de clima actual
  Widget _buildCurrentWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CURRENT WEATHER',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Icono de clima
              Icon(
                Icons.wb_cloudy_outlined,
                size: 64,
                color: AppColors.textSecondary.withOpacity(0.6),
              ),
              const SizedBox(width: 16),

              // Descripción del clima
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Partially',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'cloudy',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Humedad: 75%',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Temperatura
              const Text(
                '18.5°C',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Card de alertas activas
  Widget _buildActiveAlertsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.shade400,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'ACTIVE ALERTS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
                letterSpacing: 1,
              ),
            ),
          ),

          // Contenido de la alerta
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // Icono de alerta
                Icon(
                  Icons.ac_unit,
                  size: 48,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 16),

                // Texto de alerta
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Riesgo de',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'helada',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'En 18 horas',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Botón "Ver recomendación"
                const Column(
                  children: [
                    Text(
                      'Ver',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'recomendación',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Icon(
                      Icons.arrow_forward,
                      color: AppColors.secondary,
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card de resumen rápido
  Widget _buildQuickSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QUICK SUMMARY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),

          // Temperatura
          _buildSummaryRow(
            icon: Icons.thermostat_outlined,
            iconColor: Colors.red,
            label: 'Temp',
            value: '15°C mañana',
          ),

          const SizedBox(height: 16),

          // Humedad
          _buildSummaryRow(
            icon: Icons.water_drop_outlined,
            iconColor: Colors.blue,
            label: 'Hum.',
            value: '80% mañana',
          ),

          const SizedBox(height: 16),

          // Nutrientes
          _buildSummaryRow(
            icon: Icons.eco_outlined,
            iconColor: Colors.green,
            label: 'N (nutrientes)',
            value: 'Descendiendo',
            valueColor: Colors.red,
            trailing: const Icon(
              Icons.arrow_downward,
              color: Colors.red,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// Fila de resumen (reutilizable)
  Widget _buildSummaryRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 32),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing,
        ],
      ],
    );
  }

  /// Botón para ver predicciones detalladas
  Widget _buildPredictionsButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.predictions);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'VER PREDICCIONES DETALLADAS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  /// Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.secondary,
      unselectedItemColor: AppColors.textSecondary,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });

        // Navegar según el índice
        switch (index) {
          case 0:
          // Ya estamos en Home
            break;
          case 1:
            Navigator.pushNamed(context, AppRoutes.predictions);
            break;
          case 2:
            Navigator.pushNamed(context, AppRoutes.alerts);
            break;
          case 3:
            Navigator.pushNamed(context, AppRoutes.parcelas);
            break;
          case 4:
            Navigator.pushNamed(context, AppRoutes.profile);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Predicciones',
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
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}