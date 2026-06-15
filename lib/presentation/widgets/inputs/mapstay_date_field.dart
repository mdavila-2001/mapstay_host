import 'package:flutter/material.dart';
import 'mapstay_text_field.dart';

/// Campo especializado para seleccionar fechas en MapStay.
/// Abre de forma transparente el showDatePicker nativo y formatea la fecha en YYYY-MM-DD.
class MapStayDateTextField extends StatelessWidget {
  const MapStayDateTextField({
    super.key,
    required this.labelText,
    required this.controller,
    this.focusNode,
    this.hintText,
    this.prefixIcon,
    this.validator,
    this.onDateSelected,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  /// Etiqueta superior/flotante del campo.
  final String labelText;

  /// Controlador para gestionar y mostrar el valor de la fecha en formato YYYY-MM-DD.
  final TextEditingController controller;

  /// Nodo de enfoque opcional.
  final FocusNode? focusNode;

  /// Texto de sugerencia cuando el campo está vacío.
  final String? hintText;

  /// Icono decorativo al inicio del campo.
  final Widget? prefixIcon;

  /// Función de validación para el formulario.
  final String? Function(String?)? validator;

  /// Callback que expone el objeto DateTime limpio seleccionado por el usuario.
  final ValueChanged<DateTime>? onDateSelected;

  /// Fecha inicial seleccionada por defecto en el selector.
  final DateTime? initialDate;

  /// Límite inferior para la fecha seleccionable.
  final DateTime? firstDate;

  /// Límite superior para la fecha seleccionable.
  final DateTime? lastDate;

  /// Determina si el campo está activo o deshabilitado.
  final bool enabled;

  Future<void> _selectDate(BuildContext context) async {
    // Quita el foco actual para evitar resaltar otros campos
    FocusScope.of(context).requestFocus(FocusNode());

    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          // Forzar sincronización estética del DatePicker nativo con el tema oscuro de la app
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.secondary, // Teal #59DAD1
              onPrimary: Theme.of(context).colorScheme.onSecondary,
              surface: Theme.of(context).colorScheme.surfaceContainer,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Formateo manual en formato YYYY-MM-DD sin añadir dependencias pesadas
      final year = picked.year.toString();
      final month = picked.month.toString().padLeft(2, '0');
      final day = picked.day.toString().padLeft(2, '0');
      
      controller.text = '$year-$month-$day';
      if (onDateSelected != null) {
        onDateSelected!(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapStayTextField(
      labelText: labelText,
      controller: controller,
      focusNode: focusNode,
      hintText: hintText ?? 'Seleccione una fecha',
      prefixIcon: prefixIcon,
      suffixIcon: Icon(
        Icons.calendar_today_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      validator: validator,
      readOnly: true, // Evita abrir el teclado del sistema
      enabled: enabled,
      onTap: enabled ? () => _selectDate(context) : null,
    );
  }
}
