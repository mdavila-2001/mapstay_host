import 'package:flutter/material.dart';
import 'mapstay_text_field.dart';



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


  final String labelText;


  final TextEditingController? controller;


  final FocusNode? focusNode;


  final String? hintText;


  final Widget? prefixIcon;


  final String? Function(String?)? validator;


  final ValueChanged<String>? onChanged;


  final TextInputAction? textInputAction;


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
