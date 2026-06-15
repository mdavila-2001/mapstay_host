import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mapstay_host/presentation/providers/auth_provider.dart';
import 'package:mapstay_host/presentation/providers/property_provider.dart';
import 'package:mapstay_host/domain/entities/property.dart';
import 'package:mapstay_host/presentation/widgets/mapstay_app_bar.dart';
import 'package:mapstay_host/presentation/widgets/mapstay_drawer.dart';
import 'package:mapstay_host/presentation/widgets/mapstay_button.dart';
import 'package:mapstay_host/presentation/widgets/mapstay_toast.dart';
import 'package:mapstay_host/presentation/screens/test_component_screen.dart';
import 'package:mapstay_host/main.dart';

/// Pantalla de Dashboard principal para el Anfitrión (Host Dashboard).
/// Sigue principios SOLID (Separación de Responsabilidades) y Material 3 Dark First.
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
    // Inicia la carga de alojamientos asíncronamente al entrar a la pantalla
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
    MapStayToast.show(
      context,
      message: 'El formulario para registrar un nuevo alojamiento estará disponible próximamente.',
      type: MapStayToastType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      // 1. Encabezado de la App (Componente Propio)
      appBar: MapStayAppBar(
        title: 'Host Dashboard',
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
      // Menu lateral (Componente Propio)
      drawer: MapStayDrawer(
        currentRoute: '/alojamientos',
        onNavigate: (route) {
          Navigator.of(context).pop(); // Cierra el Drawer
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
                // Cabecera de bienvenida
                Text(
                  '¡Te damos la bienvenida, ${authProvider.userName ?? "Anfitrión"}!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Aquí puedes administrar y ver el estado de tus alojamientos.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),

                // Botón "Agregar nuevo alojamiento" antes de la lista
                MapStayButton(
                  text: 'Agregar nuevo alojamiento',
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _handleAddNewPlace,
                ),
                const SizedBox(height: 32),

                // Fila de encabezado de sección
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Managed Properties',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        MapStayToast.show(
                          context,
                          message: 'Mostrando todas las propiedades.',
                          type: MapStayToastType.info,
                        );
                      },
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Lista Dinámica de Alojamientos
                if (propertyProvider.isLoading)
                  // Skeleton Loader mientras carga
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 2,
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) => const _PropertySkeletonCard(),
                  )
                else if (propertyProvider.properties.isEmpty)
                  // Estado vacío elegante si no hay alojamientos
                  _buildEmptyState(theme)
                else
                  // Listado real de tarjetas de alojamientos
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: propertyProvider.properties.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final property = propertyProvider.properties[index];
                      return _PropertyCard(
                        property: property,
                        onEditPressed: () {
                          MapStayToast.show(
                            context,
                            message: 'Editar: ${property.nombre}',
                            type: MapStayToastType.info,
                          );
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
                const SizedBox(height: 80), // Margen inferior para que el FAB no tape contenido
              ],
            ),
          ),
        ),
      ),
      // 4. Botón Flotante (FAB) Teal Cuadrado (Bordes redondeados 12px)
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

/// Tarjeta de propiedad interna para optimizar el árbol de renderizado de Flutter.
class _PropertyCard extends StatelessWidget {
  const _PropertyCard({
    required this.property,
    required this.onEditPressed,
    required this.onMorePressed,
  });

  final Property property;
  final VoidCallback onEditPressed;
  final VoidCallback onMorePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer, // Fondo #171F33
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen 16:9 con Badge flotante
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    property.firstPhoto,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: theme.colorScheme.surfaceContainerHigh,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.colorScheme.surfaceContainerHigh,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                          size: 48,
                        ),
                      );
                    },
                  ),
                  // Badge de estado flotante arriba a la derecha
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: property.activo ? const Color(0xFF20B2AA) : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            property.activo ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: property.activo ? const Color(0xFF20B2AA) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bloque Informativo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  property.nombre,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  property.descripcion.isNotEmpty 
                      ? property.descripcion 
                      : 'Sin descripción detallada.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // Línea divisoria fina
                Divider(
                  height: 1, 
                  thickness: 1, 
                  color: theme.colorScheme.outline.withValues(alpha: 0.15),
                ),
                const SizedBox(height: 12),
                
                // Precio e iconos de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '\$${property.precioNoche.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.secondary, // Sea Green / Teal
                            ),
                          ),
                          TextSpan(
                            text: ' / night (${property.ciudad})',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: onEditPressed,
                          icon: const Icon(Icons.edit_outlined),
                          color: theme.colorScheme.onSurfaceVariant,
                          tooltip: 'Editar alojamiento',
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          onPressed: onMorePressed,
                          icon: const Icon(Icons.more_vert_rounded),
                          color: theme.colorScheme.onSurfaceVariant,
                          tooltip: 'Más opciones',
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton Loader para la tarjeta de propiedad.
class _PropertySkeletonCard extends StatelessWidget {
  const _PropertySkeletonCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surfaceContainerHigh;
    final highlightColor = theme.colorScheme.surfaceContainer;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Espacio para la imagen
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
          ),
          // Espacio para la información
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Container(
                  width: 150,
                  height: 18,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                // Descripción (Línea 1)
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: highlightColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                // Descripción (Línea 2)
                Container(
                  width: 250,
                  height: 12,
                  decoration: BoxDecoration(
                    color: highlightColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                // Divisor
                Divider(height: 1, thickness: 1, color: highlightColor),
                const SizedBox(height: 12),
                // Pie de tarjeta
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      height: 16,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 24,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
