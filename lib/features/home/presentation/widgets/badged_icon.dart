import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';


/// Widget que muestra un ícono con un badge de notificaciones
///
/// Ejemplo de uso:
/// ```dart
/// BadgedIcon(
///   icon: Icons.notifications_outlined,
///   count: 5,
///   onPressed: () => _showAlertsDialog(),
/// )
/// ```
class BadgedIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color iconColor;
  final Color badgeColor;
  final double iconSize;
  final VoidCallback? onPressed;
  final String? tooltip;

  const BadgedIcon({
    super.key,
    required this.icon,
    required this.count,
    this.iconColor = Colors.white,
    this.badgeColor = AppColors.error,
    this.iconSize = 24,
    this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(icon, color: iconColor, size: iconSize),
          onPressed: onPressed,
          tooltip: tooltip,
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding:  EdgeInsets.symmetric(
                horizontal: count > 9 ? 5 : 6,
                vertical: 2,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}