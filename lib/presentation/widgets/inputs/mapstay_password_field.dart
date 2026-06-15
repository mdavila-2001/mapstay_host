import 'package:flutter/material.dart';
import 'mapstay_text_field.dart';

/// Campo de texto especializado para contraseñas en MapStay.
/// Controla de manera autónoma el estado de visibilidad del texto usando un StatefulWidget interno.
class MapStayPasswordTextField extends StatefulWidget {
  const MapStayPasswordTextField({
    super.key,
    required this.labelText,
    this.controller,
    this.focusNode,
    this.hintText,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.enabled = true,
  });

  /// Etiqueta superior/flotante del campo.
  final String labelText;

  /// Controlador para gestionar el valor del texto.
  final TextEditingController? controller;

  /// Nodo de enfoque opcional.
  final FocusNode? focusNode;

  /// Texto de sugerencia cuando el campo está vacío.
  final String? hintText;

  /// Icono decorativo al inicio del campo (ej. Candado).
  final Widget? prefixIcon;

  /// Función de validación para formularios.
  final String? Function(String?)? validator;

  /// Callback reactivo que se ejecuta con cada cambio de texto.
  final ValueChanged<String>? onChanged;

  /// Acción del botón de acción del teclado físico.
  final TextInputAction? textInputAction;

  /// Determina si el campo está activo o deshabilitado.
  final bool enabled;

  @override
  State<MapStayPasswordTextField> createState() => _MapStayPasswordTextFieldState();
}

class _MapStayPasswordTextFieldState extends State<MapStayPasswordTextField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MapStayTextField(
      labelText: widget.labelText,
      controller: widget.controller,
      focusNode: widget.focusNode,
      hintText: widget.hintText,
      prefixIcon: widget.prefixIcon,
      validator: widget.validator,
      onChanged: widget.onChanged,
      textInputAction: widget.textInputAction,
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      enabled: widget.enabled,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onPressed: widget.enabled ? _toggleVisibility : null,
      ),
    );
  }
}
