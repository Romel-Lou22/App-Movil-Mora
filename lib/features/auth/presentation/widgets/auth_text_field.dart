import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// TextField personalizado para formularios de autenticación
/// Incluye estilos consistentes con el diseño de EcoMora
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: AppColors.textHint,
          fontSize: 16,
        ),

        // Icono izquierdo
        prefixIcon: Icon(
          widget.prefixIcon,
          color: AppColors.iconPrimary,
          size: 24,
        ),

        // Icono derecho (mostrar/ocultar contraseña)
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.iconSecondary,
            size: 24,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : null,

        // Borde normal
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: 1.5,
          ),
        ),

        // Borde cuando está enfocado
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.borderActive,
            width: 2,
          ),
        ),

        // Borde cuando hay error
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.borderError,
            width: 1.5,
          ),
        ),

        // Borde cuando hay error y está enfocado
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.borderError,
            width: 2,
          ),
        ),

        // Borde cuando está deshabilitado
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.border.withOpacity(0.5),
            width: 1.5,
          ),
        ),

        // Estilo del texto de error
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontSize: 12,
        ),

        // Padding interno
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        // Fondo
        filled: true,
        fillColor: widget.enabled
            ? AppColors.inputBackground
            : AppColors.inputBackground.withOpacity(0.5),
      ),
    );
  }
}