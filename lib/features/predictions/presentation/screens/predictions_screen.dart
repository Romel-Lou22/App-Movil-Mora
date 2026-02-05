import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prediction_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/soil_prediction_card.dart';
import '../../../alerts/presentation/providers/alert_provider.dart';
import '../../../parcelas/presentation/providers/parcela_provider.dart';

/// Pantalla principal de predicciones
///
/// Muestra:
/// - Clima actual (OpenWeather)
/// - Predicción de nutrientes del suelo (HuggingFace)
/// - Botones de acción (Actualizar, Ver Historial)
/// - Estados de carga y error
class PredictionsScreen extends StatefulWidget {
  const PredictionsScreen({super.key});

  @override
  State<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends State<PredictionsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();

      // Escuchar cambios en la parcela
      context.read<ParcelaProvider>().addListener(_onParcelaChanged);
    });
  }

  void _onParcelaChanged() {
    final parcelaId = context.read<ParcelaProvider>().parcelaSeleccionada?.id;
    if (parcelaId != null && mounted) {
      _fetchPredictions(parcelaId);
    }
  }

  @override
  void dispose() {
    context.read<ParcelaProvider>().removeListener(_onParcelaChanged);
    super.dispose();
  }

  /// Carga los datos iniciales
  Future<void> _loadInitialData() async {
    // Obtener el parcelaId del provider de parcelas
    final parcelaProvider = context.read<ParcelaProvider>();
    final parcelaId = parcelaProvider.parcelaSeleccionada?.id;

    if (parcelaId != null) {
      await _fetchPredictions(parcelaId);
    } else {
      _showError('No hay una parcela seleccionada');
    }
  }

  /// Obtiene las predicciones para una parcela específica
  Future<void> _fetchPredictions(String parcelaId) async {
    print('🎯 ===================================');
    print('🎯 BOTÓN PRESIONADO - Iniciando flujo completo');
    print('📍 Parcela: $parcelaId');

    final predictionProvider = context.read<PredictionProvider>();

    // Llamar a fetchPredictions CON callback para alertas
    await predictionProvider.fetchPredictions(
      parcelaId,
      onPredictionComplete: (weather, soil) async {
        print('🚨 ===================================');
        print('🚨 CALLBACK DE ALERTAS - Inicio');

        // Construir el mapa de features para el Random Forest
        final features = {
          'pH': soil.ph,
          'temperatura_C': weather.temperatura,
          'humedad_suelo_pct': weather.humedad,
          'N_ppm': soil.nitrogeno,
          'P_ppm': soil.fosforo,
          'K_ppm': soil.potasio,
        };

        print('📊 Features para Random Forest:');
        print('   - pH: ${soil.ph}');
        print('   - Temperatura: ${weather.temperatura}°C');
        print('   - Humedad: ${weather.humedad}%');
        print('   - Nitrógeno: ${soil.nitrogeno} ppm');
        print('   - Fósforo: ${soil.fosforo} ppm');
        print('   - Potasio: ${soil.potasio} ppm');

        // Evaluar alertas con el Random Forest
        if (!mounted) return;

        final alertProvider = context.read<AlertProvider>();
        await alertProvider.evaluateThresholds(
          parcelaId: parcelaId,
          features: features,
        );

        // Mostrar feedback al usuario
        if (!mounted) return;

        final alertsGenerated = alertProvider.lastEvaluationAlerts.length;
        if (alertsGenerated > 0) {
          print('✅ Se generaron $alertsGenerated alertas nuevas');
          _showSuccess('✅ Predicción completada - $alertsGenerated alertas generadas');
        } else {
          print('ℹ️ No se generaron alertas nuevas');
          _showSuccess('✅ Predicción completada - Sin alertas críticas');
        }

        print('🚨 CALLBACK DE ALERTAS - Fin');
        print('🚨 ===================================');
      },
    );

    print('🎯 FLUJO COMPLETO TERMINADO');
    print('🎯 ===================================');
  }

  /// Muestra un mensaje de error
  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Muestra un mensaje de éxito
  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF388E3C),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: Consumer2<PredictionProvider, ParcelaProvider>(
        builder: (context, predictionProvider, parcelaProvider, child) {
          // Obtener parcelaId del provider
          final parcelaId = parcelaProvider.parcelaSeleccionada?.id;

          // Estado: Sin parcela seleccionada
          if (parcelaId == null) {
            return _buildNoParcelaView();
          }

          // Estado: Cargando
          if (predictionProvider.isLoading && !predictionProvider.hasData) {
            return _buildLoadingView();
          }

          // Estado: Error
          if (predictionProvider.hasError && !predictionProvider.hasData) {
            return _buildErrorView(predictionProvider.errorMessage, parcelaId);
          }

          // Estado: Con datos
          if (predictionProvider.hasData) {
            return _buildDataView(predictionProvider, parcelaId);
          }

          // Estado: Inicial (sin datos todavía)
          return _buildInitialView(parcelaId);
        },
      ),
    );
  }

  /// Vista cuando no hay parcela seleccionada
  Widget _buildNoParcelaView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.agriculture_outlined,
              size: 80,
              color: Color(0xFFCCCCCC),
            ),
            const SizedBox(height: 24),
            const Text(
              'No hay parcela seleccionada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Selecciona una parcela para ver las predicciones',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver al inicio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B7C3B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Vista de carga
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B7C3B)),
          ),
          SizedBox(height: 24),
          Text(
            'Obteniendo predicciones...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Consultando OpenWeather y modelo de IA',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  /// Vista de error
  Widget _buildErrorView(String errorMessage, String parcelaId) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Color(0xFFD32F2F),
            ),
            const SizedBox(height: 24),
            const Text(
              'Error al obtener datos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _fetchPredictions(parcelaId),
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar nuevamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B7C3B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Vista inicial (cuando no se han cargado datos todavía)
  Widget _buildInitialView(String parcelaId) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.analytics_outlined,
              size: 80,
              color: Color(0xFF6B7C3B),
            ),
            const SizedBox(height: 24),
            const Text(
              'Predicciones Agrícolas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B7C3B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Obtén datos climáticos en tiempo real y predicciones de nutrientes del suelo con IA',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _fetchPredictions(parcelaId),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Obtener Predicciones'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B7C3B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Vista con datos
  Widget _buildDataView(PredictionProvider provider, String parcelaId) {
    final weather = provider.currentWeather!;
    final soil = provider.currentSoilPrediction!;

    return RefreshIndicator(
      onRefresh: () => _fetchPredictions(parcelaId),
      color: const Color(0xFF6B7C3B),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con última actualización
            _buildHeader(provider),

            const SizedBox(height: 16),

            // Card de clima
            WeatherCard(
              weatherData: weather,
              onRefresh: provider.isLoading ? null : () => _fetchPredictions(parcelaId),
            ),

            const SizedBox(height: 16),

            // Card de predicción de suelo
            SoilPredictionCard(
              soilPrediction: soil,
            ),

            const SizedBox(height: 16),

            // Resumen general
            _buildHealthSummary(provider),

            const SizedBox(height: 16),

            // Botones de acción
            _buildActionButtons(parcelaId),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Header con última actualización
  Widget _buildHeader(PredictionProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estado Actual',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  provider.lastUpdateText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        // Indicador de datos desactualizados
        if (provider.isDataOutdated)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber,
                  size: 14,
                  color: Color(0xFFF57C00),
                ),
                SizedBox(width: 4),
                Text(
                  'Datos antiguos',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFF57C00),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Resumen de salud del cultivo
  Widget _buildHealthSummary(PredictionProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B7C3B), Color(0xFF8B9D5B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen del Cultivo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.cultiveHealthSummary,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Botones de acción
  Widget _buildActionButtons(String parcelaId) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _showSuccess('Función de historial próximamente');
            },
            icon: const Icon(Icons.history),
            label: const Text('Ver Historial'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6B7C3B),
              side: const BorderSide(color: Color(0xFF6B7C3B)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: context.watch<PredictionProvider>().isLoading
                ? null
                : () => _fetchPredictions(parcelaId),
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B7C3B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  /// Muestra el diálogo de información
  void _showInfoDialog() {
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