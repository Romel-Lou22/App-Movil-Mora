import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import '../../../../core/config/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() {
    debugPrint('🎨 [SPLASH] Creando estado del SplashScreen');
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  double _loadingProgress = 0.0;
  Timer? _progressTimer;
  String _loadingMessage = 'INICIANDO...';

  @override
  void initState() {
    super.initState();
    debugPrint('🔧 [SPLASH] initState() llamado');

    try {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 700),
        vsync: this,
      );
      debugPrint('✅ [SPLASH] AnimationController creado');

      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn),
      );
      debugPrint('✅ [SPLASH] fadeAnimation configurada');

      _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
      debugPrint('✅ [SPLASH] scaleAnimation configurada');

      _controller.forward();
      debugPrint('▶️ [SPLASH] Animaciones iniciadas');

      debugPrint('🚀 [SPLASH] Iniciando proceso de inicialización...');
      _startInitialization();
    } catch (e, stackTrace) {
      debugPrint('❌ [SPLASH] Error en initState: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> _startInitialization() async {
    debugPrint('⏳ [SPLASH] _startInitialization() iniciado');

    _progressTimer = Timer.periodic(
      const Duration(milliseconds: 50),
          (timer) {
        if (mounted) {
          setState(() {
            _loadingProgress += 0.02;
            if (_loadingProgress >= 1.0) {
              _loadingProgress = 1.0;
              timer.cancel();
              debugPrint('✅ [SPLASH] Progreso completado (100%)');
            }
          });
        }
      },
    );
    debugPrint('✅ [SPLASH] Timer de progreso iniciado');

    try {
      debugPrint('⏱️ [SPLASH] Esperando 2.5 segundos...');
      setState(() => _loadingMessage = 'CARGANDO RECURSOS...');
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() => _loadingMessage = 'CONECTANDO SERVICIOS...');
      await Future.delayed(const Duration(milliseconds: 600));

      setState(() => _loadingMessage = 'VERIFICANDO SESIÓN...');
      await Future.delayed(const Duration(milliseconds: 600));

      setState(() => _loadingMessage = 'PREPARANDO INTERFAZ...');
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => _loadingMessage = '¡LISTO!');
      await Future.delayed(const Duration(milliseconds: 300));

      debugPrint('✅ [SPLASH] Inicializaciones completadas');

      if (mounted) {
        debugPrint('🧭 [SPLASH] Navegando a siguiente pantalla...');
        _navigateToNextScreen();
      } else {
        debugPrint('⚠️ [SPLASH] Widget no montado, cancelando navegación');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [SPLASH] Error en _startInitialization: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        _handleInitializationError(e);
      }
    }
  }

  void _navigateToNextScreen() {
    debugPrint('🎯 [SPLASH] _navigateToNextScreen() llamado');

    try {
      debugPrint('🧭 [SPLASH] Navegando a Login');

      // Usar rutas nombradas para mantener acceso a Providers
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);

      debugPrint('✅ [SPLASH] Navegación completada');
    } catch (e, stackTrace) {
      debugPrint('❌ [SPLASH] Error al navegar: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al navegar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleInitializationError(Object error) {
    debugPrint('⚠️ [SPLASH] Manejando error: $error');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Error de Inicialización'),
        content: Text(
          'No se pudo inicializar la aplicación.\n\n'
              'Error: $error\n\n'
              '¿Desea reintentar?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('🔄 [SPLASH] Usuario presionó Reintentar');
              Navigator.of(context).pop();
              setState(() {
                _loadingProgress = 0.0;
                _loadingMessage = 'REINTENTANDO...';
              });
              _startInitialization();
            },
            child: const Text('Reintentar'),
          ),
          TextButton(
            onPressed: () {
              debugPrint('➡️ [SPLASH] Usuario presionó Ir a Login');
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
            child: const Text('Ir a Login'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('🗑️ [SPLASH] dispose() llamado');
    _controller.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0DF246);
    const Color backgroundDark = Color(0xFF102214);
    const Color backgroundDarker = Color(0xFF08120A);

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
          child: Stack(
            children: [
              Positioned(
                top: -96,
                left: -96,
                child: Container(
                  width: 256,
                  height: 256,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.1),
                        blurRadius: 100,
                        spreadRadius: 50,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -96,
                right: -96,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.05),
                        blurRadius: 120,
                        spreadRadius: 60,
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'ECOMORA V1.0',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.05),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.eco,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'EcoMora',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                height: 1.1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Monitoreo inteligente de parcelas',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 64.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 32),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 4,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            child: Column(
                              children: [
                                Text(
                                  _loadingMessage,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _loadingProgress,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}