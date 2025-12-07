import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/config/routes/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Drawer (menú lateral) de la pantalla Home
/// Muestra información del usuario y opción de cerrar sesión
class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          return Column(
            children: [
              // Header del Drawer con info del usuario
              _buildDrawerHeader(context, user),

              // Espacio
              const SizedBox(height: 20),

              // Divider
              const Divider(height: 1),

              // Botón de Cerrar Sesión
              _buildLogoutButton(context, authProvider),

              // Spacer para empujar el contenido hacia arriba
              const Spacer(),

              // Versión de la app (opcional)
              _buildAppVersion(),
            ],
          );
        },
      ),
    );
  }

  /// Header del drawer con avatar, nombre y email
  Widget _buildDrawerHeader(BuildContext context, dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary,
            AppColors.secondaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar con iniciales
          _buildAvatar(user),

          const SizedBox(height: 16),

          // Nombre del usuario
          Text(
            user?.displayName as String ?? 'Usuario',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          // Email del usuario
          Text(
            user?.email as String ??'email@ejemplo.com',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Avatar circular con las iniciales del usuario
  Widget _buildAvatar(dynamic user) {
    final initials = user?.initials as String ?? '?';

    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.white,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  /// Botón de cerrar sesión
  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return ListTile(
      leading: const Icon(
        Icons.logout,
        color: AppColors.error,
      ),
      title: const Text(
        'Cerrar Sesión',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.error,
        ),
      ),
      onTap: () async {
        print('🔵 [1] Botón logout presionado');

        // Guardar el NavigatorState ANTES de cualquier operación
        final navigator = Navigator.of(context);

        // Mostrar diálogo de confirmación
        final shouldLogout = await _showLogoutConfirmationDialog(context);
        print('🔵 [2] ¿Confirmar logout? $shouldLogout');

        if (shouldLogout == true) {
          print('🔵 [3] Usuario confirmó logout');

          // Cerrar el drawer
          navigator.pop();
          print('🔵 [4] Drawer cerrado');

          print('🔵 [5] Estado ANTES del logout: ${authProvider.status}');
          print('🔵 [6] Usuario ANTES del logout: ${authProvider.user?.email}');

          // Ejecutar logout
          await authProvider.logout();

          print('🔵 [7] Estado DESPUÉS del logout: ${authProvider.status}');
          print('🔵 [8] Usuario DESPUÉS del logout: ${authProvider.user}');
          print('🔵 [9] Error si hay: ${authProvider.errorMessage}');

          // Navegar usando el NavigatorState guardado
          print('🔵 [10] Navegando al login...');
          navigator.pushNamedAndRemoveUntil(
            AppRoutes.login,
                (route) => false,
          );

          print('🔵 [11] Navegación completada');
        } else {
          print('🔵 [3] Usuario canceló logout');
        }

        print('🔵 [12] Proceso de logout terminado');
      },
    );
  }

  /// Muestra un diálogo de confirmación antes de cerrar sesión
  Future<bool?> _showLogoutConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Información de la versión de la app
  Widget _buildAppVersion() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        'EcoMora v1.0.0',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary.withOpacity(0.6),
        ),
      ),
    );
  }
}