import 'package:flutter/material.dart';


class MapStayOption<T> {
  const MapStayOption({
    required this.value,
    required this.label,
  });


  final T value;


  final String label;



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


  final String labelText;


  final List<MapStayOption<T>> options;


  final T? value;


  final ValueChanged<T?>? onChanged;


  final String? Function(T?)? validator;


  final String? hintText;


  final Widget? prefixIcon;


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
