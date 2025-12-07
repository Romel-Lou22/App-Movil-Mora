import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

/// Pantalla de Registro de EcoMora
/// Permite crear una nueva cuenta de usuario
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Form key para validación
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Maneja el registro
  Future<void> _handleRegister() async {
    // Limpiar errores previos
    context.read<AuthProvider>().clearError();

    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Quitar el foco del teclado
    FocusScope.of(context).unfocus();

    // Ejecutar registro
    await context.read<AuthProvider>().register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );

    // Verificar si el widget sigue montado
    if (!mounted) return;

    // Manejar resultado
    final authProvider = context.read<AuthProvider>();

    if (authProvider.isAuthenticated) {
      // Registro exitoso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Bienvenido ${authProvider.user?.displayName}!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navegar a Home o hacer pop
      Navigator.of(context).pop();
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

  /// Navega de vuelta al login
  void _navigateToLogin() {
    Navigator.of(context).pop();
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
                const SizedBox(height: 20),

                // Botón de retroceso
                _buildBackButton(),

                const SizedBox(height: 20),

                // Título
                _buildTitle(),

                const SizedBox(height: 40),

                // Card con formulario
                _buildFormCard(),

                const SizedBox(height: 24),

                // ¿Ya tienes cuenta? Inicia sesión
                _buildLoginLink(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget del botón de retroceso
  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: AppColors.primary,
          size: 28,
        ),
        onPressed: _navigateToLogin,
      ),
    );
  }

  /// Widget del título
  Widget _buildTitle() {
    return const Text(
      'Crear cuenta',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  /// Widget del card con el formulario
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Campo de Nombre Completo
          _buildFullNameField(),

          const SizedBox(height: 20),

          // Campo de Email
          _buildEmailField(),

          const SizedBox(height: 20),

          // Campo de Teléfono
          _buildPhoneField(),

          const SizedBox(height: 20),

          // Campo de Contraseña
          _buildPasswordField(),

          const SizedBox(height: 20),

          // Campo de Confirmar Contraseña
          _buildConfirmPasswordField(),

          const SizedBox(height: 32),

          // Botón de Registro
          _buildRegisterButton(),
        ],
      ),
    );
  }

  /// Widget del campo de nombre completo
  Widget _buildFullNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre completo',
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
              controller: _fullNameController,
              hintText: 'Juan Pérez',
              prefixIcon: Icons.person_outline,
              keyboardType: TextInputType.name,
              validator: (value) => Validators.required(value, 'El nombre completo'),
              enabled: !authProvider.isLoading,
            );
          },
        ),
      ],
    );
  }

  /// Widget del campo de email
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
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
              hintText: 'juan.perez@example.com',
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

  /// Widget del campo de teléfono
  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Teléfono (opcional)',
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
              controller: _phoneController,
              hintText: '+593 999 999 999',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
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
              hintText: '••••••••',
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

  /// Widget del campo de confirmar contraseña
  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirmar contraseña',
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
              controller: _confirmPasswordController,
              hintText: '••••••••',
              prefixIcon: Icons.lock_outlined,
              isPassword: true,
              validator: (value) => Validators.confirmPassword(
                value,
                _passwordController.text,
              ),
              enabled: !authProvider.isLoading,
            );
          },
        ),
      ],
    );
  }

  /// Widget del botón de registro
  Widget _buildRegisterButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return AuthButton(
          text: 'REGISTRARSE',
          onPressed: authProvider.isLoading ? null : _handleRegister,
          isLoading: authProvider.isLoading,
        );
      },
    );
  }

  /// Widget del link de login
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '¿Ya tienes cuenta? ',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: _navigateToLogin,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Inicia sesión',
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