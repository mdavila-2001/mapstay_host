import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/property.dart';
import '../providers/auth_provider.dart';
import '../providers/property_provider.dart';
import '../widgets/inputs/inputs.dart';
import '../widgets/mapstay_button.dart';
import '../widgets/mapstay_toast.dart';
import '../widgets/mapstay_app_bar.dart';

class PropertyFormScreen extends StatefulWidget {
  const PropertyFormScreen({
    super.key,
    this.property,
  });

  final Property? property;

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  int _currentStep = 0;

  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _precioNocheController;
  late TextEditingController _costoLimpiezaController;
  late TextEditingController _cantPersonasController;
  late TextEditingController _cantCamasController;
  late TextEditingController _cantBaniosController;
  late TextEditingController _cantHabitacionesController;
  late TextEditingController _cantVehiculosParqueoController;

  String _ciudad = 'Santa Cruz';
  bool _tieneWifi = false;
  List<File> _selectedImages = [];

  late String _latitud;
  late String _longitud;
  MapController? _mapController;

  bool get _isEditing => widget.property != null;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    final p = widget.property;

    _nombreController = TextEditingController(text: p?.nombre ?? '');
    _descripcionController = TextEditingController(text: p?.descripcion ?? '');
    _precioNocheController = TextEditingController(text: p?.precioNoche != null ? p!.precioNoche.toStringAsFixed(2) : '');
    _costoLimpiezaController = TextEditingController(text: p?.costoLimpieza != null ? p!.costoLimpieza.toStringAsFixed(2) : '');

    _cantPersonasController = TextEditingController(text: p?.cantPersonas.toString() ?? '1');
    _cantCamasController = TextEditingController(text: p?.cantCamas.toString() ?? '1');
    _cantBaniosController = TextEditingController(text: p?.cantBanios.toString() ?? '1');
    _cantHabitacionesController = TextEditingController(text: p?.cantHabitaciones.toString() ?? '1');
    _cantVehiculosParqueoController = TextEditingController(text: p?.cantVehiculosParqueo.toString() ?? '0');

    _ciudad = p?.ciudad ?? 'Santa Cruz';
    _tieneWifi = p?.tieneWifi ?? false;

    _latitud = p?.latitud ?? '-17.7828';
    _longitud = p?.longitud ?? '-63.1806';

    _selectedImages = [];
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioNocheController.dispose();
    _costoLimpiezaController.dispose();
    _cantPersonasController.dispose();
    _cantCamasController.dispose();
    _cantBaniosController.dispose();
    _cantHabitacionesController.dispose();
    _cantVehiculosParqueoController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  LatLng _getCityCoordinates(String city) {
    switch (city) {
      case 'Santa Cruz':
        return const LatLng(-17.7828, -63.1806);
      case 'La Paz':
        return const LatLng(-16.4897, -68.1193);
      case 'Cochabamba':
        return const LatLng(-17.3895, -66.1568);
      case 'Sucre':
        return const LatLng(-19.0333, -65.2627);
      case 'Tarija':
        return const LatLng(-21.5353, -64.7296);
      case 'Oruro':
        return const LatLng(-17.9833, -67.1500);
      case 'Potosí':
        return const LatLng(-19.5836, -65.7531);
      case 'Beni':
        return const LatLng(-14.8333, -64.9000);
      case 'Pando':
        return const LatLng(-11.0267, -68.7692);
      default:
        return const LatLng(-17.7828, -63.1806);
    }
  }

  void _goToStep2() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _currentStep = 1;
      });
      
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      if (!_isEditing) {
        final coords = _getCityCoordinates(_ciudad);
        setState(() {
          _latitud = coords.latitude.toString();
          _longitud = coords.longitude.toString();
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController?.move(coords, 14.5);
        });
      } else {
        final coords = LatLng(
          double.tryParse(_latitud) ?? -17.7828,
          double.tryParse(_longitud) ?? -63.1806,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController?.move(coords, 14.5);
        });
      }
    } else {
      MapStayToast.show(
        context,
        message: 'Por favor complete todos los campos requeridos correctamente.',
        type: MapStayToastType.error,
      );
    }
  }

  void _goToStep1() {
    setState(() {
      _currentStep = 0;
    });
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitForm() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);

    if (authProvider.userId == null) {
      MapStayToast.show(
        context,
        message: 'Sesión inválida o expirada.',
        type: MapStayToastType.error,
      );
      return;
    }

    final double price = double.tryParse(_precioNocheController.text) ?? 0.0;
    final double cleaning = double.tryParse(_costoLimpiezaController.text) ?? 0.0;
    final int persons = int.tryParse(_cantPersonasController.text) ?? 1;
    final int beds = int.tryParse(_cantCamasController.text) ?? 1;
    final int baths = int.tryParse(_cantBaniosController.text) ?? 1;
    final int rooms = int.tryParse(_cantHabitacionesController.text) ?? 1;
    final int parking = int.tryParse(_cantVehiculosParqueoController.text) ?? 0;

    final success = await propertyProvider.saveProperty(
      id: widget.property?.id,
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      precioNoche: price,
      costoLimpieza: cleaning,
      cantPersonas: persons,
      cantCamas: beds,
      cantBanios: baths,
      cantHabitaciones: rooms,
      cantVehiculosParqueo: parking,
      tieneWifi: _tieneWifi,
      latitud: _latitud,
      longitud: _longitud,
      ciudad: _ciudad,
      hostId: authProvider.userId!,
      imageFiles: _selectedImages,
    );

    if (!mounted) return;

    if (success) {
      MapStayToast.show(
        context,
        message: _isEditing 
            ? 'Alojamiento actualizado con éxito.' 
            : 'Alojamiento creado con éxito.',
        type: MapStayToastType.success,
      );
      Navigator.of(context).pop();
    } else {
      MapStayToast.show(
        context,
        message: propertyProvider.errorMessage ?? 'Ocurrió un error al guardar.',
        type: MapStayToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);

    return Scaffold(
      appBar: MapStayAppBar(
        title: _isEditing ? 'Editar Alojamiento' : 'Registrar Alojamiento',
        onMenuPressed: () => Navigator.of(context).pop(),
        isBackButton: true,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildStep1(theme, propertyProvider),
          _buildStep2(theme, propertyProvider),
        ],
      ),
    );
  }

  Widget _buildStep1(ThemeData theme, PropertyProvider provider) {
    return Form(
      key: _formKey,
      child: KeyboardAvoidingView(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Paso ${_currentStep + 1} de 2: Metadatos y Precios',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Siguiente: Ubicación',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 0.5,
                backgroundColor: theme.colorScheme.surfaceContainer,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 24),

              MapStayImageField(
                labelText: 'Fotos del lugar',
                onImagesChanged: (files) {
                  setState(() {
                    _selectedImages = files;
                  });
                },
                initialImages: _selectedImages,
                maxImages: 6,
              ),
              const SizedBox(height: 24),

              MapStayTextField(
                labelText: 'Nombre del lugar',
                controller: _nombreController,
                hintText: 'Ej. Cabaña Rústica con Vista al Río',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'El nombre del lugar es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              MapStayTextField(
                labelText: 'Descripción',
                controller: _descripcionController,
                maxLines: 3,
                hintText: 'Detalla los espacios, reglas y comodidades...',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'La descripción es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              MapStaySelectField<String>(
                labelText: 'Ciudad',
                value: _ciudad,
                options: const [
                  MapStayOption(value: 'Santa Cruz', label: 'Santa Cruz'),
                  MapStayOption(value: 'La Paz', label: 'La Paz'),
                  MapStayOption(value: 'Cochabamba', label: 'Cochabamba'),
                  MapStayOption(value: 'Sucre', label: 'Sucre'),
                  MapStayOption(value: 'Tarija', label: 'Tarija'),
                  MapStayOption(value: 'Oruro', label: 'Oruro'),
                  MapStayOption(value: 'Potosí', label: 'Potosí'),
                  MapStayOption(value: 'Beni', label: 'Beni'),
                  MapStayOption(value: 'Pando', label: 'Pando'),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _ciudad = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: MapStayNumberTextField(
                      labelText: 'Precio / Noche (\$)',
                      controller: _precioNocheController,
                      isDecimal: true,
                      hintText: '0.00',
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Requerido';
                        }
                        if (double.tryParse(val) == null) {
                          return 'Número inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MapStayNumberTextField(
                      labelText: 'Costo Limpieza (\$)',
                      controller: _costoLimpiezaController,
                      isDecimal: true,
                      hintText: '0.00',
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Requerido';
                        }
                        if (double.tryParse(val) == null) {
                          return 'Número inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                'Capacidad Física',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  MapStayNumberTextField(
                    labelText: 'Personas',
                    controller: _cantPersonasController,
                    hintText: '1',
                    isDecimal: false,
                    validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                  ),
                  MapStayNumberTextField(
                    labelText: 'Camas',
                    controller: _cantCamasController,
                    hintText: '1',
                    isDecimal: false,
                    validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                  ),
                  MapStayNumberTextField(
                    labelText: 'Baños',
                    controller: _cantBaniosController,
                    hintText: '1',
                    isDecimal: false,
                    validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                  ),
                  MapStayNumberTextField(
                    labelText: 'Habitaciones',
                    controller: _cantHabitacionesController,
                    hintText: '1',
                    isDecimal: false,
                    validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MapStayNumberTextField(
                labelText: 'Vehículos en parqueo',
                controller: _cantVehiculosParqueoController,
                hintText: '0',
                isDecimal: false,
                validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: SwitchListTile(
                  title: const Text('Tiene Wi-Fi'),
                  subtitle: const Text('Ofrece conexión inalámbrica rápida'),
                  value: _tieneWifi,
                  activeThumbColor: theme.colorScheme.secondary,
                  onChanged: (val) {
                    setState(() {
                      _tieneWifi = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),

              MapStayButton(
                text: 'Continuar a Ubicación',
                icon: const Icon(Icons.arrow_forward_rounded),
                onPressed: _goToStep2,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2(ThemeData theme, PropertyProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Paso ${_currentStep + 1} de 2: Geolocalización',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToStep1,
                    child: Text(
                      'Volver a Info',
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 1.0,
                backgroundColor: theme.colorScheme.surfaceContainer,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),

        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _getCityCoordinates(_ciudad),
                  initialZoom: 15.0,
                  maxZoom: 18.0,
                  minZoom: 10.0,
                  onPositionChanged: (position, hasGesture) {
                    if (position.center != null) {
                      setState(() {
                        _latitud = position.center!.latitude.toString();
                        _longitud = position.center!.longitude.toString();
                      });
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.mapstay.host',
                  ),
                ],
              ),

              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: Icon(
                    Icons.location_on,
                    color: theme.colorScheme.secondary,
                    size: 48,
                    shadows: const [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(0, 4),
                        blurRadius: 6,
                      )
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.map_outlined, color: theme.colorScheme.secondary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ubicación Fijada',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Lat: ${double.tryParse(_latitud)?.toStringAsFixed(6)}, Lng: ${double.tryParse(_longitud)?.toStringAsFixed(6)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MapStayButton(
                text: 'Guardar Alojamiento',
                icon: const Icon(Icons.check_circle_outline),
                isLoading: provider.isLoading,
                onPressed: _submitForm,
              ),
              const SizedBox(height: 8),
              MapStayButton(
                text: 'Volver al formulario',
                variant: MapStayButtonVariant.outline,
                onPressed: _goToStep1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class KeyboardAvoidingView extends StatelessWidget {
  const KeyboardAvoidingView({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: child,
    );
  }
}
