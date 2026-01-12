import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../providers/parcela_provider.dart';
import '../widgets/location_picker_widget.dart';

/// Pantalla para agregar una nueva parcela
/// Formulario con nombre, ubicación y área
class AddParcelaScreen extends StatefulWidget {
  const AddParcelaScreen({super.key});

  @override
  State<AddParcelaScreen> createState() => _AddParcelaScreenState();
}

class _AddParcelaScreenState extends State<AddParcelaScreen> {
  // Form key para validación
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nombreController = TextEditingController();
  final _areaController = TextEditingController();

  // Variables de estado
  double? _latitud;
  double? _longitud;
  bool _usaUbicacionDefault = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Nueva Parcela'),
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  /// Cuerpo principal con formulario
  Widget _buildBody() {
    return Consumer<ParcelaProvider>(
      builder: (context, parcelaProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título descriptivo
                _buildHeader(),

                const SizedBox(height: 24),

                // Campo: Nombre de la parcela
                _buildNombreField(parcelaProvider),

                const SizedBox(height: 20),

                // Widget: Selector de ubicación
                LocationPickerWidget(
                  usaUbicacionDefaultInicial: true,
                  onLocationChanged: (lat, lon, usaDefault) {
                    setState(() {
                      _latitud = lat;
                      _longitud = lon;
                      _usaUbicacionDefault = usaDefault;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Campo: Área (opcional)
                _buildAreaField(parcelaProvider),

                const SizedBox(height: 32),

                // Botón: Guardar
                _buildGuardarButton(parcelaProvider),

                const SizedBox(height: 16),

                // Botón: Cancelar
                _buildCancelarButton(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Header con título y descripción
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.grass,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agregar Parcela',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Registra una nueva parcela de cultivo',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Campo de nombre de parcela
  Widget _buildNombreField(ParcelaProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre de la Parcela *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nombreController,
          enabled: !provider.isCreating,
          decoration: InputDecoration(
            hintText: 'Ej: Parcela Norte, Lote Sur',
            prefixIcon: const Icon(Icons.edit),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es requerido';
            }
            if (value.trim().length < 3) {
              return 'El nombre debe tener al menos 3 caracteres';
            }
            if (value.trim().length > 100) {
              return 'El nombre no debe exceder 100 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Campo de área (opcional)
  Widget _buildAreaField(ParcelaProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Área de la Parcela (opcional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _areaController,
          enabled: !provider.isCreating,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Ej: 2.5',
            suffixText: 'hectáreas',
            prefixIcon: const Icon(Icons.square_foot),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final area = double.tryParse(value);
              if (area == null) {
                return 'Ingrese un número válido';
              }
              if (area <= 0) {
                return 'El área debe ser mayor que 0';
              }
              if (area > 1000) {
                return 'El área no puede exceder 1000 hectáreas';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        const Text(
          'Especifica el área total de tu parcela de cultivo',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Botón de guardar
  Widget _buildGuardarButton(ParcelaProvider provider) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: provider.isCreating ? null : _handleGuardar,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.secondary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: provider.isCreating
            ? const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Guardando...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        )
            : const Text(
          'GUARDAR PARCELA',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Botón de cancelar
  Widget _buildCancelarButton() {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'CANCELAR',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Maneja el guardado de la parcela
  Future<void> _handleGuardar() async {
    // Limpiar errores previos
    context.read<ParcelaProvider>().clearError();

    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Quitar el foco del teclado
    FocusScope.of(context).unfocus();

    // Parsear área si está presente
    double? area;
    if (_areaController.text.isNotEmpty) {
      area = double.tryParse(_areaController.text);
    }

    // Crear la parcela
    final success = await context.read<ParcelaProvider>().createParcela(
      nombreParcela: _nombreController.text.trim(),
      latitud: _latitud,
      longitud: _longitud,
      usaUbicacionDefault: _usaUbicacionDefault,
      areaHectareas: area,
    );

    // Verificar si el widget sigue montado
    if (!mounted) return;

    // Manejar resultado
    if (success) {
      // Éxito: Mostrar mensaje y volver
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Parcela creada exitosamente!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );

      // Volver a la pantalla anterior
      Navigator.of(context).pop();
    } else {
      // Error: Mostrar mensaje
      final errorMessage = context.read<ParcelaProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Error al crear la parcela'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}