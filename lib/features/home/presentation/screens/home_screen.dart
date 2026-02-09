import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';

import '../../../alerts/presentation/screens/alerts_screen.dart';
import '../../../weather/presentation/providers/weather_provider.dart';
import '../../../parcelas/presentation/providers/parcela_provider.dart';

import '../widgets/current_weather_card.dart';
import '../widgets/prediction_preview_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onTabRequested});
  final ValueChanged<int>? onTabRequested;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {

    });
  }

  Future<void> _refreshHome() async {
    // Nota: aquí recargas "lo que alimenta los cards del Home".
    // Por ahora: clima + parcelas (por si cambió algo en backend).
    final weather = context.read<WeatherProvider>();
    final parcelas = context.read<ParcelaProvider>();

    await Future.wait([

      parcelas.refresh(), // o parcelas.fetchParcelas()
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshHome,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildParcelaInfo(),
                const SizedBox(height: 16),
                const CurrentWeatherCard(),
                const SizedBox(height: 16),

                const SizedBox(height: 16),
                const PredictionPreviewCard(),
                const SizedBox(height: 24),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParcelaInfo() {
    return Consumer<ParcelaProvider>(
      builder: (context, parcelaProvider, _) {
        final parcela = parcelaProvider.parcelaSeleccionada;

        final nombre = parcela?.nombreParcela ?? 'Sin parcela';
        final ubicacion = parcela == null
            ? 'Selecciona una parcela'
            : (parcela.usaUbicacionDefault
            ? 'Tisaleo (general)'
            : '${parcela.latitudEfectiva.toStringAsFixed(5)}, ${parcela.longitudEfectiva.toStringAsFixed(5)}');

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ubicacion,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Última actualización: ${TimeOfDay.now().format(context)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }




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
        Text(label, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
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


}
