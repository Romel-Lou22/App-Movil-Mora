import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';

import '../../../../core/config/routes/app_routes.dart';
import '../../../parcelas/presentation/providers/parcela_provider.dart';
import '../../../weather/presentation/providers/weather_provider.dart';
import '../../../predictions/presentation/providers/prediction_provider.dart';
import '../../../alerts/presentation/providers/alert_provider.dart';

class DataLoadingScreen extends StatefulWidget {
  const DataLoadingScreen({super.key});

  @override
  State<DataLoadingScreen> createState() => _DataLoadingScreenState();
}

class _DataLoadingScreenState extends State<DataLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<LoadingTask> _tasks = [];
  int _completedTasks = 0;
  bool _hasError = false;
  String _errorMessage = '';
  bool _userHasParcelas = false; // 🆕 Bandera para saber si tiene parcelas

  @override
  void initState() {
    super.initState();
    debugPrint('🔧 [LOADING] initState() llamado');

    // Animación de pulso
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 🆕 Las tareas se definirán dinámicamente después de cargar parcelas
    // Iniciar carga
    _startLoading();
  }

  Future<void> _loadParcelas() async {
    debugPrint('📦 [LOADING] Cargando parcelas...');
    final provider = context.read<ParcelaProvider>();
    await provider.fetchParcelas();

    // 🆕 Verificar si el usuario tiene parcelas
    _userHasParcelas = provider.hasParcelas;

    debugPrint('📦 [LOADING] Parcelas cargadas: ${provider.cantidadParcelas}');
    debugPrint('📦 [LOADING] Usuario tiene parcelas: $_userHasParcelas');

    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _loadWeather() async {
    final parcelaProvider = context.read<ParcelaProvider>();
    final weatherProvider = context.read<WeatherProvider>();

    // 🆕 Validar que hay parcela seleccionada
    if (parcelaProvider.parcelaSeleccionada != null) {
      final parcela = parcelaProvider.parcelaSeleccionada!;
      debugPrint('🌤️ [LOADING] Cargando clima para: ${parcela.nombreParcela}');

      await weatherProvider.fetchCurrentWeather(
        lat: parcela.latitudEfectiva,
        lon: parcela.longitudEfectiva,
      );

      debugPrint('✅ [LOADING] Clima cargado exitosamente');
    } else {
      debugPrint('⚠️ [LOADING] No hay parcela seleccionada, omitiendo clima');
    }

    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _loadPredictions() async {
    final parcelaProvider = context.read<ParcelaProvider>();
    final provider = context.read<PredictionProvider>();

    // 🆕 Validar que hay parcela seleccionada
    if (parcelaProvider.parcelaSeleccionada != null) {
      final parcelaId = parcelaProvider.parcelaSeleccionada!.id;
      debugPrint('🔮 [LOADING] Cargando datos para parcela: $parcelaId');

      await provider.fetchPredictions(parcelaId);

      debugPrint('✅ [LOADING] Datos cargados exitosamente');
    } else {
      debugPrint('⚠️ [LOADING] No hay parcela seleccionada, omitiendo predicciones');
    }

    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _loadAlerts() async {
    final parcelaProvider = context.read<ParcelaProvider>();
    final alertProvider = context.read<AlertProvider>();

    // 🆕 Validar que hay parcela seleccionada
    if (parcelaProvider.parcelaSeleccionada != null) {
      final parcelaId = parcelaProvider.parcelaSeleccionada!.id;
      debugPrint('🚨 [LOADING] Cargando alertas para parcela: $parcelaId');

      await alertProvider.fetchActiveAlerts(parcelaId);

      debugPrint('✅ [LOADING] Alertas cargadas exitosamente');
    } else {
      debugPrint('⚠️ [LOADING] No hay parcela seleccionada, omitiendo alertas');
    }

    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _startLoading() async {
    debugPrint('🚀 [LOADING] Iniciando carga de datos...');

    // 🆕 PASO 1: Cargar parcelas PRIMERO (siempre)
    setState(() {
      _tasks.add(LoadingTask(
        name: 'Cargando parcelas',
        icon: Icons.terrain,
        future: () => _loadParcelas(),
      ));
    });

    // Ejecutar carga de parcelas
    setState(() {
      _tasks[0].status = TaskStatus.loading;
    });

    try {
      await _tasks[0].future();
      if (mounted) {
        setState(() {
          _tasks[0].status = TaskStatus.completed;
          _completedTasks++;
        });
      }
      debugPrint('✅ [LOADING] Parcelas cargadas');
    } catch (e) {
      debugPrint('❌ [LOADING] Error al cargar parcelas: $e');
      if (mounted) {
        setState(() {
          _tasks[0].status = TaskStatus.error;
          _tasks[0].errorMessage = e.toString();
          _hasError = true;
          _errorMessage = 'Error al cargar parcelas: $e';
        });
      }
      return; // Detener si falla la carga de parcelas
    }

    await Future.delayed(const Duration(milliseconds: 200));

    // 🆕 PASO 2: Agregar tareas condicionales basadas en si tiene parcelas
    if (_userHasParcelas) {
      debugPrint('✅ [LOADING] Usuario tiene parcelas, cargando datos completos');

      setState(() {
        _tasks.addAll([
          LoadingTask(
            name: 'Consultando clima',
            icon: Icons.wb_sunny,
            future: () => _loadWeather(),
          ),
          LoadingTask(
            name: 'Obteniendo datos de parcela',
            icon: Icons.insights,
            future: () => _loadPredictions(),
          ),
          LoadingTask(
            name: 'Verificando alertas',
            icon: Icons.notification_important,
            future: () => _loadAlerts(),
          ),
        ]);
      });
    } else {
      debugPrint('⚠️ [LOADING] Usuario SIN parcelas, omitiendo cargas adicionales');

      // Agregar tarea informativa
      setState(() {
        _tasks.add(LoadingTask(
          name: 'Preparando interfaz',
          icon: Icons.check_circle,
          future: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
        ));
      });
    }

    // 🆕 PASO 3: Ejecutar tareas restantes
    for (int i = 1; i < _tasks.length; i++) {
      if (_hasError) break;

      setState(() {
        _tasks[i].status = TaskStatus.loading;
      });

      try {
        await _tasks[i].future();
        if (mounted) {
          setState(() {
            _tasks[i].status = TaskStatus.completed;
            _completedTasks++;
          });
        }
        debugPrint('✅ [LOADING] ${_tasks[i].name} completado');
      } catch (e) {
        debugPrint('❌ [LOADING] Error en ${_tasks[i].name}: $e');

        // 🆕 No marcar como error crítico si es un problema menor
        if (mounted) {
          setState(() {
            _tasks[i].status = TaskStatus.error;
            _tasks[i].errorMessage = e.toString();

            // Solo marcar como error crítico si es parcelas o predicciones
            if (_tasks[i].name.contains('parcelas') ||
                _tasks[i].name.contains('predicciones')) {
              _hasError = true;
              _errorMessage = 'Error al cargar ${_tasks[i].name}';
            } else {
              // Errores menores: continuar
              _completedTasks++;
              debugPrint('⚠️ [LOADING] Error no crítico, continuando...');
            }
          });
        }
      }

      await Future.delayed(const Duration(milliseconds: 200));
    }

    // 🆕 PASO 4: Navegar al home
    if (!_hasError && mounted) {
      debugPrint('✅ [LOADING] Todas las tareas completadas');
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    debugPrint('🏠 [LOADING] Navegando a Home');

    if (_userHasParcelas) {
      debugPrint('✅ [LOADING] Usuario con parcelas → Home completo');
    } else {
      debugPrint('⚠️ [LOADING] Usuario SIN parcelas → Home con mensaje');
    }

    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  void _retry() {
    debugPrint('🔄 [LOADING] Reintentando carga...');
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _completedTasks = 0;
      _userHasParcelas = false;
      _tasks.clear();
    });
    _startLoading();
  }

  void _skipAndContinue() {
    debugPrint('➡️ [LOADING] Omitiendo errores y continuando...');
    _navigateToHome();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0DF246);
    const backgroundDark = Color(0xFF102214);
    const backgroundDarker = Color(0xFF08120A);

    final progress = _tasks.isEmpty ? 0.0 : _completedTasks / _tasks.length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [backgroundDark, backgroundDarker],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Header
                  const SizedBox(height: 40),
                  const Text(
                    'EcoMora',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Preparando tu información',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),

                  const Spacer(),

                  // Indicador central
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Lista de tareas
                  if (_tasks.isNotEmpty)
                    ..._tasks.map((task) => _buildTaskItem(task)),

                  const Spacer(),

                  // Barra de progreso
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Error o botones
                  if (_hasError) ...[
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _retry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Reintentar'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: _skipAndContinue,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: primaryColor),
                            foregroundColor: primaryColor,
                          ),
                          child: const Text('Continuar'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(LoadingTask task) {
    IconData statusIcon;
    Color statusColor;

    switch (task.status) {
      case TaskStatus.pending:
        statusIcon = Icons.radio_button_unchecked;
        statusColor = Colors.white.withOpacity(0.3);
        break;
      case TaskStatus.loading:
        statusIcon = Icons.hourglass_empty;
        statusColor = const Color(0xFF0DF246);
        break;
      case TaskStatus.completed:
        statusIcon = Icons.check_circle;
        statusColor = const Color(0xFF0DF246);
        break;
      case TaskStatus.error:
        statusIcon = Icons.error;
        statusColor = Colors.red;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(task.icon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task.name,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ),
          Icon(statusIcon, color: statusColor, size: 20),
        ],
      ),
    );
  }
}

// Modelo de tarea
class LoadingTask {
  final String name;
  final IconData icon;
  final Future<void> Function() future;
  TaskStatus status;
  String? errorMessage;

  LoadingTask({
    required this.name,
    required this.icon,
    required this.future,
    this.status = TaskStatus.pending,
    this.errorMessage,
  });
}

enum TaskStatus { pending, loading, completed, error }