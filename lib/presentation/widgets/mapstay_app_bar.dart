import 'package:flutter/material.dart';

/// Encabezado (AppBar) personalizado de MapStay.
/// Sincronizado estéticamente con Material 3 y el Design System de la app.
class MapStayAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MapStayAppBar({
    super.key,
    required this.title,
    required this.onMenuPressed,
    required this.onLogoutPressed,
  });

  /// Título centrado que se muestra en el AppBar.
  final String title;

  /// Callback que se ejecuta al presionar el botón de menú hamburguesa (Leading).
  final VoidCallback onMenuPressed;

  /// Callback que se ejecuta al presionar el botón de cerrar sesión (Actions).
  final VoidCallback onLogoutPressed;

  @override
  Size get preferredSize => const Size.fromHeight(56.0); // Altura física estándar

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        tooltip: 'Abrir menú',
        onPressed: onMenuPressed,
        color: theme.colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20, // headlineSmall equivalente
          fontWeight: FontWeight.w600, // peso 600
        ),
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: true,
      backgroundColor: theme.colorScheme.surfaceContainer, // Fondo #171F33
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Cerrar sesión',
          onPressed: onLogoutPressed,
          color: theme.colorScheme.onSurface,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: const Color(0xFF334155),
          height: 1.0,
        ),
      ),
    );
  }
}
