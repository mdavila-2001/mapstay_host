import 'package:flutter/material.dart';

/// Modelo fuertemente tipado para las opciones del selector MapStay.
class MapStayOption<T> {
  const MapStayOption({
    required this.value,
    required this.label,
  });

  /// Valor interno que se retornará al formulario (ej. 1, 0, 'admin', etc.).
  final T value;

  /// Texto descriptivo que se muestra al usuario.
  final String label;

  /// Utilidad estática para generar opciones binarias (Sí/No) que mapean a entero (1/0).
  /// Requisito crucial para persistir datos binarios según la base de datos del backend.
  static List<MapStayOption<int>> binary({
    String trueLabel = 'Sí',
    String falseLabel = 'No',
  }) {
    return [
      MapStayOption(value: 1, label: trueLabel),
      MapStayOption(value: 0, label: falseLabel),
    ];
  }
}

/// Selector desplegable especializado en MapStay.
/// Wrapper sobre DropdownButtonFormField que mantiene consistencia visual con el tema base.
class MapStaySelectField<T> extends StatelessWidget {
  const MapStaySelectField({
    super.key,
    required this.labelText,
    required this.options,
    this.value,
    this.onChanged,
    this.validator,
    this.hintText,
    this.prefixIcon,
    this.enabled = true,
  });

  /// Etiqueta superior/flotante del campo.
  final String labelText;

  /// Lista estricta de opciones disponibles.
  final List<MapStayOption<T>> options;

  /// Valor actualmente seleccionado.
  final T? value;

  /// Callback ejecutado cuando el usuario selecciona una nueva opción.
  final ValueChanged<T?>? onChanged;

  /// Validador de formulario opcional.
  final String? Function(T?)? validator;

  /// Texto de sugerencia si no hay selección.
  final String? hintText;

  /// Icono decorativo inicial.
  final Widget? prefixIcon;

  /// Determina si el selector está habilitado.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText ?? 'Seleccione una opción',
        prefixIcon: prefixIcon,
        errorStyle: TextStyle(
          color: theme.colorScheme.error,
        ),
      ),
      // Estandarización estética del menú desplegable: fondo y tipografía
      dropdownColor: theme.colorScheme.surfaceContainerHigh,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      selectedItemBuilder: (BuildContext context) {
        return options.map((option) {
          return Text(
            option.label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          );
        }).toList();
      },
      items: options.map((option) {
        return DropdownMenuItem<T>(
          value: option.value,
          child: Text(
            option.label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        );
      }).toList(),
    );
  }
}
