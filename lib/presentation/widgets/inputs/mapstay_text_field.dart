import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



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


  final String labelText;


  final TextEditingController? controller;


  final FocusNode? focusNode;


  final String? hintText;


  final Widget? prefixIcon;


  final Widget? suffixIcon;


  final String? Function(String?)? validator;


  final ValueChanged<String>? onChanged;


  final TextInputType? keyboardType;


  final TextInputAction? textInputAction;


  final bool obscureText;


  final bool readOnly;


  final VoidCallback? onTap;


  final bool isEmail;


  final bool enabled;


  final List<TextInputFormatter>? inputFormatters;


  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium;


    String? defaultEmailValidator(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'El correo electrónico es requerido';
      }

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

        errorStyle: TextStyle(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}
