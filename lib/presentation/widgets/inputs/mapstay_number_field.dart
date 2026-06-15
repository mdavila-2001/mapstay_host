import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mapstay_text_field.dart';

/// Campo de texto especializado para números en MapStay.
/// Permite discriminar entre enteros (para contadores) y decimales (para finanzas).
class MapStayNumberTextField extends StatelessWidget {
  const MapStayNumberTextField({
    super.key,
    required this.labelText,
    this.controller,
    this.focusNode,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.isDecimal = false,
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

  /// Icono decorativo al inicio del campo.
  final Widget? prefixIcon;

  /// Icono decorativo al final del campo.
  final Widget? suffixIcon;

  /// Función de validación para formularios.
  final String? Function(String?)? validator;

  /// Callback reactivo que se ejecuta con cada cambio de texto.
  final ValueChanged<String>? onChanged;

  /// Acción del botón de acción del teclado físico.
  final TextInputAction? textInputAction;

  /// Indica si el campo acepta números decimales (precios, costos) o solo enteros (contadores).
  final bool isDecimal;

  /// Determina si el campo está activo o deshabilitado.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final List<TextInputFormatter> formatters = [];

    if (isDecimal) {
      formatters.add(DecimalTextInputFormatter());
    } else {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }

    return MapStayTextField(
      labelText: labelText,
      controller: controller,
      focusNode: focusNode,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      validator: validator,
      onChanged: onChanged,
      keyboardType: TextInputType.numberWithOptions(
        decimal: isDecimal,
        signed: false,
      ),
      textInputAction: textInputAction,
      enabled: enabled,
      inputFormatters: formatters,
    );
  }
}

/// Formateador personalizado para restringir la entrada a un formato decimal financiero válido.
/// Permite un solo punto o coma, y hasta un máximo de 2 dígitos decimales.
class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Expresión regular que permite dígitos opcionales, seguidos de un único
    // separador decimal opcional (punto o coma), y hasta 2 dígitos para la parte decimal.
    final regExp = RegExp(r'^\d*[\.,]?\d{0,2}$');
    
    if (regExp.hasMatch(newValue.text)) {
      // Reemplaza comas por puntos de manera transparente para estandarizar el guardado en base de datos.
      final standardizedText = newValue.text.replaceAll(',', '.');
      return newValue.copyWith(
        text: standardizedText,
        selection: TextSelection.collapsed(offset: standardizedText.length),
      );
    }

    return oldValue;
  }
}
