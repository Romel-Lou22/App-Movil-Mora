import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Botón personalizado para formularios de autenticación
/// Incluye estilos consistentes con el diseño de EcoMora
class AuthButton extends StatelessWidget {

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.height = 56,
    this.borderRadius = 12,
    this.icon,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    // Determinar si el botón está habilitado
    final bool isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.secondary,
          disabledBackgroundColor:
          (backgroundColor ?? AppColors.secondary).withOpacity(0.5),
          foregroundColor: textColor ?? AppColors.textOnButton,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? _buildLoadingIndicator()
            : _buildButtonContent(),
      ),
    );
  }

  /// Widget del indicador de carga
  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          textColor ?? AppColors.textOnButton,
        ),
      ),
    );
  }

  /// Widget del contenido del botón (texto e icono opcional)
  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: textColor ?? AppColors.textOnButton,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor ?? AppColors.textOnButton,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor ?? AppColors.textOnButton,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Variante del botón con borde (outline)
class AuthOutlineButton extends StatelessWidget {

  const AuthOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.borderColor,
    this.textColor,
    this.height = 56,
    this.borderRadius = 12,
    this.icon,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? borderColor;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primary,
          disabledForegroundColor:
          (textColor ?? AppColors.primary).withOpacity(0.5),
          side: BorderSide(
            color: isEnabled
                ? (borderColor ?? AppColors.primary)
                : (borderColor ?? AppColors.primary).withOpacity(0.5),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              textColor ?? AppColors.primary,
            ),
          ),
        )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: textColor ?? AppColors.primary,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor ?? AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor ?? AppColors.primary,
        letterSpacing: 0.5,
      ),
    );
  }
}