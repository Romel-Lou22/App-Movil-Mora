import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/parcela.dart';

/// Tipos de ubicación que se pueden seleccionar
enum TipoUbicacion {
  automatica,  // Detectar con GPS
  manual,      // Ingresar coordenadas manualmente
  porDefecto,  // Usar coordenadas de Tisaleo
}

/// Widget para seleccionar la ubicación de una parcela
/// Permite tres opciones: GPS automático, manual o por defecto
class LocationPickerWidget extends StatefulWidget {
  final double? latitudInicial;
  final double? longitudInicial;
  final bool usaUbicacionDefaultInicial;
  final Function(double? latitud, double? longitud, bool usaDefault) onLocationChanged;

  const LocationPickerWidget({
    super.key,
    this.latitudInicial,
    this.longitudInicial,
    this.usaUbicacionDefaultInicial = false,
    required this.onLocationChanged,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  late TipoUbicacion _tipoSeleccionado;
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  bool _isGettingLocation = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Determinar tipo inicial
    if (widget.usaUbicacionDefaultInicial) {
      _tipoSeleccionado = TipoUbicacion.porDefecto;
    } else if (widget.latitudInicial != null && widget.longitudInicial != null) {
      _tipoSeleccionado = TipoUbicacion.manual;
      _latitudController.text = widget.latitudInicial.toString();
      _longitudController.text = widget.longitudInicial.toString();
    } else {
      _tipoSeleccionado = TipoUbicacion.porDefecto;
    }
  }

  @override
  void dispose() {
    _latitudController.dispose();
    _longitudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        const Text(
          'Ubicación de la Parcela',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Opciones de ubicación
        _buildOpcionUbicacion(
          tipo: TipoUbicacion.porDefecto,
          titulo: 'Usar ubicación general de Tisaleo',
          subtitulo: 'Coordenadas: ${Parcela.DEFAULT_LATITUDE}, ${Parcela.DEFAULT_LONGITUDE}',
          icono: Icons.location_city,
        ),

        const SizedBox(height: 8),

        _buildOpcionUbicacion(
          tipo: TipoUbicacion.automatica,
          titulo: 'Detectar mi ubicación actual',
          subtitulo: 'Usar GPS del dispositivo',
          icono: Icons.my_location,
        ),

        const SizedBox(height: 8),

        _buildOpcionUbicacion(
          tipo: TipoUbicacion.manual,
          titulo: 'Ingresar coordenadas manualmente',
          subtitulo: 'Especificar latitud y longitud',
          icono: Icons.edit_location_alt,
        ),

        // Campos de entrada manual (solo si está seleccionado)
        if (_tipoSeleccionado == TipoUbicacion.manual) ...[
          const SizedBox(height: 16),
          _buildCamposCoordenadas(),
        ],

        // Mensaje de error si hay
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          _buildErrorMessage(),
        ],

        // Indicador de carga
        if (_isGettingLocation) ...[
          const SizedBox(height: 12),
          _buildLoadingIndicator(),
        ],
      ],
    );
  }

  /// Opción de ubicación (radio button con descripción)
  Widget _buildOpcionUbicacion({
    required TipoUbicacion tipo,
    required String titulo,
    required String subtitulo,
    required IconData icono,
  }) {
    final isSelected = _tipoSeleccionado == tipo;

    return InkWell(
      onTap: () => _seleccionarTipo(tipo),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Radio button
            Radio<TipoUbicacion>(
              value: tipo,
              groupValue: _tipoSeleccionado,
              onChanged: (value) {
                if (value != null) _seleccionarTipo(value);
              },
              activeColor: AppColors.primary,
            ),

            // Icono
            Icon(
              icono,
              color: isSelected ? AppColors.primary : AppColors.iconSecondary,
              size: 24,
            ),

            const SizedBox(width: 12),

            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Campos para ingresar coordenadas manualmente
  Widget _buildCamposCoordenadas() {
    return Column(
      children: [
        // Campo de Latitud
        TextFormField(
          controller: _latitudController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          decoration: const InputDecoration(
            labelText: 'Latitud',
            hintText: 'Ej: -1.3667',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _notificarCambio(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingrese la latitud';
            }
            final lat = double.tryParse(value);
            if (lat == null || lat < -90 || lat > 90) {
              return 'Latitud inválida (-90 a 90)';
            }
            return null;
          },
        ),

        const SizedBox(height: 12),

        // Campo de Longitud
        TextFormField(
          controller: _longitudController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          decoration: const InputDecoration(
            labelText: 'Longitud',
            hintText: 'Ej: -78.6833',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _notificarCambio(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingrese la longitud';
            }
            final lon = double.tryParse(value);
            if (lon == null || lon < -180 || lon > 180) {
              return 'Longitud inválida (-180 a 180)';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Mensaje de error
  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Indicador de carga
  Widget _buildLoadingIndicator() {
    return const Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Text(
          'Obteniendo ubicación...',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Selecciona un tipo de ubicación
  void _seleccionarTipo(TipoUbicacion tipo) {
    setState(() {
      _tipoSeleccionado = tipo;
      _errorMessage = null;
    });

    if (tipo == TipoUbicacion.automatica) {
      _obtenerUbicacionActual();
    } else {
      _notificarCambio();
    }
  }

  /// Obtiene la ubicación actual con GPS
  Future<void> _obtenerUbicacionActual() async {
    setState(() {
      _isGettingLocation = true;
      _errorMessage = null;
    });

    try {
      // Verificar permisos
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permisos de ubicación denegados permanentemente');
      }

      // Obtener posición
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Actualizar campos
      _latitudController.text = position.latitude.toStringAsFixed(5);
      _longitudController.text = position.longitude.toStringAsFixed(5);

      // Cambiar a manual para mostrar las coordenadas
      setState(() {
        _tipoSeleccionado = TipoUbicacion.manual;
        _isGettingLocation = false;
      });

      _notificarCambio();

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación obtenida exitosamente'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGettingLocation = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _tipoSeleccionado = TipoUbicacion.porDefecto;
      });
    }
  }

  /// Notifica el cambio de ubicación
  void _notificarCambio() {
    if (_tipoSeleccionado == TipoUbicacion.porDefecto) {
      widget.onLocationChanged(null, null, true);
    } else if (_tipoSeleccionado == TipoUbicacion.manual) {
      final lat = double.tryParse(_latitudController.text);
      final lon = double.tryParse(_longitudController.text);
      widget.onLocationChanged(lat, lon, false);
    }
  }
}