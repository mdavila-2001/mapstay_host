import 'package:flutter/material.dart';

class MapStayAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MapStayAppBar({
    super.key,
    required this.title,
    required this.onMenuPressed,
    this.onLogoutPressed,
    this.isBackButton = false,
  });

  final String title;
  final VoidCallback onMenuPressed;
  final VoidCallback? onLogoutPressed;
  final bool isBackButton;

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      leading: IconButton(
        icon: Icon(isBackButton ? Icons.arrow_back_rounded : Icons.menu),
        tooltip: isBackButton ? 'Volver' : 'Abrir menú',
        onPressed: onMenuPressed,
        color: theme.colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: true,
      backgroundColor: theme.colorScheme.surfaceContainer,
      elevation: 0,
      actions: [
        if (onLogoutPressed != null)
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
