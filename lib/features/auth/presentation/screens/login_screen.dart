import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

/// Pantalla de Login de EcoMora
/// Diseño basado en la imagen proporcionada
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Form key para validación
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Maneja el inicio de sesión
  Future<void> _handleLogin() async {
    // Limpiar errores previos
    context.read<AuthProvider>().clearError();

    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Quitar el foco del teclado
    FocusScope.of(context).unfocus();

    // Ejecutar login
    await context.read<AuthProvider>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    // Verificar si el widget sigue montado
    if (!mounted) return;

    // Manejar resultado
    final authProvider = context.read<AuthProvider>();

    if (authProvider.isAuthenticated) {
      // Login exitoso - Navegar a Home
      // TODO: Implementar navegación cuando tengas HomeScreen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Bienvenido ${authProvider.user?.displayName}!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (authProvider.hasError) {
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Error desconocido'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Navega a la pantalla de recuperación de contraseña
  void _navigateToForgotPassword() {
    // TODO: Implementar cuando tengas ForgotPasswordScreen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad en desarrollo'),
      ),
    );
  }

  /// Navega a la pantalla de registro
  void _navigateToRegister() {
    // TODO: Implementar cuando tengas RegisterScreen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad en desarrollo'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // Logo
                _buildLogo(),

                const SizedBox(height: 40),

                // Título
                _buildTitle(),

                const SizedBox(height: 40),

                // Campo de Email
                _buildEmailField(),

                const SizedBox(height: 20),

                // Campo de Contraseña
                _buildPasswordField(),

                const SizedBox(height: 16),

                // ¿Olvidaste tu contraseña?
                _buildForgotPasswordLink(),

                const SizedBox(height: 32),

                // Botón de Iniciar Sesión
                _buildLoginButton(),

                const SizedBox(height: 24),

                // ¿No tienes cuenta? Regístrate
                _buildRegisterLink(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget del logo
  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de planta (simulando el logo)
            Icon(
              Icons.eco,
              color: Colors.white,
              size: 40,
            ),
            SizedBox(height: 8),
            // Texto del logo
            Text(
              'ECOMORA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            Text(
              'manage sensitive work',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget del título
  Widget _buildTitle() {
    return const Text(
      'Bienvenido a EcoMora',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Widget del campo de email
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Correo Electrónico',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return AuthTextField(
              controller: _emailController,
              hintText: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              enabled: !authProvider.isLoading,
            );
          },
        ),
      ],
    );
  }

  /// Widget del campo de contraseña
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contraseña',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return AuthTextField(
              controller: _passwordController,
              hintText: 'Contraseña',
              prefixIcon: Icons.lock_outlined,
              isPassword: true,
              validator: Validators.password,
              enabled: !authProvider.isLoading,
            );
          },
        ),
      ],
    );
  }

  /// Widget del link "¿Olvidaste tu contraseña?"
  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _navigateToForgotPassword,
        child: const Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  /// Widget del botón de login
  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return AuthButton(
          text: 'INICIAR SESIÓN',
          onPressed: authProvider.isLoading ? null : _handleLogin,
          isLoading: authProvider.isLoading,
        );
      },
    );
  }

  /// Widget del link de registro
  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '¿No tienes cuenta? ',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: _navigateToRegister,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Regístrate',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}