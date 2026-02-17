import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../predictions/presentation/providers/prediction_provider.dart';
import '../../../weather/presentation/providers/weather_provider.dart';
import '../../../predictions/domain/entities/soil_prediction.dart';

/// Card de preview de predicciones para el HomeScreen
///
/// Muestra un resumen del estado del suelo (pH, N, P, K)
/// y permite navegar al tab completo de predicciones
class PredictionPreviewCard extends StatelessWidget {
  const PredictionPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PredictionProvider>(
      builder: (context, provider, child) {
        return InkWell(
          onTap: () {
            // Navegar al tab de predicciones
            //Navigator.pushNamed(context, AppRoutes.predictions);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
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
                // Header
                _buildHeader(provider),

                const SizedBox(height: 20),

                // Contenido según el estado
                if (provider.isLoading && !provider.hasData)
                  _buildLoadingState()
                else if (provider.hasError && !provider.hasData)
                  _buildErrorState(provider.errorMessage)
                else if (provider.hasData)
                    _buildDataState(provider, context.watch<WeatherProvider>())
                  else
                    _buildEmptyState(),

                const SizedBox(height: 16),


              ],
            ),
          ),
        );
      },
    );
  }

  /// Header del card
  Widget _buildHeader(PredictionProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '🌱 ESTADO DEL SUELO',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 1,
          ),
        ),
        if (provider.hasData)
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 12,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                provider.lastUpdateText,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// Estado: Cargando
  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Cargando predicción...',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado: Error
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 32,
            ),
            const SizedBox(height: 12),
            const Text(
              'Error al cargar',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Estado: Sin datos (primera vez)
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(
              Icons.eco_outlined,
              color: Colors.grey[400],
              size: 40,
            ),
            const SizedBox(height: 12),
            const Text(
              'Sin predicciones todavía',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Genera tu primera predicción\npara ver el estado del suelo',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Estado: Con datos
  Widget _buildDataState(PredictionProvider provider, WeatherProvider weatherProvider) {
    final soil = provider.currentSoilPrediction!;
    final weather = weatherProvider.weather!;




    // Contar nutrientes fuera del rango óptimo
    int nutrientsOutOfRange = 0;
    if (!soil.phIsOptimal) nutrientsOutOfRange++;
    if (!soil.nitrogenoIsOptimal) nutrientsOutOfRange++;
    if (!soil.fosforoIsOptimal) nutrientsOutOfRange++;
    if (!soil.potasioIsOptimal) nutrientsOutOfRange++;

    return Column(
      children: [
        // pH
        _buildSummaryRow(
          icon: Icons.science_outlined,
          iconColor: const Color(0xFF9C27B0),
          label: 'pH',
          value: soil.ph.toStringAsFixed(2),
          status: soil.phIsOptimal ? '✅' : '⚠️',
          statusColor: soil.phIsOptimal ? AppColors.success : Colors.orange,
        ),

        const SizedBox(height: 12),

        // Nitrógeno
        _buildSummaryRow(
          icon: Icons.eco_outlined,
          iconColor: const Color(0xFF4CAF50),
          label: 'Nitrógeno',
          value: '${soil.nitrogeno.toStringAsFixed(2)} ppm',
          status: soil.nitrogenoIsOptimal ? '✅' : '⚠️',
          statusColor: soil.nitrogenoIsOptimal ? AppColors.success : Colors.orange,
        ),

        const SizedBox(height: 12),

        // Fósforo
        _buildSummaryRow(
          icon: Icons.grass_outlined,
          iconColor: const Color(0xFFFF9800),
          label: 'Fósforo',
          value: '${soil.fosforo.toStringAsFixed(2)} ppm',
          status: soil.fosforoIsOptimal ? '✅' : '⚠️',
          statusColor: soil.fosforoIsOptimal ? AppColors.success : Colors.orange,
        ),

        const SizedBox(height: 12),

        // Potasio
        _buildSummaryRow(
          icon: Icons.spa_outlined,
          iconColor: const Color(0xFF00BCD4),
          label: 'Potasio',
          value: '${soil.potasio.toStringAsFixed(2)} ppm',
          status: soil.potasioIsOptimal ? '✅' : '⚠️',
          statusColor: soil.potasioIsOptimal ? AppColors.success : Colors.orange,
        ),

        const SizedBox(height: 16),

        // humedad
        // DESPUÉS
        _buildSummaryRow(
          icon: Icons.water_drop_outlined,
          iconColor: const Color(0xFF2196F3),
          label: 'Humedad',
          value: '${weather.humidity} %',
          status: _humedadIsOptimal(weather.humidity.toDouble()) ? '✅' : '⚠️',
          statusColor: _humedadIsOptimal(weather.humidity.toDouble()) ? AppColors.success : Colors.orange,
        ),

        const SizedBox(height: 16),

        // Resumen general
        if (nutrientsOutOfRange > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange[200]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$nutrientsOutOfRange nutriente${nutrientsOutOfRange > 1 ? 's requieren' : ' requiere'} atención',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green[200]!,
                width: 1,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Todos los nutrientes en rango óptimo',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Row de resumen reutilizable
  Widget _buildSummaryRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String status,
    required Color statusColor,
  }) {
    return Row(
      children: [
        // Icono
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
        ),

        const SizedBox(width: 12),

        // Label
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Valor
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(width: 8),

        // Status
        Text(
          status,
          style: TextStyle(
            fontSize: 16,
            color: statusColor,
          ),
        ),
      ],
    );
  }

  /// Footer con botón de acción
///

  bool _humedadIsOptimal(double humedad) {
    return humedad >= SoilPrediction.humedadMin && humedad <= SoilPrediction.humedadMax;
  }
}
