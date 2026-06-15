import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mapstay_text_field.dart';



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


  final String labelText;


  final TextEditingController? controller;


  final FocusNode? focusNode;


  final String? hintText;


  final Widget? prefixIcon;


  final Widget? suffixIcon;


  final String? Function(String?)? validator;


  final ValueChanged<String>? onChanged;


  final TextInputAction? textInputAction;


  final bool isDecimal;


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



class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }



    final regExp = RegExp(r'^\d*[\.,]?\d{0,2}$');
    
    if (regExp.hasMatch(newValue.text)) {

      final standardizedText = newValue.text.replaceAll(',', '.');
      return newValue.copyWith(
        text: standardizedText,
        selection: TextSelection.collapsed(offset: standardizedText.length),
      );
    }

    return oldValue;
  }
}
