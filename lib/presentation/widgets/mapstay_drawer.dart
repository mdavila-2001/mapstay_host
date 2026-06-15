import 'package:flutter/material.dart';
import 'mapstay_button.dart';

class MapStayDrawer extends StatelessWidget {
  const MapStayDrawer({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    required this.onLogout,
  });

  final String currentRoute;
  final ValueChanged<String> onNavigate;

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: const Color(0xFF131B2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MapStay',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Anfitriones',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1, thickness: 1, color: Color(0xFF334155)),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                children: [
                  _buildDrawerItem(
                    context: context,
                    title: 'Mis Alojamientos',
                    icon: Icons.home_work_outlined,
                    routeName: '/alojamientos',
                  ),
                  const SizedBox(height: 8),
                  _buildDrawerItem(
                    context: context,
                    title: 'Ver Reservas Recibidas',
                    icon: Icons.date_range_outlined,
                    routeName: '/reservas',
                  ),
                  const SizedBox(height: 8),
                  _buildDrawerItem(
                    context: context,
                    title: 'Página de componentes',
                    icon: Icons.swap_horiz_rounded,
                    routeName: '/componentes',
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1, thickness: 1, color: Color(0xFF334155)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: MapStayButton(
                text: 'Cerrar Sesión',
                icon: const Icon(Icons.logout_rounded),
                variant: MapStayButtonVariant.outline,
                onPressed: onLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String routeName,
  }) {
    final theme = Theme.of(context);
    final bool isActive = currentRoute == routeName;

    return InkWell(
      onTap: () => onNavigate(routeName),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.surfaceContainerHigh
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
