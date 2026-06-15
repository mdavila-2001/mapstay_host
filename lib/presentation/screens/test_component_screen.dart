import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mapstay_host/presentation/widgets/mapstay_button.dart';
import 'package:mapstay_host/presentation/widgets/inputs/inputs.dart';
import 'package:mapstay_host/presentation/widgets/mapstay_modal.dart';
import 'package:mapstay_host/presentation/widgets/mapstay_table.dart';
import 'package:mapstay_host/presentation/widgets/mapstay_toast.dart';
import 'package:mapstay_host/presentation/widgets/mapstay_app_bar.dart';
import 'package:mapstay_host/presentation/widgets/mapstay_drawer.dart';

class MockBooking {
  final String id;
  final String guestName;
  final String checkIn;
  final String checkOut;
  final String status;
  final double price;

  const MockBooking({
    required this.id,
    required this.guestName,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.price,
  });

  @override
  String toString() => guestName; // Fallback simple para visualización por defecto
}

class TestComponentScreen extends StatefulWidget {
  const TestComponentScreen({super.key});

  @override
  State<TestComponentScreen> createState() => _TestComponentScreenState();
}

class _TestComponentScreenState extends State<TestComponentScreen> {
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _activeRoute = '/alojamientos';

  // Lista de reservas de prueba para la tabla genérica
  final List<MockBooking> _mockBookings = const [
    MockBooking(
      id: 'B-1024',
      guestName: 'Carlos Mendoza',
      checkIn: '2026-06-15',
      checkOut: '2026-06-20',
      status: 'Confirmada',
      price: 450.00,
    ),
    MockBooking(
      id: 'B-1025',
      guestName: 'Ana Gomez',
      checkIn: '2026-06-18',
      checkOut: '2026-06-22',
      status: 'Pendiente',
      price: 320.50,
    ),
    MockBooking(
      id: 'B-1026',
      guestName: 'John Doe',
      checkIn: '2026-07-01',
      checkOut: '2026-07-08',
      status: 'Cancelada',
      price: 840.00,
    ),
    MockBooking(
      id: 'B-1027',
      guestName: 'Sophia Loren',
      checkIn: '2026-07-10',
      checkOut: '2026-07-15',
      status: 'Confirmada',
      price: 590.00,
    ),
  ];

  // Claves y controladores para el formulario de prueba de inputs
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _integerController = TextEditingController();
  final _decimalController = TextEditingController();
  final _dateController = TextEditingController();
  
  // Estado local para los selectores e imágenes
  int? _wifiValue; // Debe retornar 1 o 0 (entero)
  List<File> _selectedImages = [];

  @override
  void dispose() {
    _textController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _integerController.dispose();
    _decimalController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String appBarTitle = switch (_activeRoute) {
      '/alojamientos' => 'Mis Alojamientos',
      '/reservas' => 'Reservas Recibidas',
      '/modo_huesped' => 'Modo Huésped',
      _ => 'MapStay',
    };

    return Scaffold(
      key: _scaffoldKey,
      appBar: MapStayAppBar(
        title: appBarTitle,
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        onLogoutPressed: () {
          MapStayToast.show(
            context,
            message: 'Cerrando sesión desde el encabezado...',
            type: MapStayToastType.warning,
          );
        },
      ),
      drawer: MapStayDrawer(
        currentRoute: _activeRoute,
        onNavigate: (route) {
          _scaffoldKey.currentState?.closeDrawer();
          if (route == '/alojamientos') {
            Navigator.of(context).pop();
          } else {
            setState(() {
              _activeRoute = route;
            });
            MapStayToast.show(
              context,
              message: 'Navegando a: $route',
              type: MapStayToastType.info,
            );
          }
        },
        onLogout: () {
          _scaffoldKey.currentState?.closeDrawer();
          MapStayToast.show(
            context,
            message: 'Cerrando sesión desde el menú lateral...',
            type: MapStayToastType.error,
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Variantes de Botón (MapStayButtonVariant)'),
            const SizedBox(height: 12),
            MapStayButton(
              text: 'Primary Button',
              variant: MapStayButtonVariant.primary,
              onPressed: () {
                _showSnackBar(context, 'Primary Button Pressed');
              },
            ),
            const SizedBox(height: 12),
            MapStayButton(
              text: 'Secondary Button',
              variant: MapStayButtonVariant.secondary,
              onPressed: () {
                _showSnackBar(context, 'Secondary Button Pressed');
              },
            ),
            const SizedBox(height: 12),
            MapStayButton(
              text: 'Outline Button',
              variant: MapStayButtonVariant.outline,
              onPressed: () {
                _showSnackBar(context, 'Outline Button Pressed');
              },
            ),
            const SizedBox(height: 12),
            MapStayButton(
              text: 'Text Button',
              variant: MapStayButtonVariant.text,
              onPressed: () {
                _showSnackBar(context, 'Text Button Pressed');
              },
            ),
            
            const Divider(height: 40),
            
            _buildSectionTitle('2. Curvaturas (MapStayButtonRoundness)'),
            const SizedBox(height: 12),
            MapStayButton(
              text: 'Roundness: sm (4px)',
              roundness: MapStayButtonRoundness.sm,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            MapStayButton(
              text: 'Roundness: md (12px - Default)',
              roundness: MapStayButtonRoundness.md,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            MapStayButton(
              text: 'Roundness: lg (16px)',
              roundness: MapStayButtonRoundness.lg,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            MapStayButton(
              text: 'Roundness: full (Pill/Circular)',
              roundness: MapStayButtonRoundness.full,
              onPressed: () {},
            ),
            
            const Divider(height: 40),
            
            _buildSectionTitle('3. Botones con Iconos'),
            const SizedBox(height: 12),
            MapStayButton(
              text: 'Primary con Icono',
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            MapStayButton(
              text: 'Outline con Icono',
              icon: const Icon(Icons.settings),
              variant: MapStayButtonVariant.outline,
              onPressed: () {},
            ),
            
            const Divider(height: 40),
            
            _buildSectionTitle('4. Estados Especiales (Loading y Deshabilitado)'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MapStayButton(
                    text: 'Activar Carga',
                    onPressed: () {
                      setState(() {
                        _isLoading = !_isLoading;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            MapStayButton(
              text: 'Botón Cargando...',
              isLoading: _isLoading,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            MapStayButton(
              text: 'Botón Secundario Cargando...',
              variant: MapStayButtonVariant.secondary,
              isLoading: _isLoading,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            MapStayButton(
              text: 'Botón Outline Cargando...',
              variant: MapStayButtonVariant.outline,
              isLoading: _isLoading,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            const MapStayButton(
              text: 'Botón Deshabilitado (onPressed: null)',
              onPressed: null,
            ),
            
            const Divider(height: 40),
            
            _buildSectionTitle('5. Comportamiento del Ancho (expand: false)'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                MapStayButton(
                  text: 'Ajustado',
                  expand: false,
                  onPressed: () {},
                ),
                MapStayButton(
                  text: 'Filtro',
                  icon: const Icon(Icons.tune),
                  variant: MapStayButtonVariant.outline,
                  roundness: MapStayButtonRoundness.full,
                  expand: false,
                  onPressed: () {},
                ),
                MapStayButton(
                  icon: const Icon(Icons.share),
                  variant: MapStayButtonVariant.secondary,
                  expand: false,
                  onPressed: () {},
                ),
              ],
            ),

            const Divider(height: 40),

            _buildSectionTitle('6. Nuevos Campos de Entrada (Ecosistema Inputs)'),
            const SizedBox(height: 8),
            Text(
              'Prueba la sincronización de temas, validaciones automáticas y comportamientos específicos de la UI en este formulario.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 6.1 MapStayTextField (Base - Text)
                  MapStayTextField(
                    labelText: 'Nombre del Alojamiento',
                    controller: _textController,
                    hintText: 'Ej. Modern Penthouse',
                    prefixIcon: const Icon(Icons.home_outlined),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 6.2 MapStayTextField (Base - Email)
                  MapStayTextField(
                    labelText: 'Correo Electrónico de Contacto',
                    controller: _emailController,
                    isEmail: true,
                    hintText: 'ejemplo@mapstay.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  const SizedBox(height: 20),

                  // 6.3 MapStayPasswordTextField (Password)
                  MapStayPasswordTextField(
                    labelText: 'Contraseña de Confirmación',
                    controller: _passwordController,
                    hintText: 'Ingrese su contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 6.4 MapStayNumberTextField (Integer Counters)
                  Row(
                    children: [
                      Expanded(
                        child: MapStayNumberTextField(
                          labelText: 'Personas',
                          controller: _integerController,
                          hintText: 'Ej. 4',
                          prefixIcon: const Icon(Icons.people_outline),
                          isDecimal: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Requerido';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 6.5 MapStayNumberTextField (Decimal Financials)
                      Expanded(
                        child: MapStayNumberTextField(
                          labelText: 'Precio por Noche',
                          controller: _decimalController,
                          hintText: 'Ej. 85.50',
                          prefixIcon: const Icon(Icons.attach_money_rounded),
                          isDecimal: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Requerido';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 6.6 MapStayDateTextField (Native DatePicker Sync)
                  MapStayDateTextField(
                    labelText: 'Fecha de Disponibilidad Inicial',
                    controller: _dateController,
                    hintText: 'Seleccionar fecha',
                    prefixIcon: const Icon(Icons.date_range_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Seleccione una fecha válida';
                      }
                      return null;
                    },
                    onDateSelected: (date) {
                      debugPrint('Fecha limpia seleccionada: $date');
                    },
                  ),
                  const SizedBox(height: 20),

                  // 6.7 MapStaySelectField (Dropdown & Binary 1/0 Mapping)
                  MapStaySelectField<int>(
                    labelText: '¿Tiene servicio de Wi-Fi?',
                    value: _wifiValue,
                    options: MapStayOption.binary(
                      trueLabel: 'Sí, incluye Wi-Fi de alta velocidad',
                      falseLabel: 'No, no incluye conexión a internet',
                    ),
                    prefixIcon: const Icon(Icons.wifi_rounded),
                    onChanged: (val) {
                      setState(() {
                        _wifiValue = val;
                      });
                      debugPrint('Valor binario seleccionado para la base de datos: $val (tipo: ${val.runtimeType})');
                    },
                    validator: (val) {
                      if (val == null) {
                        return 'Por favor seleccione una opción';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 6.8 MapStayImageField (Multimedia Grid)
                  MapStayImageField(
                    labelText: 'Fotos del Alojamiento (Mín. 1, Máx. 6)',
                    maxImages: 6,
                    onImagesChanged: (images) {
                      setState(() {
                        _selectedImages = images;
                      });
                      debugPrint('Lista actual de archivos File: ${images.map((f) => f.path).toList()}');
                    },
                  ),
                  const SizedBox(height: 32),

                  // Botón de Enviar Formulario para verificar validaciones
                  MapStayButton(
                    text: 'Validar y Guardar Formulario',
                    icon: const Icon(Icons.save_outlined),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedImages.isEmpty) {
                          _showSnackBar(context, '⚠️ Por favor agregue al menos una foto');
                          return;
                        }
                        
                        // Si todo es válido, mostramos los payloads resultantes listos para el backend
                        final String message = 
                          '¡Datos Validados!\n'
                          'Email: ${_emailController.text}\n'
                          'Personas: ${_integerController.text}\n'
                          'Precio: ${_decimalController.text}\n'
                          'Fecha: ${_dateController.text}\n'
                          'Wi-Fi (DB Payload): $_wifiValue\n'
                          'Fotos a subir: ${_selectedImages.length} archivos';
                          
                        _showSnackBar(context, message, durationSeconds: 5);
                      } else {
                        _showSnackBar(context, '❌ Corrige los errores en el formulario');
                      }
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 40),

            _buildSectionTitle('7. Modales y Ventanas Emergentes (MapStayModal)'),
            const SizedBox(height: 8),
            Text(
              'Prueba diálogos centrados y bottom sheets interactivos optimizados para teclado y áreas seguras.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MapStayButton(
                    text: 'Bottom Sheet Informativo',
                    variant: MapStayButtonVariant.secondary,
                    onPressed: () {
                      MapStayModal.showBottomSheet(
                        context,
                        title: 'Términos y Condiciones',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Al publicar un alojamiento en MapStay, aceptas seguir nuestras directrices de hospitalidad y calidad. Es obligatorio mantener la información de precios y disponibilidad al día.',
                              style: TextStyle(height: 1.5),
                            ),
                            const SizedBox(height: 24),
                            MapStayButton(
                              text: 'Entendido',
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MapStayButton(
                    text: 'Bottom Sheet con Formulario',
                    variant: MapStayButtonVariant.outline,
                    onPressed: () {
                      final controller = TextEditingController();
                      MapStayModal.showBottomSheet(
                        context,
                        title: 'Agregar Comentario Rápido',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MapStayTextField(
                              labelText: 'Comentario',
                              controller: controller,
                              hintText: 'Escribe algo aquí...',
                            ),
                            const SizedBox(height: 24),
                            MapStayButton(
                              text: 'Guardar Comentario',
                              onPressed: () {
                                Navigator.pop(context);
                                _showSnackBar(context, 'Comentario guardado: ${controller.text}');
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MapStayButton(
                    text: 'Diálogo Centrado de Alerta',
                    variant: MapStayButtonVariant.primary,
                    onPressed: () {
                      MapStayModal.showCustomDialog(
                        context,
                        title: '¿Eliminar Publicación?',
                        content: const Text(
                          'Esta acción es irreversible y tu propiedad dejará de estar visible para los huéspedes de inmediato. ¿Deseas continuar?',
                          style: TextStyle(height: 1.5),
                        ),
                        actions: [
                          MapStayButton(
                            text: 'Cancelar',
                            variant: MapStayButtonVariant.text,
                            expand: false,
                            onPressed: () => Navigator.pop(context),
                          ),
                          MapStayButton(
                            text: 'Eliminar',
                            variant: MapStayButtonVariant.primary,
                            expand: false,
                            onPressed: () {
                              Navigator.pop(context);
                              _showSnackBar(context, 'Publicación eliminada correctamente.');
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            const Divider(height: 40),

            _buildSectionTitle('8. Tablas Genéricas y Responsivas (MapStayTable)'),
            const SizedBox(height: 8),
            Text(
              'Prueba la visualización de datos estructurados. Soporta celdas polimórficas (badges, avatares, botones) y scroll horizontal.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            _buildSubSectionTitle('8.1 Tabla Compacta (Flex Proporcional)'),
            const SizedBox(height: 12),
            MapStayTable<MockBooking>(
              data: _mockBookings,
              useZebraStriping: true,
              horizontalScroll: false,
              onRowTap: (booking) {
                _showSnackBar(context, 'Reserva presionada: ${booking.guestName}');
              },
              columns: [
                MapStayColumnConfig<MockBooking>(
                  title: 'Huésped',
                  key: 'guest',
                  flex: 2,
                  render: (booking) => Text(
                    booking.guestName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                MapStayColumnConfig<MockBooking>(
                  title: 'Entrada',
                  key: 'checkin',
                  flex: 2,
                  align: MapStayTableAlign.center,
                  render: (booking) => Text(booking.checkIn),
                ),
                MapStayColumnConfig<MockBooking>(
                  title: 'Precio',
                  key: 'price',
                  flex: 1,
                  align: MapStayTableAlign.right,
                  render: (booking) => Text('\$${booking.price.toStringAsFixed(2)}'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSubSectionTitle('8.2 Tabla Completa (Scroll Horizontal y Celdas Polimórficas)'),
            const SizedBox(height: 12),
            MapStayTable<MockBooking>(
              data: _mockBookings,
              useZebraStriping: true,
              horizontalScroll: true,
              onRowTap: (booking) {
                _showSnackBar(context, 'Detalles de reserva: ${booking.id}');
              },
              columns: [
                MapStayColumnConfig<MockBooking>(
                  title: 'ID',
                  key: 'id',
                  width: 80,
                  render: (booking) => Text(
                    booking.id,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                MapStayColumnConfig<MockBooking>(
                  title: 'Huésped',
                  key: 'guest',
                  width: 140,
                  render: (booking) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          booking.guestName[0],
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking.guestName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                MapStayColumnConfig<MockBooking>(
                  title: 'Check-In',
                  key: 'checkin',
                  width: 100,
                  align: MapStayTableAlign.center,
                  render: (booking) => Text(booking.checkIn),
                ),
                MapStayColumnConfig<MockBooking>(
                  title: 'Check-Out',
                  key: 'checkout',
                  width: 100,
                  align: MapStayTableAlign.center,
                  render: (booking) => Text(booking.checkOut),
                ),
                MapStayColumnConfig<MockBooking>(
                  title: 'Estado',
                  key: 'status',
                  width: 120,
                  align: MapStayTableAlign.center,
                  render: (booking) {
                    final color = switch (booking.status) {
                      'Confirmada' => Colors.greenAccent,
                      'Pendiente' => Colors.orangeAccent,
                      'Cancelada' => Colors.redAccent,
                      _ => Colors.grey,
                    };
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        booking.status,
                        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
                MapStayColumnConfig<MockBooking>(
                  title: 'Total',
                  key: 'total',
                  width: 90,
                  align: MapStayTableAlign.right,
                  render: (booking) => Text(
                    '\$${booking.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                MapStayColumnConfig<MockBooking>(
                  title: 'Acción',
                  key: 'actions',
                  width: 80,
                  align: MapStayTableAlign.center,
                  render: (booking) => IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onPressed: () {
                      _showSnackBar(context, 'Abriendo detalles para ${booking.id}');
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
            const Divider(height: 40),

            _buildSectionTitle('9. Notificaciones Efímeras (MapStayToast)'),
            const SizedBox(height: 8),
            Text(
              'Prueba la emisión de alertas flotantes instantáneas sincronizadas con nuestro Design System.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                MapStayButton(
                  text: 'Toast Éxito',
                  variant: MapStayButtonVariant.primary,
                  expand: false,
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: () {
                    MapStayToast.show(
                      context,
                      message: '¡La propiedad ha sido publicada exitosamente!',
                      type: MapStayToastType.success,
                    );
                  },
                ),
                MapStayButton(
                  text: 'Toast Info',
                  variant: MapStayButtonVariant.secondary,
                  expand: false,
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    MapStayToast.show(
                      context,
                      message: 'Sincronizando el calendario con canales externos...',
                      type: MapStayToastType.info,
                    );
                  },
                ),
                MapStayButton(
                  text: 'Toast Alerta',
                  variant: MapStayButtonVariant.outline,
                  expand: false,
                  icon: const Icon(Icons.warning_amber_rounded),
                  onPressed: () {
                    MapStayToast.show(
                      context,
                      message: 'Quedan pocas horas para confirmar la solicitud pendiente.',
                      type: MapStayToastType.warning,
                    );
                  },
                ),
                MapStayButton(
                  text: 'Toast Error',
                  variant: MapStayButtonVariant.outline,
                  expand: false,
                  icon: const Icon(Icons.error_outline),
                  onPressed: () {
                    MapStayToast.show(
                      context,
                      message: 'Error de red. No se pudieron cargar los datos de facturación.',
                      type: MapStayToastType.error,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, {int durationSeconds = 2}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: durationSeconds),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
