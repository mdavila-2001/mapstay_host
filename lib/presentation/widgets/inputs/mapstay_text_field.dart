import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo de texto base para MapStay.
/// Sincronizado automáticamente con el tema de la aplicación.
class MapStayTextField extends StatelessWidget {
  const MapStayTextField({
    super.key,
    required this.labelText,
    this.controller,
    this.focusNode,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.isEmail = false,
    this.enabled = true,
    this.inputFormatters,
    this.maxLines = 1,
  });

  /// Etiqueta superior/flotante del campo.
  final String labelText;

  /// Controlador para gestionar el valor del texto.
  final TextEditingController? controller;

  /// Nodo de enfoque opcional.
  final FocusNode? focusNode;

  /// Texto de sugerencia cuando el campo está vacío.
  final String? hintText;

  /// Icono decorativo al inicio del campo.
  final Widget? prefixIcon;

  /// Icono decorativo al final del campo.
  final Widget? suffixIcon;

  /// Función de validación para formularios.
  final String? Function(String?)? validator;

  /// Callback reactivo que se ejecuta con cada cambio de texto.
  final ValueChanged<String>? onChanged;

  /// Tipo de teclado del sistema.
  final TextInputType? keyboardType;

  /// Acción del botón de acción del teclado físico.
  final TextInputAction? textInputAction;

  /// Determina si se oculta el texto introducido (útil para contraseñas).
  final bool obscureText;

  /// Si es true, el campo será de solo lectura y no abrirá el teclado.
  final bool readOnly;

  /// Callback que se activa al presionar el campo.
  final VoidCallback? onTap;

  /// Si es true, fuerza el comportamiento y la validación de email.
  final bool isEmail;

  /// Determina si el campo está activo o deshabilitado.
  final bool enabled;

  /// Formateadores opcionales para la entrada de texto.
  final List<TextInputFormatter>? inputFormatters;

  /// Número máximo de líneas (por defecto es 1).
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium;

    // Validador por defecto para emails
    String? defaultEmailValidator(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'El correo electrónico es requerido';
      }
      // Expresión regular estándar para validación de email
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value.trim())) {
        return 'Ingrese un correo electrónico válido';
      }
      return null;
    }

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      enabled: enabled,
      style: textStyle,
      maxLines: maxLines,
      keyboardType: isEmail ? TextInputType.emailAddress : keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      validator: validator ?? (isEmail ? defaultEmailValidator : null),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        // El color del texto de error se fuerza al colorScheme.error
        errorStyle: TextStyle(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}
