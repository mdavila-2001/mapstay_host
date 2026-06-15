import 'package:flutter/material.dart';
import 'mapstay_text_field.dart';



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


  final String labelText;


  final TextEditingController controller;


  final FocusNode? focusNode;


  final String? hintText;


  final Widget? prefixIcon;


  final String? Function(String?)? validator;


  final ValueChanged<DateTime>? onDateSelected;


  final DateTime? initialDate;


  final DateTime? firstDate;


  final DateTime? lastDate;


  final bool enabled;

  Future<void> _selectDate(BuildContext context) async {

    FocusScope.of(context).requestFocus(FocusNode());

    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(

          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.secondary,
              onPrimary: Theme.of(context).colorScheme.onSecondary,
              surface: Theme.of(context).colorScheme.surfaceContainer,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {

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
      readOnly: true,
      enabled: enabled,
      onTap: enabled ? () => _selectDate(context) : null,
    );
  }
}
