import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mapstay_host/presentation/providers/auth_provider.dart';
import 'package:mapstay_host/presentation/providers/property_provider.dart';
import 'package:mapstay_host/presentation/widgets/mapstay_app_bar.dart';
import 'package:mapstay_host/presentation/widgets/mapstay_drawer.dart';
import 'package:mapstay_host/presentation/widgets/mapstay_button.dart';
import 'package:mapstay_host/presentation/widgets/mapstay_toast.dart';
import 'package:mapstay_host/presentation/screens/test_component_screen.dart';
import 'package:mapstay_host/presentation/screens/property_form_screen.dart';
import 'package:mapstay_host/presentation/widgets/properties/property_card.dart';
import 'package:mapstay_host/main.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProperties();
    });
  }

  void _loadProperties() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userId != null) {
      Provider.of<PropertyProvider>(context, listen: false)
          .fetchProperties(authProvider.userId!)
          .then((_) {
            if (!mounted) return;
            final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
            if (propertyProvider.errorMessage != null) {
              MapStayToast.show(
                context,
                message: propertyProvider.errorMessage!,
                type: MapStayToastType.error,
              );
            }
          });
    }
  }

  void _handleAddNewPlace() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PropertyFormScreen()),
    ).then((_) => _loadProperties());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: MapStayAppBar(
        title: 'Mis Alojamientos',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        onLogoutPressed: () async {
          final navigator = Navigator.of(context);
          await authProvider.logout();
          navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthWrapper()),
          );
        },
      ),
      drawer: MapStayDrawer(
        currentRoute: '/properties',
        onNavigate: (route) {
          Navigator.of(context).pop();
          if (route == '/componentes') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TestComponentScreen()),
            );
          }
        },
        onLogout: () async {
          final navigator = Navigator.of(context);
          await authProvider.logout();
          navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthWrapper()),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadProperties();
        },
        color: theme.colorScheme.secondary,
        backgroundColor: theme.colorScheme.surfaceContainer,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Aquí puedes administrar y ver el estado de tus alojamientos.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),

                MapStayButton(
                  text: 'Agregar nuevo alojamiento',
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _handleAddNewPlace,
                ),
                const SizedBox(height: 32),

                if (propertyProvider.isLoading)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 2,
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) => const PropertySkeletonCard(),
                  )
                else if (propertyProvider.properties.isEmpty)
                  _buildEmptyState(theme)
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: propertyProvider.properties.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final property = propertyProvider.properties[index];
                      return PropertyCard(
                        property: property,
                        onEditPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PropertyFormScreen(property: property),
                            ),
                          ).then((_) => _loadProperties());
                        },
                        onMorePressed: () {
                          MapStayToast.show(
                            context,
                            message: 'Opciones de: ${property.nombre}',
                            type: MapStayToastType.info,
                          );
                        },
                      );
                    },
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddNewPlace,
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.home_work_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes alojamientos registrados',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza registrando tu primera propiedad para empezar a recibir huéspedes.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
