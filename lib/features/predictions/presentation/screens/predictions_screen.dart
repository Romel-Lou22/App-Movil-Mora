import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prediction_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/soil_prediction_card.dart';

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
  // ID de la parcela activa (deberías obtenerlo del provider de parcelas)
  // Por ahora lo dejamos como ejemplo
  String? _parcelaId = 'c9320aff-9a75-4e3e-aadf-41ab2cbebd07';

  @override
  void initState() {
    super.initState();
    // Aquí deberías obtener el parcelaId de tu provider de parcelas
    // Por ejemplo: _parcelaId = context.read<ParcelasProvider>().parcelaActiva?.id;

    // Para este ejemplo, lo inicializamos después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  /// Carga los datos iniciales
  Future<void> _loadInitialData() async {
    // TODO: Obtener el parcelaId real del provider de parcelas
    // Por ahora usamos un placeholder
    // final parcelasProvider = context.read<ParcelasProvider>();
    // _parcelaId = parcelasProvider.parcelaActiva?.id;

    // TEMPORAL: Simular que tenemos un parcelaId
    // Descomenta esto cuando tengas el provider de parcelas
    // if (_parcelaId != null) {
    //   await _fetchPredictions();
    // }
  }

  /// Obtiene las predicciones
  Future<void> _fetchPredictions() async {
    if (_parcelaId == null) {
      _showError('No hay una parcela seleccionada');
      return;
    }

    final provider = context.read<PredictionProvider>();
    await provider.fetchPredictions(_parcelaId!);
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
      appBar: AppBar(
        title: const Text('Predicciones'),
        backgroundColor: const Color(0xFF6B7C3B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Botón de información
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: Consumer<PredictionProvider>(
        builder: (context, provider, child) {
          // Estado: Sin parcela seleccionada
          if (_parcelaId == null) {
            return _buildNoParcelaView();
          }

          // Estado: Cargando
          if (provider.isLoading && !provider.hasData) {
            return _buildLoadingView();
          }

          // Estado: Error
          if (provider.hasError && !provider.hasData) {
            return _buildErrorView(provider.errorMessage);
          }

          // Estado: Con datos
          if (provider.hasData) {
            return _buildDataView(provider);
          }

          // Estado: Inicial (sin datos todavía)
          return _buildInitialView();
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
                // TODO: Navegar a la pantalla de parcelas
                // Navigator.pushNamed(context, '/parcelas');
              },
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Seleccionar Parcela'),
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
  Widget _buildErrorView(String errorMessage) {
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
              onPressed: _fetchPredictions,
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
  Widget _buildInitialView() {
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
              onPressed: _fetchPredictions,
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
  Widget _buildDataView(PredictionProvider provider) {
    final weather = provider.currentWeather!;
    final soil = provider.currentSoilPrediction!;

    return RefreshIndicator(
      onRefresh: _fetchPredictions,
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
              onRefresh: provider.isLoading ? null : _fetchPredictions,
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
            _buildActionButtons(),

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
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Navegar a historial
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
                : _fetchPredictions,
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