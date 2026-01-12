import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/parcela.dart';
import '../providers/parcela_provider.dart';
import '../widgets/location_picker_widget.dart';

/// Pantalla para editar una parcela existente
/// Recibe la parcela como argumento de navegación
class EditParcelaScreen extends StatefulWidget {
  final Parcela parcela;

  const EditParcelaScreen({
    super.key,
    required this.parcela,
  });

  @override
  State<EditParcelaScreen> createState() => _EditParcelaScreenState();
}

class _EditParcelaScreenState extends State<EditParcelaScreen> {
  // Form key para validación
  final _formKey = GlobalKey<FormState>();

  // Controladores
  late final TextEditingController _nombreController;
  late final TextEditingController _areaController;

  // Variables de estado
  late double? _latitud;
  late double? _longitud;
  late bool _usaUbicacionDefault;

  @override
  void initState() {
    super.initState();

    // Inicializar con valores actuales de la parcela
    _nombreController = TextEditingController(text: widget.parcela.nombreParcela);
    _areaController = TextEditingController(
      text: widget.parcela.areaHectareas?.toString() ?? '',
    );

    _latitud = widget.parcela.latitud;
    _longitud = widget.parcela.longitud;
    _usaUbicacionDefault = widget.parcela.usaUbicacionDefault;
  }

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
      title: const Text('Editar Parcela'),
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // Botón de eliminar
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: _mostrarDialogoEliminar,
          tooltip: 'Eliminar parcela',
        ),
      ],
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
                // Header con información de la parcela
                _buildHeader(),

                const SizedBox(height: 24),

                // Campo: Nombre de la parcela
                _buildNombreField(parcelaProvider),

                const SizedBox(height: 20),

                // Widget: Selector de ubicación
                LocationPickerWidget(
                  latitudInicial: _latitud,
                  longitudInicial: _longitud,
                  usaUbicacionDefaultInicial: _usaUbicacionDefault,
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

                // Botón: Guardar cambios
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

  /// Header con información de la parcela
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Editar Parcela',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${widget.parcela.id.substring(0, 8)}...',
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
          enabled: !provider.isUpdating,
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
          enabled: !provider.isUpdating,
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
      ],
    );
  }

  /// Botón de guardar cambios
  Widget _buildGuardarButton(ParcelaProvider provider) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: provider.isUpdating || provider.isDeleting
            ? null
            : _handleGuardar,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.secondary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: provider.isUpdating
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
              'Guardando cambios...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        )
            : const Text(
          'GUARDAR CAMBIOS',
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

  /// Maneja el guardado de cambios
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

    // Actualizar la parcela
    final success = await context.read<ParcelaProvider>().updateParcela(
      parcelaId: widget.parcela.id,
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
          content: Text('¡Cambios guardados exitosamente!'),
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
          content: Text(errorMessage ?? 'Error al guardar cambios'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Muestra diálogo de confirmación para eliminar
  void _mostrarDialogoEliminar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desactivar Parcela'),
        content: Text(
          '¿Estás seguro de que quieres desactivar "${widget.parcela.nombreParcela}"?\n\n'
              'Los datos históricos se mantendrán, pero la parcela dejará de aparecer en tus listas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleEliminar();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
  }

  /// Maneja la eliminación (desactivación) de la parcela
  Future<void> _handleEliminar() async {
    final success = await context.read<ParcelaProvider>().deleteParcela(
      widget.parcela.id,
    );

    // Verificar si el widget sigue montado
    if (!mounted) return;

    // Manejar resultado
    if (success) {
      // Éxito: Mostrar mensaje y volver
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parcela desactivada exitosamente'),
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
          content: Text(errorMessage ?? 'Error al desactivar parcela'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}